import 'package:askys/feedcontent.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'choices_row.dart';

List<Widget> makePlay() {
  final FeedContent feedContent = Get.find();
  return [
    Obx(() => Visibility(
        visible: feedContent.tour.tourStops.isNotEmpty,
        child: const FeedPlay(key: Key('feedplay')))),
    Obx(() => Visibility(
        visible: feedContent.tour.tourStops.isNotEmpty,
        child: const SizedBox(width: choiceSpacing))),
  ];
}

class FeedPlay extends StatelessWidget {
  const FeedPlay({super.key});

  @override
  Widget build(BuildContext context) {
    final FeedContent feedContent = Get.find();
    return GestureDetector(
      onTap: () async {
        feedContent.play();
      },
      child: const Icon(Icons.play_arrow, size: 48),
    );
  }
}
