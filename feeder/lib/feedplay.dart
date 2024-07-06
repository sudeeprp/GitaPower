import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class FeedPlay extends StatelessWidget {
  const FeedPlay({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        FlutterTts flutterTts = FlutterTts();
        await flutterTts.speak('Work for Krishna');
      },
      child: const Icon(Icons.play_arrow),
    );
  }
}
