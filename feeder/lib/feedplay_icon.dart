import 'package:askys/feedcontent.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FeedPlayIcon extends StatelessWidget {
  const FeedPlayIcon({super.key});

  @override
  Widget build(BuildContext context) {
    final FeedContent feedContent = Get.find();
    return GestureDetector(
      onTap: () async {
        if (feedContent.tour.state.value == TourState.idle) {
          feedContent.play();
        } else if (feedContent.tour.state.value == TourState.paused) {
          feedContent.resume();
        } else if (feedContent.tour.state.value == TourState.playing) {
          feedContent.pause();
        }
      },
      child: Obx(() => Icon(
          switch (feedContent.tour.state.value) {
            TourState.idle => Icons.play_arrow,
            TourState.paused => Icons.play_arrow,
            TourState.loading => Icons.hourglass_top,
            TourState.playing => Icons.pause,
          },
          size: 48)),
    );
  }
}
