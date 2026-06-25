import '../database/database_helper.dart';
import '../models/movie_model.dart';

class FavoriteService {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  /// Saves a movie as a favorite for a given user.
  Future<void> addFavorite(int userId, Movie movie) async {
    await _dbHelper.insert(
      'favorites',
      {
        'user_id': userId,
        'movie_id': movie.id,
        'title': movie.title,
        'poster_url': movie.posterUrl,
        'backdrop_url': movie.backdropUrl,
        'rating': movie.rating,
        'genres': movie.genres.join(','),
        'release_year': movie.releaseYear,
        'synopsis': movie.synopsis,
        'director': movie.director,
        'duration': movie.duration,
        'language': movie.language,
        'maturity_rating': movie.maturityRating,
        'trailer_url': movie.trailerUrl,
      },
      conflictAlgorithm: 'replace',
    );
  }

  /// Removes a movie from a user's favorites list.
  Future<void> removeFavorite(int userId, int movieId) async {
    await _dbHelper.delete(
      'favorites',
      where: 'user_id = ? AND movie_id = ?',
      whereArgs: [userId, movieId],
    );
  }

  /// Checks if a movie is favorited by a user.
  Future<bool> isFavorite(int userId, int movieId) async {
    final List<Map<String, dynamic>> results = await _dbHelper.query(
      'favorites',
      where: 'user_id = ? AND movie_id = ?',
      whereArgs: [userId, movieId],
      limit: 1,
    );
    return results.isNotEmpty;
  }

  /// Returns all favorited movies for a user.
  Future<List<Movie>> getFavorites(int userId) async {
    final List<Map<String, dynamic>> results = await _dbHelper.query(
      'favorites',
      where: 'user_id = ?',
      whereArgs: [userId],
    );

    return results.map((map) {
      return Movie(
        id: map['movie_id'] as int,
        title: map['title'] as String,
        posterUrl: map['poster_url'] as String,
        backdropUrl: map['backdrop_url'] as String,
        rating: (map['rating'] as num).toDouble(),
        genres: (map['genres'] as String)
            .split(',')
            .map((g) => g.trim())
            .where((g) => g.isNotEmpty)
            .toList(),
        releaseYear: map['release_year'] as int,
        synopsis: map['synopsis'] as String,
        director: map['director'] as String,
        duration: map['duration'] as String,
        language: map['language'] as String,
        maturityRating: map['maturity_rating'] as String,
        trailerUrl: map['trailer_url'] as String,
      );
    }).toList();
  }

  /// Toggles the favorite status of a movie for a user.
  Future<void> toggleFavorite(int userId, Movie movie) async {
    final favorited = await isFavorite(userId, movie.id);
    if (favorited) {
      await removeFavorite(userId, movie.id);
    } else {
      await addFavorite(userId, movie);
    }
  }
}
