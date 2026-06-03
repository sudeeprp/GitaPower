import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:askys/tours_widget.dart';

Widget titleTextContainer(String title, String about) {
  final titleText = Padding(
    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
    child: Text.rich(TextSpan(children: [
      TextSpan(text: '$title\n', style: const TextStyle(fontSize: 20)),
      TextSpan(text: about),
    ], style: const TextStyle(height: 1.5))),
  );
  return Container(
    alignment: Alignment.centerLeft,
    child: titleText,
  );
}

class BeginWidget extends StatelessWidget {
  const BeginWidget({super.key});

  Decoration beginCardDecoration(BuildContext context) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withValues(alpha: 0.2),
          spreadRadius: 2,
          blurRadius: 1,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  Widget beginBrowse(BuildContext context, {Key? key}) {
    return Container(
        margin: const EdgeInsets.all(4.0),
        decoration: beginCardDecoration(context),
        child: GestureDetector(
            onTap: () => Get.toNamed('/browse'),
            child: Container(
                color: Colors.transparent,
                child: Row(children: [
                  Expanded(key: key, child: titleTextContainer('browse', 'Chapters and Notes')),
                  Expanded(
                      child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                          child: Image.asset('images/begin-chapters.png'))),
                ]))));
  }

  Widget beginGuides(BuildContext context, {Key? key}) {
    return Container(
        margin: const EdgeInsets.all(4.0),
        decoration: beginCardDecoration(context),
        child: Row(
          key: key,
          children: [
            Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                  child: Image.asset('images/look-listen.png'),
                )),
            Expanded(
                flex: 3,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                  child: ToursListWidget(),
                )),
          ],
        ));
  }

  @override
  Widget build(context) {
    return Column(children: [
      Expanded(
        flex: 2,
        child: beginBrowse(context, key: const Key('begin/browse')),
      ),
      Expanded(
        flex: 3,
        child: beginGuides(context, key: const Key('begin/guides')),
      ),
    ]);
  }
}
