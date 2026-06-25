import 'dart:async';
import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class CustomYoutubePlayer extends StatefulWidget {
  final String videoUrl;
  final String title;

  const CustomYoutubePlayer({
    super.key,
    required this.videoUrl,
    required this.title,
  });

  @override
  State<CustomYoutubePlayer> createState() => _CustomYoutubePlayerState();
}

class _CustomYoutubePlayerState extends State<CustomYoutubePlayer> {
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
      final id = YoutubePlayer.convertUrlToId(widget.videoUrl);
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
      if (_controller!.value.isReady && !_isPlayerReady) {
        setState(() {
          _isPlayerReady = true;
          _showTimeoutError = false;
          _loadingTimer?.cancel();
        });
      }
      if (_controller!.value.playerState == PlayerState.playing) {
        setState(() {
          _isPlayerReady = true;
          _showTimeoutError = false;
          _loadingTimer?.cancel();
        });
      }
    }
  }

  @override
  void dispose() {
    _loadingTimer?.cancel();
    _controller?.removeListener(_playerListener);
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError || _controller == null) {
      return Container(
        height: 220,
        color: Colors.black,
        child: const Center(
          child: Text(
            'Format URL YouTube tidak valid',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    if (_showTimeoutError) {
      return Container(
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
      );
    }

    return YoutubePlayer(
      controller: _controller!,
      showVideoProgressIndicator: true,
      progressIndicatorColor: const Color(0xFFE50914),
      progressColors: const ProgressBarColors(
        playedColor: Color(0xFFE50914),
        handleColor: Color(0xFFE50914),
      ),
    );
  }
}
