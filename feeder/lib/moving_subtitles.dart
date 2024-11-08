import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:askys/feedcontent.dart';

class MovingSubtitles extends StatelessWidget {
  const MovingSubtitles({super.key});

  @override
  Widget build(BuildContext context) {
    final FeedContent feedContent = Get.find();
    return Obx(
      () => Visibility(
        visible: feedContent.tour.state.value == TourState.playing,
        child: SingleChildScrollView(
          key: const Key('feed/subtitles'),
          scrollDirection: Axis.horizontal,
          child: Row(children: feedContent.tour.tourStops.map((tourStop) => Text(tourStop.line)).toList()),
        ),
      ),
    );
  }
}
