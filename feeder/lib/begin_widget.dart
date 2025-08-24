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
        child: Container(
          margin: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withValues(alpha: 0.2),
                spreadRadius: 2,
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    const Icon(Icons.play_circle_filled, size: 32, color: Colors.blue),
                    const SizedBox(width: 12),
                    const Text(
                      'Guided Tours',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      height: 40,
                      width: 60,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        image: const DecorationImage(
                          image: AssetImage('images/look-listen.png'),
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Expanded(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: ToursListWidget(),
                ),
              ),
            ],
          ),
        ),
      ),
    ]);
  }
}
