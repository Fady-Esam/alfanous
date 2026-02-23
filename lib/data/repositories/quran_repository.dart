library;

import 'package:sqflite/sqflite.dart';

import '../database/database_helper.dart';
import '../models/aya_model.dart';
import '../../core/arabic/arabic_normalizer.dart';

enum SortMode { score, mushaf, tanzil, subject, ayaLength }

class SearchResultItem {
  final AyaModel aya;
  final List<String> highlightTerms;
  const SearchResultItem({required this.aya, required this.highlightTerms});
}

sealed class _ExpandedGroup {
  const _ExpandedGroup();
}

final class _IncludeGroup extends _ExpandedGroup {
  final List<String> words;
  const _IncludeGroup(this.words);
}

final class _ExcludeGroup extends _ExpandedGroup {
  final List<String> words;
  const _ExcludeGroup(this.words);
}

final class _PhraseGroup extends _ExpandedGroup {
  final String phrase;
  const _PhraseGroup(this.phrase);
}

class QuranRepository {
  final DatabaseHelper _dbHelper;

  QuranRepository({DatabaseHelper? dbHelper})
    : _dbHelper = dbHelper ?? DatabaseHelper.instance;

  Future<Database> get _db async => _dbHelper.database;

  List<AyaModel> _mapRows(List<Map<String, dynamic>> rows) =>
      rows.map(AyaModel.fromMap).toList();

  static const Set<String> _stopWords = {
    'أن',
    'أو',
    'إذا',
    'إلا',
    'إلى',
    'إن',
    'الذي',
    'الذين',
    'بما',
    'به',
    'ثم',
    'ذلك',
    'شيء',
    'على',
    'عليهم',
    'عن',
    'في',
    'فيها',
    'كان',
    'كانوا',
    'كل',
    'كنتم',
    'لا',
    'لكم',
    'لم',
    'له',
    'لهم',
    'ما',
    'من',
    'هذا',
    'هم',
    'هو',
    'وإن',
    'ولا',
    'وما',
    'ومن',
    'وهو',
    'يا',
  };

  Future<int> getTotalSearchCount(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return 0;

    final rawTokens = RegExp(r'[^\s"]+|"[^"]*"')
        .allMatches(trimmed)
        .map((m) => m.group(0)!)
        .where((t) => t.isNotEmpty)
        .toList();

    if (rawTokens.isEmpty) return 0;

    final groups = <_ExpandedGroup>[];
    for (final token in rawTokens) {
      final group = await _expandToken(token);
      if (group != null) groups.add(group);
    }

    if (groups.isEmpty) return 0;

    final includeGroups = groups.whereType<_IncludeGroup>().toList();
    if (includeGroups.isNotEmpty) {
      final allStops = includeGroups.every(
        (g) => g.words.every(_stopWords.contains),
      );
      if (allStops) return 0;
    }

    final matchExpr = _buildMatchExpression(groups);
    final db = await _db;
    try {
      final rows = await db.rawQuery(
        'SELECT COUNT(*) FROM aya_fts WHERE aya_fts MATCH ?',
        [matchExpr],
      );
      return Sqflite.firstIntValue(rows) ?? 0;
    } on DatabaseException catch (e) {
      if (_isFtsQueryError(e)) {
        final fallbackWord =
            includeGroups.isNotEmpty && includeGroups.first.words.isNotEmpty
            ? includeGroups.first.words.first
            : '';
        if (fallbackWord.isNotEmpty) {
          final fallbackRows = await db.query(
            'aya',
            columns: ['COUNT(*)'],
            where: 'normalized LIKE ?',
            whereArgs: ['%$fallbackWord%'],
          );
          return Sqflite.firstIntValue(fallbackRows) ?? 0;
        }
      }
      return 0;
    }
  }

  Future<List<SearchResultItem>> searchAyat(
    String query, {
    int limit = 50,
    int offset = 0,
    SortMode sort = SortMode.score,
  }) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return const [];

    final rawTokens = RegExp(r'[^\s"]+|"[^"]*"')
        .allMatches(trimmed)
        .map((m) => m.group(0)!)
        .where((t) => t.isNotEmpty)
        .toList();

    if (rawTokens.isEmpty) return const [];

    final groups = <_ExpandedGroup>[];
    for (final token in rawTokens) {
      final group = await _expandToken(token);
      if (group != null) groups.add(group);
    }

    if (groups.isEmpty) return const [];

