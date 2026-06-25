import 'package:flutter/material.dart';
import '../models/movie_model.dart';
import '../widgets/movie_card.dart';
import 'login_page.dart';
import 'favorite_page.dart';
import 'profile_page.dart';
import '../services/movie_service.dart';
import 'admin_movie_management_page.dart';

class HomePage extends StatefulWidget {
  final int userId;
  final String userName;
  final String userUsername;
  final String userRole;

  const HomePage({
    super.key,
    required this.userId,
    required this.userName,
    required this.userUsername,
    required this.userRole,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _searchController = TextEditingController();
  final _movieService = MovieService();
  String _searchQuery = '';
  String _selectedGenre = 'All';
  List<Movie> _allMovies = [];
  bool _isLoading = true;

  final List<String> _genres = [
    'All',
    'Action',
    'Drama',
    'Horror',
    'Comedy',
    'Romance',
    'Animation',
    'Sci-Fi',
    'Adventure',
  ];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _loadMovies();
  }

  Future<void> _loadMovies() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final movies = await _movieService.getAllMovies();
      if (mounted) {
        setState(() {
          _allMovies = movies;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text;
    });
  }

  List<Movie> get _filteredMovies {
    return _allMovies.where((movie) {
      // 1. Filter by Search Query (Title match, non-case-sensitive)
      final matchesSearch = movie.title.toLowerCase().contains(_searchQuery.toLowerCase());

      // 2. Filter by Genre
      bool matchesGenre = false;
      if (_selectedGenre == 'All') {
        matchesGenre = true;
      } else {
        // Map "Sci-Fi" filter option to "Science Fiction" in dummy data
        final targetGenre = _selectedGenre == 'Sci-Fi' ? 'Science Fiction' : _selectedGenre;
        matchesGenre = movie.genres.any((g) => g.toLowerCase() == targetGenre.toLowerCase());
      }

      return matchesSearch && matchesGenre;
    }).toList();
  }

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Keluar'),
        content: const Text('Apakah Anda yakin ingin keluar dari aplikasi?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal', style: TextStyle(color: Colors.white60)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
              );
            },
            child: Text('Keluar', style: TextStyle(color: Theme.of(context).primaryColor)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final movies = _filteredMovies;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A1A),
        elevation: 0,
        title: const Text(
          'Movie App',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite_rounded, color: Color(0xFFFF9F0A)),
            tooltip: 'Favorites',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FavoritePage(userId: widget.userId),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.person_rounded, color: Colors.blueAccent),
            tooltip: 'Profile',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProfilePage(
                    userId: widget.userId,
                    userName: widget.userName,
                    userUsername: widget.userUsername,
                    userRole: widget.userRole,
                  ),
                ),
              );
            },
          ),
          if (widget.userRole == 'admin')
            IconButton(
              icon: const Icon(Icons.movie_creation_rounded, color: Colors.greenAccent),
              tooltip: 'Manage Movies',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AdminMovieManagementPage(
                      userRole: widget.userRole,
                      userId: widget.userId,
                    ),
                  ),
                ).then((_) {
                  _loadMovies();
                });
              },
            ),
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
            tooltip: 'Logout',
            onPressed: _handleLogout,
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Greeting Banner
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            color: const Color(0xFF1A1A1A),
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Selamat datang kembali,',
                  style: TextStyle(color: Colors.grey[500], fontSize: 13),
                ),
                Text(
                  widget.userName,
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search movies',
                prefixIcon: const Icon(Icons.search_rounded, color: Colors.grey),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded, color: Colors.grey),
                        onPressed: () => _searchController.clear(),
                      )
                    : null,
                filled: true,
                fillColor: const Color(0xFF161616),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),

          // Genre Selector Header
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'Genres',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Horizontal Genre Scroll list
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              itemCount: _genres.length,
              itemBuilder: (context, index) {
                final genre = _genres[index];
                final isSelected = _selectedGenre == genre;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: ChoiceChip(
                    label: Text(genre),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _selectedGenre = genre;
                        });
                      }
                    },
                    selectedColor: Theme.of(context).primaryColor,
                    backgroundColor: const Color(0xFF161616),
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.white70,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    side: BorderSide.none,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    showCheckmark: false,
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),

          // Popular Movies header
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'Popular Movies',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Movie Grid/List
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE50914)),
                    ),
                  )
                : movies.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.search_off_rounded, size: 64, color: Colors.grey[700]),
                            const SizedBox(height: 16),
                            Text(
                              'Film tidak ditemukan',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[400],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Coba gunakan kata kunci atau genre lain',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        itemCount: movies.length,
                        itemBuilder: (context, index) {
                          return MovieCard(
                            movie: movies[index],
                            userId: widget.userId,
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
