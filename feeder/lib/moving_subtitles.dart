import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:askys/feedcontent.dart';

class MovingSubtitles extends StatelessWidget {
  const MovingSubtitles({super.key});

  @override
  Widget build(BuildContext context) {
    final FeedContent feedContent = Get.find();
    return Obx(() => Visibility(
          visible: feedContent.tour.state.value == TourState.playing,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Text(feedContent.tour.playPosition.value.toString(), key: const Key('feed/subtitles')),
          ),
        ));
  }
}
