import '../database/database_helper.dart';
import '../models/movie_model.dart';

class MovieService {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<List<Movie>> getAllMovies() async {
    final List<Map<String, dynamic>> results = await _dbHelper.query('movies');
    return results.map((map) => Movie.fromMap(map)).toList();
  }

  Future<int> insertMovie(Movie movie) async {
    return await _dbHelper.insert(
      'movies',
      movie.toMap(),
      conflictAlgorithm: 'replace',
    );
  }

  Future<int> updateMovie(Movie movie) async {
    return await _dbHelper.update(
      'movies',
      movie.toMap(),
      where: 'id = ?',
      whereArgs: [movie.id],
    );
  }

  Future<Movie?> getMovieById(int id) async {
    final List<Map<String, dynamic>> results = await _dbHelper.query(
      'movies',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (results.isNotEmpty) {
      return Movie.fromMap(results.first);
    }
    return null;
  }
}
