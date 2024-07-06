import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

const asysWebApp =
    'https://script.google.com/macros/s/AKfycbxte9Euu8Mc3pXOjTWMaZYqJpfXcPPl2F-b_jAI8S8L1v4B35Zn9V_-XnlaV4Vf3x2O/exec';

class FeedPlay extends StatelessWidget {
  const FeedPlay({super.key});

  // TODO: Take the docId from the url
  final String? docId = '11No58DpoVARwL-6qsq9jaPcl1ph29hTO7g_EeDw6rB8';

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final dio = Dio();
        final narration = await dio.get(asysWebApp, queryParameters: {'id': docId});

        FlutterTts flutterTts = FlutterTts();
        await flutterTts.speak(narration.data.toString());
      },
      child: const Icon(Icons.play_arrow),
    );
  }
}
