class Movie {
  final int id;
  final String title;
  final String posterUrl;
  final String backdropUrl;
  final double rating;
  final List<String> genres;
  final int releaseYear;
  final String synopsis;
  final String director;
  final String duration;
  final String language;
  final String maturityRating;
  final String trailerUrl;

  Movie({
    required this.id,
    required this.title,
    required this.posterUrl,
    required this.backdropUrl,
    required this.rating,
    required this.genres,
    required this.releaseYear,
    required this.synopsis,
    required this.director,
    required this.duration,
    required this.language,
    required this.maturityRating,
    required this.trailerUrl,
  });

  // Convert Movie to Map for SQLite database storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'posterUrl': posterUrl,
      'backdropUrl': backdropUrl,
      'rating': rating,
      'genres': genres.join(','), // Store as comma-separated string in local database
      'releaseYear': releaseYear,
      'synopsis': synopsis,
      'director': director,
      'duration': duration,
      'language': language,
      'maturityRating': maturityRating,
      'trailerUrl': trailerUrl,
    };
  }

  // Create Movie from SQLite database Map
  factory Movie.fromMap(Map<String, dynamic> map) {
    return Movie(
      id: map['id'] as int,
      title: map['title'] as String,
      posterUrl: map['posterUrl'] as String,
      backdropUrl: map['backdropUrl'] as String,
      rating: (map['rating'] as num).toDouble(),
      genres: (map['genres'] as String)
          .split(',')
          .map((g) => g.trim())
          .where((g) => g.isNotEmpty)
          .toList(),
      releaseYear: map['releaseYear'] as int,
      synopsis: map['synopsis'] as String,
      director: map['director'] as String,
      duration: map['duration'] as String,
      language: map['language'] as String,
      maturityRating: map['maturityRating'] as String,
      trailerUrl: map['trailerUrl'] as String,
    );
  }

  // Helper method to clone Movie with overridden fields if needed
  Movie copyWith({
    int? id,
    String? title,
    String? posterUrl,
    String? backdropUrl,
    double? rating,
    List<String>? genres,
    int? releaseYear,
    String? synopsis,
    String? director,
    String? duration,
    String? language,
    String? maturityRating,
    String? trailerUrl,
  }) {
    return Movie(
      id: id ?? this.id,
      title: title ?? this.title,
      posterUrl: posterUrl ?? this.posterUrl,
      backdropUrl: backdropUrl ?? this.backdropUrl,
      rating: rating ?? this.rating,
      genres: genres ?? this.genres,
      releaseYear: releaseYear ?? this.releaseYear,
      synopsis: synopsis ?? this.synopsis,
      director: director ?? this.director,
      duration: duration ?? this.duration,
      language: language ?? this.language,
      maturityRating: maturityRating ?? this.maturityRating,
      trailerUrl: trailerUrl ?? this.trailerUrl,
    );
  }
}
