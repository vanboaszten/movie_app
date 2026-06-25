import 'package:flutter/material.dart';

class CustomYoutubePlayer extends StatelessWidget {
  final String videoUrl;
  final String title;

  const CustomYoutubePlayer({
    super.key,
    required this.videoUrl,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}
