library;

import 'package:sqflite/sqflite.dart';

import '../database/database_helper.dart';

import '../models/aya_model.dart';

import '../../core/arabic/arabic_normalizer.dart';

class QuranRepository {
  final DatabaseHelper _dbHelper;

  static const int _resultLimit = 50;

  QuranRepository({DatabaseHelper? dbHelper})
    : _dbHelper = dbHelper ?? DatabaseHelper.instance;

  Future<Database> get _db async => _dbHelper.database;

  List<AyaModel> _mapRows(List<Map<String, dynamic>> rows) =>
      rows.map(AyaModel.fromMap).toList();

  Future<List<AyaModel>> searchAyat(String query) async {
    final trimmed = query.trim();

    if (trimmed.isEmpty) return [];

    final tokens = trimmed
        .split(RegExp(r'\s+'))
        .where((t) => t.isNotEmpty)
        .toList();

    if (tokens.isEmpty) return [];
    final List<List<String>> expandedGroups = [];

    for (final token in tokens) {
      final group = await _expandToken(token);
      if (group.isNotEmpty) expandedGroups.add(group);
    }

    if (expandedGroups.isEmpty) return [];
    final matchExpr = _buildMatchExpression(expandedGroups, tokens);

    final db = await _db;

    try {
      final rows = await db.rawQuery(
        '''
        SELECT a.*
        FROM   aya     AS a
        JOIN   aya_fts AS f ON a.gid = f.rowid
        WHERE  aya_fts MATCH ?
        ORDER  BY bm25(aya_fts)
        LIMIT  $_resultLimit
        ''',
        [matchExpr],
      );

      return _mapRows(rows);
    } on DatabaseException catch (e) {
      if (_isFtsQueryError(e)) {
        final fallback = expandedGroups.first.first;
        return _likeSearchFallback(fallback);
      }

      rethrow;
    }
  }

  Future<List<String>> _expandToken(String token) async {
    if (token.startsWith('~') && token.length > 1) {
      final word = ArabicNormalizer.normalize(token.substring(1));

      if (word.isEmpty) return [];

      final expanded = await _synonymExpansion(word);

      return {word, ...expanded}.toList();
    } else if (token.startsWith('<') && token.length > 1) {
      final word = ArabicNormalizer.normalize(token.substring(1));

      if (word.isEmpty) return [];
      final expanded = await _derivationExpansion(word);
      return {word, ...expanded}.toList();
    } else {
      final cleaned = token.endsWith('*')
          ? token.substring(0, token.length - 1)
          : token;

      final norm = ArabicNormalizer.normalize(cleaned);

      return norm.isEmpty ? [] : [norm];
    }
  }

  Future<List<String>> _synonymExpansion(String normalizedWord) async {
    try {
      final db = await _db;

      final forward = await db.query(
        'synonym',
        columns: ['synonym'],
        where: 'word = ?',
        whereArgs: [normalizedWord],
      );

      final reverse = await db.query(
        'synonym',
        columns: ['word'],
        where: 'synonym = ?',
        whereArgs: [normalizedWord],
      );

      final results = <String>{};
      for (final row in forward) {
        final s = row['synonym'] as String? ?? '';
        final norm = ArabicNormalizer.normalize(s);
        if (norm.isNotEmpty) results.add(norm);
      }

      for (final row in reverse) {
        final w = row['word'] as String? ?? '';
        final norm = ArabicNormalizer.normalize(w);
        if (norm.isNotEmpty) results.add(norm);
      }

      return results.toList();
    } catch (_) {
      return [];
    }
  }

