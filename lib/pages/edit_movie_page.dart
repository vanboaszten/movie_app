import 'package:flutter/material.dart';
import '../models/movie_model.dart';
import '../services/movie_service.dart';

class EditMoviePage extends StatefulWidget {
  final String userRole;
  final int userId;
  final Movie movie;

  const EditMoviePage({
    super.key,
    required this.userRole,
    required this.userId,
    required this.movie,
  });

  @override
  State<EditMoviePage> createState() => _EditMoviePageState();
}

class _EditMoviePageState extends State<EditMoviePage> {
  final _formKey = GlobalKey<FormState>();
  final _movieService = MovieService();
  bool _isSaving = false;

  late final TextEditingController _titleController;
  late final TextEditingController _posterUrlController;
  late final TextEditingController _backdropUrlController;
  late final TextEditingController _ratingController;
  late final TextEditingController _genresController;
  late final TextEditingController _releaseYearController;
  late final TextEditingController _synopsisController;
  late final TextEditingController _directorController;
  late final TextEditingController _durationController;
  late final TextEditingController _languageController;
  late final TextEditingController _maturityRatingController;
  late final TextEditingController _trailerUrlController;

  @override
  void initState() {
    super.initState();
    if (widget.userRole != 'admin') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Akses ditolak: Hanya administrator yang dapat mengakses halaman ini.',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.of(context).pop();
      });
    }

    // Pre-populate fields with existing movie data
    _titleController = TextEditingController(text: widget.movie.title);
    _posterUrlController = TextEditingController(text: widget.movie.posterUrl);
    _backdropUrlController = TextEditingController(text: widget.movie.backdropUrl);
    _ratingController = TextEditingController(text: widget.movie.rating.toString());
    _genresController = TextEditingController(text: widget.movie.genres.join(', '));
    _releaseYearController = TextEditingController(text: widget.movie.releaseYear.toString());
    _synopsisController = TextEditingController(text: widget.movie.synopsis);
    _directorController = TextEditingController(text: widget.movie.director);
    _durationController = TextEditingController(text: widget.movie.duration);
    _languageController = TextEditingController(text: widget.movie.language);
    _maturityRatingController = TextEditingController(text: widget.movie.maturityRating);
    _trailerUrlController = TextEditingController(text: widget.movie.trailerUrl);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _posterUrlController.dispose();
    _backdropUrlController.dispose();
    _ratingController.dispose();
    _genresController.dispose();
    _releaseYearController.dispose();
    _synopsisController.dispose();
    _directorController.dispose();
    _durationController.dispose();
    _languageController.dispose();
    _maturityRatingController.dispose();
    _trailerUrlController.dispose();
    super.dispose();
  }

  Future<void> _handleUpdate() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
    });

    final genresList = _genresController.text
        .split(',')
        .map((g) => g.trim())
        .where((g) => g.isNotEmpty)
        .toList();

    final updatedMovie = Movie(
      id: widget.movie.id, // Retain the same id
      title: _titleController.text.trim(),
      posterUrl: _posterUrlController.text.trim(),
      backdropUrl: _backdropUrlController.text.trim(),
      rating: double.parse(_ratingController.text.trim()),
      genres: genresList,
      releaseYear: int.parse(_releaseYearController.text.trim()),
      synopsis: _synopsisController.text.trim(),
      director: _directorController.text.trim(),
      duration: _durationController.text.trim(),
      language: _languageController.text.trim(),
      maturityRating: _maturityRatingController.text.trim(),
      trailerUrl: _trailerUrlController.text.trim(),
    );

    try {
      await _movieService.updateMovie(updatedMovie);
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Film "${updatedMovie.title}" berhasil diperbarui!',
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memperbarui: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (widget.userRole != 'admin') {
      return const Scaffold(
        backgroundColor: Color(0xFF0A0A0A),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        title: const Text(
          'Edit Data Film',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF1A1A1A),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTextField(
                controller: _titleController,
                labelText: 'Judul Film',
                hintText: 'Masukkan judul film',
              ),
              _buildTextField(
                controller: _posterUrlController,
                labelText: 'Poster URL',
                hintText: 'https://example.com/poster.jpg',
                keyboardType: TextInputType.url,
              ),
              _buildTextField(
                controller: _backdropUrlController,
                labelText: 'Backdrop / Banner URL',
                hintText: 'https://example.com/backdrop.jpg',
                keyboardType: TextInputType.url,
              ),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _ratingController,
                      labelText: 'Rating',
                      hintText: '8.5',
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) return 'Wajib diisi';
                        final num = double.tryParse(value.trim());
                        if (num == null) return 'Harus angka';
                        if (num < 0 || num > 10) return 'Skala 0 - 10';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTextField(
                      controller: _releaseYearController,
                      labelText: 'Tahun Rilis',
                      hintText: '2024',
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) return 'Wajib diisi';
                        final num = int.tryParse(value.trim());
                        if (num == null) return 'Harus angka';
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              _buildTextField(
                controller: _genresController,
                labelText: 'Genre',
                hintText: 'Action, Drama, Sci-Fi (pisahkan dengan koma)',
              ),
              _buildTextField(
                controller: _directorController,
                labelText: 'Sutradara',
                hintText: 'Masukkan nama sutradara',
              ),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _durationController,
                      labelText: 'Durasi',
                      hintText: '2h 15m',
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTextField(
                      controller: _maturityRatingController,
                      labelText: 'Batas Usia',
                      hintText: 'PG-13 / R',
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _languageController,
                      labelText: 'Bahasa',
                      hintText: 'English / Indonesia',
                    ),
                  ),
                ],
              ),
              _buildTextField(
                controller: _trailerUrlController,
                labelText: 'YouTube Trailer URL',
                hintText: 'https://www.youtube.com/watch?v=...',
                keyboardType: TextInputType.url,
              ),
              _buildTextField(
                controller: _synopsisController,
                labelText: 'Sinopsis',
                hintText: 'Masukkan cerita singkat film...',
                maxLines: 4,
              ),
              const SizedBox(height: 32),
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  onPressed: _isSaving ? null : _handleUpdate,
                  child: _isSaving
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Update Film',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required String hintText,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        style: const TextStyle(color: Colors.white, fontSize: 15),
        decoration: InputDecoration(
          labelText: labelText,
          labelStyle: const TextStyle(color: Colors.grey),
          hintText: hintText,
          hintStyle: const TextStyle(color: Colors.white24, fontSize: 14),
          filled: true,
          fillColor: const Color(0xFF161616),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.white.withOpacity(0.05)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE50914), width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
          ),
        ),
        validator: validator ??
            (value) {
              if (value == null || value.trim().isEmpty) {
                return '$labelText wajib diisi';
              }
              return null;
            },
      ),
    );
  }
}
