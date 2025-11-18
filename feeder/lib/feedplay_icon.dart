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
        child: Obx(
          () => Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.deepPurple,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.deepPurple.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(12),
                child: Icon(
                  switch (feedContent.tour.state.value) {
                    TourState.idle => Icons.play_arrow,
                    TourState.paused => Icons.play_arrow,
                    TourState.loading => Icons.hourglass_top,
                    TourState.playing => Icons.pause,
                  },
                  size: 42,
                  color: Colors.white,
                ),
              )),
        ));
  }
}