  Future<List<String>> _derivationExpansion(String normalizedWord) async {
    try {
      final db = await _db;
      final lemmaRows = await db.query(
        'derivation',
        columns: ['lemma'],
        where: 'word_form = ?',
        whereArgs: [normalizedWord],
        limit: 1,
      );

      if (lemmaRows.isNotEmpty) {
        final lemma = lemmaRows.first['lemma'] as String? ?? '';
        if (lemma.isNotEmpty) {
          return await _wordsByLemma(lemma);
        }
      }

      final rootRows = await db.query(
        'derivation',
        columns: ['root'],
        where: 'word_form = ?',
        whereArgs: [normalizedWord],
        limit: 1,
      );

      if (rootRows.isNotEmpty) {
        final root = rootRows.first['root'] as String? ?? '';
        if (root.isNotEmpty) {
          return await _wordsByRoot(root);
        }
      }

      return [];
    } catch (_) {
      return [];
    }
  }

  String _buildMatchExpression(
    List<List<String>> groups,

    List<String> rawTokens,
  ) {
    final parts = <String>[];

    for (int i = 0; i < groups.length; i++) {
      final words = groups[i];
      final rawToken = i < rawTokens.length ? rawTokens[i] : '';
      final isPlainToken =
          !rawToken.startsWith('~') && !rawToken.startsWith('<');
      if (words.length == 1) {
        final word = words.first;
        final escaped = _escapeWord(word);
        final useWildcard = isPlainToken && word.length >= 3;
        parts.add(useWildcard ? '"$escaped"*' : '"$escaped"');
      } else {
        final inner = words.map((w) => '"${_escapeWord(w)}"').join(' OR ');
        parts.add('($inner)');
      }
    }

    final body = parts.join(' AND ');
    // FTS5 brace column-filter: only the `normalized` column is searched.
    // This form is correct when MATCH is called at table level (aya_fts MATCH ?).
    // The colon syntax `normalized : (...)` conflicts with column-alias MATCH.
    return '{normalized} $body';
  }

  Future<List<AyaModel>> getSurah(int suraId) async {
    final db = await _db;
    final rows = await db.rawQuery(
      'SELECT * FROM aya WHERE sura_id = ? ORDER BY aya_id ASC',
      [suraId],
    );

    return _mapRows(rows);
  }

  Future<List<AyaModel>> getAyatBySura(int suraId) => getSurah(suraId);

  Future<AyaModel?> getAyaByGid(int gid) async {
    final db = await _db;

    final rows = await db.query(
      'aya',
      where: 'gid = ?',
      whereArgs: [gid],
      limit: 1,
    );

    return rows.isEmpty ? null : AyaModel.fromMap(rows.first);
  }

  Future<List<String>> _wordsByLemma(String lemma) async {
    final db = await _db;

    final rows = await db.query(
      'derivation',
      columns: ['word_form'],
      where: 'lemma = ?',
      whereArgs: [lemma],
      distinct: true,
    );

    return rows
        .map((r) => ArabicNormalizer.normalize(r['word_form'] as String? ?? ''))
        .where((w) => w.isNotEmpty)
        .toList();
  }

  Future<List<String>> _wordsByRoot(String root) async {
    final db = await _db;

    final rows = await db.query(
      'derivation',
      columns: ['word_form'],
      where: 'root = ?',
      whereArgs: [root],
      distinct: true,
    );

    return rows
        .map((r) => ArabicNormalizer.normalize(r['word_form'] as String? ?? ''))
        .where((w) => w.isNotEmpty)
        .toList();
  }

  Future<List<String>> getSynonyms(String word) =>
      _synonymExpansion(ArabicNormalizer.normalize(word));

  Future<List<String>> getWordsByLemma(String lemma) => _wordsByLemma(lemma);

  Future<List<String>> getWordsByRoot(String root) => _wordsByRoot(root);

  String _escapeWord(String word) => word.replaceAll('"', '""');

  Future<List<AyaModel>> _likeSearchFallback(String normalized) async {
    final db = await _db;

    final rows = await db.query(
      'aya',
      where: 'normalized LIKE ?',
      whereArgs: ['%$normalized%'],
      limit: _resultLimit,
    );

    return _mapRows(rows);
  }

  bool _isFtsQueryError(DatabaseException e) {
    final msg = e.toString().toLowerCase();
    return msg.contains('fts5') ||
        msg.contains('syntax error') ||
        msg.contains('malformed');
  }
}
