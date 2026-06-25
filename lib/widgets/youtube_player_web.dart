// ignore_for_file: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:ui_web' as ui_web;
import 'package:flutter/material.dart';

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
  late String _viewId;
  bool _isValid = false;

  @override
  void initState() {
    super.initState();
    _initPlayer();
  }

  void _initPlayer() {
    final videoId = _getYoutubeId(widget.videoUrl);
    if (videoId.isNotEmpty) {
      _viewId = 'youtube-iframe-$videoId';
      ui_web.platformViewRegistry.registerViewFactory(
        _viewId,
        (int viewId) => html.IFrameElement()
          ..src = 'https://www.youtube.com/embed/$videoId'
          ..style.border = 'none'
          ..style.width = '100%'
          ..style.height = '100%'
          ..allow = 'accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture'
          ..allowFullscreen = true,
      );
      _isValid = true;
    }
  }

  String _getYoutubeId(String url) {
    try {
      final uri = Uri.parse(url);
      if (uri.host.contains('youtube.com')) {
        return uri.queryParameters['v'] ?? '';
      } else if (uri.host.contains('youtu.be')) {
        return uri.pathSegments.isNotEmpty ? uri.pathSegments.first : '';
      }
    } catch (_) {}
    return '';
  }

  @override
  Widget build(BuildContext context) {
    if (!_isValid) {
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

    return Container(
      height: 300,
      width: double.infinity,
      color: Colors.black,
      child: HtmlElementView(viewType: _viewId),
    );
  }
}