    final highlightTerms = groups
        .whereType<_IncludeGroup>()
        .expand((g) => g.words)
        .map((w) => w.endsWith('*') ? w.substring(0, w.length - 1) : w)
        .where((w) => w.isNotEmpty && !w.startsWith('?'))
        .toSet()
        .toList();

    final includeGroups = groups.whereType<_IncludeGroup>().toList();
    if (includeGroups.isNotEmpty) {
      final allStops = includeGroups.every(
        (g) => g.words.every(_stopWords.contains),
      );
      if (allStops) return const [];
    }

    final matchExpr = _buildMatchExpression(groups);

    final orderBy = _orderByClause(sort);

    final db = await _db;
    try {
      final rows = await db.rawQuery(
        '''
        SELECT a.*
        FROM   aya     AS a
        JOIN   aya_fts AS f ON a.gid = f.rowid
        WHERE  aya_fts MATCH ?
        $orderBy
        LIMIT  $limit OFFSET $offset
        ''',
        [matchExpr],
      );
      return rows
          .map(AyaModel.fromMap)
          .map(
            (aya) => SearchResultItem(aya: aya, highlightTerms: highlightTerms),
          )
          .toList();
    } on DatabaseException catch (e) {
      if (_isFtsQueryError(e)) {
        final fallbackWord =
            includeGroups.isNotEmpty && includeGroups.first.words.isNotEmpty
            ? includeGroups.first.words.first
            : '';
        if (fallbackWord.isNotEmpty) {
          final fallbackAyas = await _likeSearchFallback(
            fallbackWord,
            limit,
            offset,
          );
          return fallbackAyas
              .map(
                (aya) =>
                    SearchResultItem(aya: aya, highlightTerms: highlightTerms),
              )
              .toList();
        }
        return const [];
      }
      rethrow;
    }
  }

  Future<_ExpandedGroup?> _expandToken(String token) async {
    if (token.startsWith('"') && token.endsWith('"') && token.length > 2) {
      final inner = token.substring(1, token.length - 1).trim();
      if (inner.isEmpty) return null;
      final normWords = inner
          .split(RegExp(r'\s+'))
          .map(ArabicNormalizer.normalizeQuery)
          .where((w) => w.isNotEmpty)
          .toList();
      if (normWords.isEmpty) return null;
      return _PhraseGroup(normWords.join(' '));
    }

    if (token.startsWith('-') && token.length > 1) {
      final word = ArabicNormalizer.normalizeQuery(token.substring(1));
      if (word.isEmpty) return null;
      return _ExcludeGroup([word]);
    }

    if (token.startsWith('~') && token.length > 1) {
      final word = ArabicNormalizer.normalizeQuery(token.substring(1));
      if (word.isEmpty) return null;
      final expanded = await _synonymExpansion(word);
      return _IncludeGroup({word, ...expanded}.toList());
    }

    if (token.startsWith('#') && token.length > 1) {
      final word = ArabicNormalizer.normalizeQuery(token.substring(1));
      if (word.isEmpty) return null;
      final expanded = await _antonymExpansion(word);

      return _IncludeGroup({word, ...expanded}.toList());
    }

    if (token.startsWith('<<') && token.length > 2) {
      final word = ArabicNormalizer.normalizeQuery(token.substring(2));
      if (word.isEmpty) return null;
      final expanded = await _rootDerivationExpansion(word);
      return _IncludeGroup({word, ...expanded}.toList());
    }

    if (token.startsWith('<') && token.length > 1) {
      final word = ArabicNormalizer.normalizeQuery(token.substring(1));
      if (word.isEmpty) return null;
      final expanded = await _derivationExpansion(word);
      return _IncludeGroup({word, ...expanded}.toList());
    }

    final hasStar = token.endsWith('*');
    final cleaned = hasStar ? token.substring(0, token.length - 1) : token;
    final hasLeadQ = cleaned.startsWith('?');
    final stem = hasLeadQ ? cleaned.substring(1) : cleaned;

    final norm = ArabicNormalizer.normalizeQuery(stem);
    if (norm.isEmpty) return null;

    final result = '${hasLeadQ ? '?' : ''}$norm${hasStar ? '*' : ''}';
    return _IncludeGroup([result]);
  }

  String _buildMatchExpression(List<_ExpandedGroup> groups) {
    final positives = <String>[];
    final negatives = <String>[];

    for (final group in groups) {
      switch (group) {
        case _PhraseGroup group:
          final escaped = _escapeWord(group.phrase);
          positives.add('"$escaped"');

        case _ExcludeGroup group:
          for (final word in group.words) {
            negatives.add('NOT "${_escapeWord(word)}"');
          }

        case _IncludeGroup group:
          if (group.words.isEmpty) continue;
          if (group.words.length == 1) {
            final word = group.words.first;

            if (word.contains('*') || word.contains('?')) {
              positives.add(word);
            } else {
              positives.add('"${_escapeWord(word)}"');
            }
          } else {
            final inner = group.words
                .map((w) => '"${_escapeWord(w)}"')
                .join(' OR ');
            positives.add('($inner)');
          }
      }
    }

    if (positives.isEmpty && negatives.isNotEmpty) {
      return '{normalized} ""';
    }

    final body = [...positives, ...negatives].join(' ');

    return '{normalized} $body';
  }

  String _orderByClause(SortMode sort) => switch (sort) {
    SortMode.score => 'ORDER BY bm25(aya_fts)',
    SortMode.mushaf => 'ORDER BY a.gid ASC',
    SortMode.tanzil => 'ORDER BY a.sura_order ASC, a.aya_id ASC',
    SortMode.subject => 'ORDER BY a.chapter ASC, a.topic ASC, a.subtopic ASC',
    SortMode.ayaLength => 'ORDER BY a.aya_letters_nb ASC, a.aya_words_nb ASC',
  };

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
        final norm = ArabicNormalizer.normalize(
          row['synonym'] as String? ?? '',
        );
        if (norm.isNotEmpty) results.add(norm);
      }
      for (final row in reverse) {
        final norm = ArabicNormalizer.normalize(row['word'] as String? ?? '');
        if (norm.isNotEmpty) results.add(norm);
      }
      return results.toList();
    } catch (_) {
      return [];
    }
  }

  Future<List<String>> _antonymExpansion(String normalizedWord) async {
    try {
      final db = await _db;

      final forward = await db.query(
        'antonym',
        columns: ['antonym'],
        where: 'word = ?',
        whereArgs: [normalizedWord],
      );
      final reverse = await db.query(
        'antonym',
        columns: ['word'],
        where: 'antonym = ?',
        whereArgs: [normalizedWord],
      );

      final results = <String>{};
      for (final row in forward) {
        final norm = ArabicNormalizer.normalize(
          row['antonym'] as String? ?? '',
        );
        if (norm.isNotEmpty) results.add(norm);
      }
      for (final row in reverse) {
        final norm = ArabicNormalizer.normalize(row['word'] as String? ?? '');
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
        if (lemma.isNotEmpty) return _wordsByLemma(lemma);
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
        if (root.isNotEmpty) return _wordsByRoot(root);
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  Future<List<String>> _rootDerivationExpansion(String normalizedWord) async {
    try {
      final db = await _db;
      final rootRows = await db.query(
        'derivation',
        columns: ['root'],
        where: 'word_form = ?',
        whereArgs: [normalizedWord],
        limit: 1,
      );
      if (rootRows.isNotEmpty) {
        final root = rootRows.first['root'] as String? ?? '';
        if (root.isNotEmpty) return _wordsByRoot(root);
      }
      return [];
    } catch (_) {
      return [];
    }
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

  Future<AyaModel?> getRandomAya() async {
    final db = await _db;
    final rows = await db.rawQuery(
      'SELECT * FROM aya ORDER BY RANDOM() LIMIT 1',
    );
    return rows.isEmpty ? null : AyaModel.fromMap(rows.first);
  }

  Future<List<String>> getSynonyms(String word) =>
      _synonymExpansion(ArabicNormalizer.normalize(word));

  Future<List<String>> getAntonyms(String word) =>
      _antonymExpansion(ArabicNormalizer.normalize(word));

  Future<List<String>> getWordsByLemma(String lemma) => _wordsByLemma(lemma);

  Future<List<String>> getWordsByRoot(String root) => _wordsByRoot(root);

  String _escapeWord(String word) => word.replaceAll('"', '""');

  Future<List<AyaModel>> _likeSearchFallback(
    String normalized,
    int limit,
    int offset,
  ) async {
    final db = await _db;
    final rows = await db.query(
      'aya',
      where: 'normalized LIKE ?',
      whereArgs: ['%$normalized%'],
      limit: limit,
      offset: offset,
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
