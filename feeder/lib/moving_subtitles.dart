import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:askys/feedcontent.dart';

class Narration {
  Narration(this.line);
  String line;
  GlobalKey key = GlobalKey();
}

class NarrationStops extends GetxController {
  List<Narration> narrations = [];

  @override
  void onInit() {
    final FeedContent feedContent = Get.find();
    narrations = feedContent.tour.tourStops.map((stop) => Narration(stop.line)).toList();
    // TODO: move this listen (and unlisten) out of this unused controller
    feedContent.tour.stopIndex.listen((newIndex) => scrollToIndex(newIndex));
    super.onInit();
  }

  void scrollToIndex(int index) {
    BuildContext? context;
    if (index < narrations.length) {
      context = narrations[index].key.currentContext;
    }
    if (context != null) {
      Scrollable.ensureVisible(context);
    }
  }
}

class MovingSubtitles extends StatelessWidget {
  const MovingSubtitles({super.key});

  @override
  Widget build(BuildContext context) {
    final FeedContent feedContent = Get.find();

    return Obx(() => Visibility(
        visible: (feedContent.tour.state.value == TourState.playing ||
            feedContent.tour.state.value == TourState.paused),
        child: SizedBox(
            height: oneLineHeight() * 3.5,
            child: Container(
              decoration: const BoxDecoration(border: Border(top: BorderSide())),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: SingleChildScrollView(
                  key: const Key('feed/subtitles'),
                  scrollDirection: Axis.vertical,
                  child: Column(children: narrationWidgets(feedContent)),
                ),
              ),
            ))));
  }

  double oneLineHeight() {
    final textPainter = TextPainter(
      text: const TextSpan(text: 'Sample'),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    )..layout();
    return textPainter.height;
  }

  List<Widget> narrationWidgets(FeedContent feedContent) {
    return feedContent.tour.tourStops
        .map((tourStop) => Text(key: tourStop.globalKey, tourStop.line))
        .toList();
  }
}
