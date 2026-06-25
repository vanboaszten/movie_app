import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'database_helper.dart';

DatabaseHelper getDatabaseHelper() => DatabaseHelperMobile._init();

class DatabaseHelperMobile implements DatabaseHelper {
  static Database? _database;

  DatabaseHelperMobile._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('movie_app.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 2,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL,
        name TEXT NOT NULL
      )
    ''');

    await db.insert('users', {
      'username': 'admin',
      'password': '123456',
      'name': 'Admin User',
    });

    await _createFavoritesTable(db);
  }

  Future<void> _createFavoritesTable(Database db) async {
    await db.execute('''
      CREATE TABLE favorites (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        movie_id INTEGER NOT NULL,
        title TEXT NOT NULL,
        poster_url TEXT NOT NULL,
        backdrop_url TEXT NOT NULL,
        rating REAL NOT NULL,
        genres TEXT NOT NULL,
        release_year INTEGER NOT NULL,
        synopsis TEXT NOT NULL,
        director TEXT NOT NULL,
        duration TEXT NOT NULL,
        language TEXT NOT NULL,
        maturity_rating TEXT NOT NULL,
        trailer_url TEXT NOT NULL,
        UNIQUE(user_id, movie_id)
      )
    ''');
  }

  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await _createFavoritesTable(db);
    }
  }

  @override
  Future<int> insert(String table, Map<String, dynamic> values, {String? conflictAlgorithm}) async {
    final db = await database;
    return await db.insert(
      table,
      values,
      conflictAlgorithm: conflictAlgorithm != null
          ? (conflictAlgorithm == 'replace' ? ConflictAlgorithm.replace : ConflictAlgorithm.ignore)
          : null,
    );
  }

  @override
  Future<int> delete(String table, {String? where, List<Object?>? whereArgs}) async {
    final db = await database;
    return await db.delete(table, where: where, whereArgs: whereArgs);
  }

  @override
  Future<List<Map<String, dynamic>>> query(String table, {String? where, List<Object?>? whereArgs, int? limit}) async {
    final db = await database;
    return await db.query(table, where: where, whereArgs: whereArgs, limit: limit);
  }
}
