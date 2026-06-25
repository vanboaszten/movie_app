import 'db_helper_stub.dart'
    if (dart.library.html) 'db_helper_web.dart'
    if (dart.library.io) 'db_helper_mobile.dart';

abstract class DatabaseHelper {
  static DatabaseHelper? _instance;
  static DatabaseHelper get instance {
    _instance ??= getDatabaseHelper();
    return _instance!;
  }

  Future<int> insert(String table, Map<String, dynamic> values, {String? conflictAlgorithm});
  Future<int> delete(String table, {String? where, List<Object?>? whereArgs});
  Future<List<Map<String, dynamic>>> query(String table, {String? where, List<Object?>? whereArgs, int? limit});
  Future<int> update(String table, Map<String, dynamic> values, {String? where, List<Object?>? whereArgs});
}
