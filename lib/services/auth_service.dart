import '../database/database_helper.dart';

class AuthService {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  /// Verifies credentials against the local SQLite users table.
  /// 
  /// Returns a [Map] containing user details if successful,
  /// or [null] if username and password combination is invalid.
  Future<Map<String, dynamic>?> login(String username, String password) async {
    final db = await _dbHelper.database;

    final List<Map<String, dynamic>> results = await db.query(
      'users',
      where: 'username = ? AND password = ?',
      whereArgs: [username, password],
      limit: 1,
    );

    if (results.isNotEmpty) {
      return results.first;
    }
    return null;
  }
}
