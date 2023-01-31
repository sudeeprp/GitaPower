import 'package:flutter/material.dart';
import 'package:get/get.dart';

Widget beginItem(String title, String about, Image image, {Key? key}) {
  const itemPadding = EdgeInsets.symmetric(vertical: 8, horizontal: 4);
  final titleText = Padding(
    padding: itemPadding,
    child: Text.rich(
        key: Key('begin/$title'),
        TextSpan(children: [
          TextSpan(text: '$title\n', style: const TextStyle(fontSize: 20)),
          TextSpan(text: about),
        ], style: const TextStyle(height: 1.5))),
  );
  final textContainer = Container(
    alignment: Alignment.centerLeft,
    child: titleText,
  );
  return Expanded(
      child: GestureDetector(
          onTap: () => Get.toNamed('/$title'),
          child: Row(children: [
            Expanded(key: key, child: textContainer),
            Expanded(child: Padding(padding: itemPadding, child: image)),
          ])));
}

class BeginWidget extends StatelessWidget {
  const BeginWidget({super.key});

  @override
  Widget build(context) {
    return Column(children: [
      beginItem('notes', 'Follow the conversation by themes',
          Image.asset('images/begin-notes.png')),
      beginItem('feed', 'Explore connections across chapters',
          Image.asset('images/begin-feed3.png')),
      beginItem('chapters', 'Start chapter by chapter',
          Image.asset('images/begin-chapters.png')),
    ]);
  }
}
