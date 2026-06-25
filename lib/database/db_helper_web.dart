// ignore_for_file: avoid_web_libraries_in_flutter
import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;
import 'database_helper.dart';

DatabaseHelper getDatabaseHelper() => DatabaseHelperWeb._init();

class DatabaseHelperWeb implements DatabaseHelper {
  DatabaseHelperWeb._init() {
    _initWebDB();
  }

  void _initWebDB() {
    final usersJson = html.window.localStorage['users'];
    if (usersJson == null) {
      final defaultUsers = [
        {
          'id': 1,
          'username': 'admin',
          'password': '123456',
          'name': 'Admin User',
        }
      ];
      html.window.localStorage['users'] = jsonEncode(defaultUsers);
    }

    final favsJson = html.window.localStorage['favorites'];
    if (favsJson == null) {
      html.window.localStorage['favorites'] = jsonEncode([]);
    }
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
}
