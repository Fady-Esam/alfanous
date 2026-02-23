import 'package:sqflite/sqflite.dart';

import '../database/database_helper.dart';
import '../models/aya_model.dart';

class FavoritesRepository {
  final DatabaseHelper _dbHelper;

  FavoritesRepository({DatabaseHelper? dbHelper})
    : _dbHelper = dbHelper ?? DatabaseHelper.instance;

  Future<Database> get _db async => _dbHelper.database;

  Future<bool> toggleFavorite(int gid) async {
    final db = await _db;

    final exists = await isFavorite(gid);

    if (exists) {
      await db.delete('favorites', where: 'gid = ?', whereArgs: [gid]);
      return false;
    } else {
      await db.insert('favorites', {
        'gid': gid,
      }, conflictAlgorithm: ConflictAlgorithm.ignore);
      return true;
    }
  }

  Future<bool> isFavorite(int gid) async {
    final db = await _db;
    final rows = await db.query(
      'favorites',
      where: 'gid = ?',
      whereArgs: [gid],
      limit: 1,
    );
    return rows.isNotEmpty;
  }

  Future<Set<int>> getAllFavoriteGids() async {
    final db = await _db;
    final rows = await db.query('favorites', columns: ['gid']);
    return rows.map((row) => row['gid'] as int).toSet();
  }

  Future<List<AyaModel>> getAllFavorites() async {
    final db = await _db;
    final rows = await db.rawQuery('''
      SELECT a.* 
      FROM aya a
      INNER JOIN favorites f ON a.gid = f.gid
      ORDER BY f.added_at DESC
    ''');

    return rows.map(AyaModel.fromMap).toList();
  }
}
