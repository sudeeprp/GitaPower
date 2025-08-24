import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:askys/tours_widget.dart';

Widget titleTextContainer(String title, String about) {
  final titleText = Padding(
    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
    child: Text.rich(
        key: Key('begin/$title'),
        TextSpan(children: [
          TextSpan(text: '$title\n', style: const TextStyle(fontSize: 20)),
          TextSpan(text: about),
        ], style: const TextStyle(height: 1.5))),
  );
  return Container(
    alignment: Alignment.centerLeft,
    child: titleText,
  );
}

Widget beginItem(String title, String about, Image image, {Key? key}) {
  return Expanded(
      child: GestureDetector(
          onTap: () => Get.toNamed('/$title'),
          child: Row(children: [
            Expanded(key: key, child: titleTextContainer(title, about)),
            Expanded(
                child:
                    Padding(padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8), child: image)),
          ])));
}

class BeginWidget extends StatelessWidget {
  const BeginWidget({super.key});

  @override
  Widget build(context) {
    return Column(children: [
      beginItem('browse', 'Browse topics', Image.asset('images/begin-chapters.png')),
      Expanded(
        key: const Key('begin/guides'),
        child: Row(children: [
          Expanded(flex: 2, child: ToursListWidget()),
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Image.asset('images/look-listen.png', fit: BoxFit.contain),
            ),
          ),
        ]),
      ),
    ]);
  }
}
