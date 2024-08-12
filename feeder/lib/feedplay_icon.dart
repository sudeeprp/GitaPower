import 'package:askys/feedcontent.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'choices_row.dart';

List<Widget> makePlay() {
  final FeedContent feedContent = Get.find();
  return [
    Obx(() => Visibility(
        visible: feedContent.tour.tourStops.isNotEmpty,
        child: FeedPlayIcon(feedContent.tour.state.value, key: const Key('feedplay')))),
    Obx(() => Visibility(
        visible: feedContent.tour.tourStops.isNotEmpty,
        child: const SizedBox(width: choiceSpacing))),
  ];
}

class FeedPlayIcon extends StatelessWidget {
  const FeedPlayIcon(this.state, {super.key});
  final TourState state;

  @override
  Widget build(BuildContext context) {
    final FeedContent feedContent = Get.find();
    return GestureDetector(
      onTap: () async {
        if (feedContent.tour.state.value == TourState.idle) {
          feedContent.play();
        } else if (feedContent.tour.state.value == TourState.playing) {
          feedContent.pause();
        }
      },
      child: Icon(
          switch (state) {
            TourState.idle => Icons.play_arrow,
            TourState.loading => Icons.hourglass_top,
            TourState.playing => Icons.pause,
          },
          size: 48),
    );
  }
}
