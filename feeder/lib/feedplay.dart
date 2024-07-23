import 'package:flutter/material.dart';

class FeedPlay extends StatelessWidget {
  const FeedPlay({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {},
      child: const Icon(Icons.play_arrow, size: 48),
    );
  }
}
