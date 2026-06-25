import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../widgets/youtube_player_bridge.dart';

class TrailerPage extends StatefulWidget {
  final String title;
  final String trailerUrl;

  const TrailerPage({
    super.key,
    required this.title,
    required this.trailerUrl,
  });

  @override
  State<TrailerPage> createState() => _TrailerPageState();
}

class _TrailerPageState extends State<TrailerPage> {
  Future<void> _launchYoutubeUrl() async {
    final uri = Uri.parse(widget.trailerUrl);
    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal membuka URL: ${widget.trailerUrl}'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal membuka URL: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: const Color(0xFF1A1A1A),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomYoutubePlayer(
              videoUrl: widget.trailerUrl,
              title: widget.title,
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tag
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'TRAILER',
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.1,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  
                  // Movie Title
                  Text(
                    widget.title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 28),
                  
                  const Divider(color: Colors.white10),
                  const SizedBox(height: 16),
                  
                  // Description message
                  Text(
                    'Trailer tidak berputar dengan lancar? Silakan gunakan tombol cadangan di bawah untuk membukanya secara eksternal melalui aplikasi YouTube atau peramban web.',
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 13,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Fallback Launcher Button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Theme.of(context).primaryColor),
                        foregroundColor: Theme.of(context).primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.open_in_new_rounded),
                      label: const Text(
                        'Open in YouTube',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      onPressed: _launchYoutubeUrl,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
