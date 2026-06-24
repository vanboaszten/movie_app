import 'package:flutter/material.dart';
import '../models/movie_model.dart';
import '../widgets/info_row.dart';
import 'trailer_page.dart';
import '../services/favorite_service.dart';

class DetailMoviePage extends StatefulWidget {
  final Movie movie;
  final int userId;

  const DetailMoviePage({super.key, required this.movie, required this.userId});

  @override
  State<DetailMoviePage> createState() => _DetailMoviePageState();
}

class _DetailMoviePageState extends State<DetailMoviePage> {
  final _favoriteService = FavoriteService();
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _checkFavoriteStatus();
  }

  Future<void> _checkFavoriteStatus() async {
    final isFav = await _favoriteService.isFavorite(widget.userId, widget.movie.id);
    if (mounted) {
      setState(() {
        _isFavorite = isFav;
      });
    }
  }

  Future<void> _toggleFavorite() async {
    await _favoriteService.toggleFavorite(widget.userId, widget.movie);
    final nextStatus = !_isFavorite;
    
    if (mounted) {
      setState(() {
        _isFavorite = nextStatus;
      });

      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            nextStatus
                ? '${widget.movie.title} ditambahkan ke Favorit'
                : '${widget.movie.title} dihapus dari Favorit',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: nextStatus ? Theme.of(context).primaryColor : Colors.grey[800],
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final movie = widget.movie;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Backdrop Image Header
            Stack(
              children: [
                // Backdrop Image
                Image.network(
                  movie.backdropUrl,
                  width: double.infinity,
                  height: 250,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: double.infinity,
                      height: 250,
                      color: const Color(0xFF2A2A2A),
                      child: const Center(
                        child: Icon(
                          Icons.broken_image_rounded,
                          size: 64,
                          color: Colors.grey,
                        ),
                      ),
                    );
                  },
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      width: double.infinity,
                      height: 250,
                      color: const Color(0xFF161616),
                      child: const Center(
                        child: SizedBox(
                          width: 30,
                          height: 30,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE50914)),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                // Gradient Overlay
                Positioned.fill(
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black45,
                          Colors.transparent,
                          Color(0xFF121212),
                        ],
                      ),
                    ),
                  ),
                ),
                // Custom Navigation Back Button
                Positioned(
                  top: 40,
                  left: 16,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ),
                // Watch Trailer Play button overlay
                Positioned(
                  bottom: 16,
                  right: 16,
                  child: FloatingActionButton.extended(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TrailerPage(
                            title: movie.title,
                            trailerUrl: movie.trailerUrl,
                          ),
                        ),
                      );
                    },
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.black,
                    icon: const Icon(Icons.play_arrow_rounded),
                    label: const Text(
                      'Watch Trailer',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),

            // Content Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and Favorite Button
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          movie.title,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Favorite Toggle Button
                      IconButton(
                        icon: Icon(
                          _isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                          color: _isFavorite ? Colors.redAccent : Colors.white,
                          size: 32,
                        ),
                        onPressed: _toggleFavorite,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Rating Row
                  Row(
                    children: [
                      const Icon(Icons.star_rounded, color: Color(0xFFFFD60A), size: 24),
                      const SizedBox(width: 6),
                      Text(
                        '${movie.rating} / 10',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Genre Chips
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: movie.genres.map((genre) {
                      return Chip(
                        label: Text(genre),
                        labelStyle: const TextStyle(fontSize: 12, color: Colors.white70),
                        backgroundColor: const Color(0xFF161616),
                        side: BorderSide(color: Colors.grey.withOpacity(0.2)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),

                  // Synopsis
                  const Text(
                    'Synopsis',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    movie.synopsis,
                    style: TextStyle(
                      color: Colors.grey[300],
                      fontSize: 14,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Movie Metadata Table (using InfoRow)
                  const Text(
                    'Movie Info',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF161616),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.withOpacity(0.1)),
                    ),
                    child: Column(
                      children: [
                        InfoRow(label: 'Director', value: movie.director),
                        const Divider(color: Colors.white10),
                        InfoRow(label: 'Duration', value: movie.duration),
                        const Divider(color: Colors.white10),
                        InfoRow(label: 'Language', value: movie.language),
                        const Divider(color: Colors.white10),
                        InfoRow(label: 'Maturity Rating', value: movie.maturityRating),
                        const Divider(color: Colors.white10),
                        InfoRow(label: 'Release Year', value: movie.releaseYear.toString()),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
