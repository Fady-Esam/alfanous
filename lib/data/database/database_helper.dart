import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('quran.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, filePath);

    bool dbExists = await File(path).exists();

    if (!dbExists) {
      debugPrint("Creating a copy of the database from assets...");

      ByteData data = await rootBundle.load(join('assets', filePath));
      List<int> bytes = data.buffer.asUint8List(
        data.offsetInBytes,
        data.lengthInBytes,
      );

      await File(path).writeAsBytes(bytes, flush: true);
      debugPrint("Database copied successfully!");
    } else {
      debugPrint("Database already exists. Opening...");
    }

    final db = await openDatabase(path);

    await db.execute('''
      CREATE TABLE IF NOT EXISTS favorites (
        gid INTEGER PRIMARY KEY,
        added_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    return db;
  }
}
