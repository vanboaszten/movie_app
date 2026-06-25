// ignore_for_file: avoid_web_libraries_in_flutter
import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;
import 'database_helper.dart';
import '../data/dummy_movies.dart';

DatabaseHelper getDatabaseHelper() => DatabaseHelperWeb._init();

class DatabaseHelperWeb implements DatabaseHelper {
  DatabaseHelperWeb._init() {
    _initWebDB();
  }

  void _initWebDB() {
    final usersJson = html.window.localStorage['users'];
    List<dynamic> users = [];
    if (usersJson != null) {
      try {
        users = jsonDecode(usersJson);
      } catch (_) {}
    }

    final defaultUsers = [
      {'username': 'admin', 'password': '123456', 'name': 'Admin User', 'role': 'admin'},
      {'username': 'pai', 'password': 'Pai123', 'name': 'Pai', 'role': 'user'},
      {'username': 'arya', 'password': 'arya123', 'name': 'Arya', 'role': 'user'},
      {'username': 'qolby', 'password': 'qolby123', 'name': 'Qolby', 'role': 'user'},
      {'username': 'dika', 'password': 'dika123', 'name': 'Dika', 'role': 'user'},
    ];

    int nextId = 1;
    if (users.isNotEmpty) {
      final ids = users.map((e) => e['id'] as int? ?? 0);
      nextId = ids.reduce((a, b) => a > b ? a : b) + 1;
    }

    for (var def in defaultUsers) {
      final existingIndex = users.indexWhere((u) => u['username'] == def['username']);
      if (existingIndex == -1) {
        users.add({
          'id': nextId++,
          ...def,
        });
      } else {
        final Map<String, dynamic> existing = Map<String, dynamic>.from(users[existingIndex]);
        if (!existing.containsKey('role') || existing['role'] == null) {
          existing['role'] = def['role'];
          users[existingIndex] = existing;
        }
      }
    }

    html.window.localStorage['users'] = jsonEncode(users);

    final favsJson = html.window.localStorage['favorites'];
    if (favsJson == null) {
      html.window.localStorage['favorites'] = jsonEncode([]);
    }

    final moviesJson = html.window.localStorage['movies'];
    List<dynamic> movies = [];
    if (moviesJson != null) {
      try {
        movies = jsonDecode(moviesJson);
      } catch (_) {}
    }

    if (movies.isEmpty) {
      movies = dummyMovies.map((m) => m.toMap()).toList();
    } else {
      for (var dm in dummyMovies) {
        final exists = movies.any((m) => m['id'] == dm.id);
        if (!exists) {
          movies.add(dm.toMap());
        }
      }
    }
    html.window.localStorage['movies'] = jsonEncode(movies);
  }

  @override
  Future<int> insert(String table, Map<String, dynamic> values, {String? conflictAlgorithm}) async {
    final dataJson = html.window.localStorage[table] ?? '[]';
    final List<dynamic> list = jsonDecode(dataJson);

    int newId = 1;
    if (list.isNotEmpty) {
      final maxId = list.map((e) => e['id'] as int? ?? 0).reduce((a, b) => a > b ? a : b);
      newId = maxId + 1;
    }

    final Map<String, dynamic> row = Map<String, dynamic>.from(values);
    if (!row.containsKey('id')) {
      row['id'] = newId;
    }

    if (table == 'favorites') {
      final userId = row['user_id'];
      final movieId = row['movie_id'];
      final existsIndex = list.indexWhere((e) => e['user_id'] == userId && e['movie_id'] == movieId);
      if (existsIndex != -1) {
        if (conflictAlgorithm == 'replace') {
          list[existsIndex] = row;
        } else {
          return -1;
        }
      } else {
        list.add(row);
      }
    } else {
      list.add(row);
    }

    html.window.localStorage[table] = jsonEncode(list);
    return row['id'] as int;
  }

  @override
  Future<int> delete(String table, {String? where, List<Object?>? whereArgs}) async {
    final dataJson = html.window.localStorage[table] ?? '[]';
    final List<dynamic> list = jsonDecode(dataJson);
    int initialLength = list.length;

    if (table == 'favorites' && where == 'user_id = ? AND movie_id = ?' && whereArgs != null && whereArgs.length == 2) {
      final userId = whereArgs[0];
      final movieId = whereArgs[1];
      list.removeWhere((e) => e['user_id'] == userId && e['movie_id'] == movieId);
    }

    html.window.localStorage[table] = jsonEncode(list);
    return initialLength - list.length;
  }

  @override
  Future<List<Map<String, dynamic>>> query(String table, {String? where, List<Object?>? whereArgs, int? limit}) async {
    final dataJson = html.window.localStorage[table] ?? '[]';
    final List<dynamic> list = jsonDecode(dataJson);
    List<Map<String, dynamic>> results = list.map((e) => Map<String, dynamic>.from(e)).toList();

    if (table == 'users' && where == 'username = ? AND password = ?' && whereArgs != null && whereArgs.length == 2) {
      final username = whereArgs[0];
      final password = whereArgs[1];
      results = results.where((e) => e['username'] == username && e['password'] == password).toList();
    } else if (table == 'favorites' && where == 'user_id = ? AND movie_id = ?' && whereArgs != null && whereArgs.length == 2) {
      final userId = whereArgs[0];
      final movieId = whereArgs[1];
      results = results.where((e) => e['user_id'] == userId && e['movie_id'] == movieId).toList();
    } else if (table == 'favorites' && where == 'user_id = ?' && whereArgs != null && whereArgs.length == 1) {
      final userId = whereArgs[0];
      results = results.where((e) => e['user_id'] == userId).toList();
    }

    if (limit != null && results.length > limit) {
      results = results.sublist(0, limit);
    }

    return results;
  }

  @override
  Future<int> update(String table, Map<String, dynamic> values, {String? where, List<Object?>? whereArgs}) async {
    final dataJson = html.window.localStorage[table] ?? '[]';
    final List<dynamic> list = jsonDecode(dataJson);
    int updatedCount = 0;

    for (int i = 0; i < list.length; i++) {
      final Map<String, dynamic> item = Map<String, dynamic>.from(list[i]);
      if (where == 'id = ?' && whereArgs != null && whereArgs.length == 1) {
        final id = whereArgs[0];
        if (item['id'] == id) {
          values.forEach((key, val) {
            item[key] = val;
          });
          list[i] = item;
          updatedCount++;
        }
      }
    }

    if (updatedCount > 0) {
      html.window.localStorage[table] = jsonEncode(list);
    }
    return updatedCount;
  }
}
