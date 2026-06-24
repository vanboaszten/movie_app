import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

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
  YoutubePlayerController? _controller;
  bool _hasError = false;
  bool _isPlayerReady = false;
  bool _showTimeoutError = false;
  Timer? _loadingTimer;

  @override
  void initState() {
    super.initState();
    _initPlayer();
    _startTimeoutTimer();
  }

  void _startTimeoutTimer() {
    _loadingTimer = Timer(const Duration(seconds: 8), () {
      if (mounted && !_isPlayerReady) {
        setState(() {
          _showTimeoutError = true;
        });
      }
    });
  }

  void _initPlayer() {
    try {
      final id = YoutubePlayer.convertUrlToId(widget.trailerUrl);
      if (id != null) {
        _controller = YoutubePlayerController(
          initialVideoId: id,
          flags: const YoutubePlayerFlags(
            autoPlay: false,
            mute: false,
            forceHD: false,
            enableCaption: false,
          ),
        )..addListener(_playerListener);
      } else {
        setState(() {
          _hasError = true;
        });
      }
    } catch (e) {
      setState(() {
        _hasError = true;
      });
    }
  }

  void _playerListener() {
    if (mounted && _controller != null) {
      // If player claims it's ready, cancel the loading timeout
      if (_controller!.value.isReady && !_isPlayerReady) {
        setState(() {
          _isPlayerReady = true;
          _showTimeoutError = false;
          _loadingTimer?.cancel();
        });
      }
      
      // If it starts playing, we cancel the loading timeout
      if (_controller!.value.playerState == PlayerState.playing) {
        setState(() {
          _isPlayerReady = true;
          _showTimeoutError = false;
          _loadingTimer?.cancel();
        });
      }
    }
  }

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
  void dispose() {
    _loadingTimer?.cancel();
    _controller?.removeListener(_playerListener);
    // Reset orientation settings when leaving the trailer page
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError || _controller == null) {
      return _buildErrorUI();
    }

    return YoutubePlayerBuilder(
      onExitFullScreen: () {
        // Correct system orientation when exiting fullscreen
        SystemChrome.setPreferredOrientations(DeviceOrientation.values);
      },
      player: YoutubePlayer(
        controller: _controller!,
        showVideoProgressIndicator: true,
        progressIndicatorColor: const Color(0xFFE50914),
        progressColors: const ProgressBarColors(
          playedColor: Color(0xFFE50914),
          handleColor: Color(0xFFE50914),
        ),
        thumbnail: Container(
          color: Colors.black,
          height: 220,
          child: const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE50914)),
            ),
          ),
        ),
      ),
      builder: (context, player) {
        return Scaffold(
          appBar: AppBar(
            title: Text(widget.title),
            backgroundColor: const Color(0xFF1A1A1A),
          ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Embed Player or Timeout UI
                _showTimeoutError
                    ? Container(
                        width: double.infinity,
                        height: 220,
                        color: const Color(0xFF161616),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.wifi_off_rounded, color: Colors.grey, size: 48),
                            const SizedBox(height: 12),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 24.0),
                              child: Text(
                                'Koneksi lambat atau pemutaran diblokir oleh YouTube.',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.grey[400], fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                      )
                    : player,
                
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
                        _showTimeoutError 
                            ? 'Trailer memuat terlalu lama. Silakan gunakan tombol cadangan di bawah untuk membukanya secara eksternal melalui aplikasi YouTube atau peramban web.'
                            : 'Trailer tidak berputar dengan lancar? Silakan gunakan tombol cadangan di bawah untuk membukanya secara eksternal melalui aplikasi YouTube atau peramban web.',
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
      },
    );
  }

  Widget _buildErrorUI() {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: const Color(0xFF1A1A1A),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                size: 72,
                color: Colors.redAccent,
              ),
              const SizedBox(height: 24),
              const Text(
                'Trailer Gagal Diputar',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Aplikasi tidak dapat mendeteksi ID video YouTube yang valid dari URL yang diberikan.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 36),
              
              // Fallback Launcher Button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
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
      ),
    );
  }
}
