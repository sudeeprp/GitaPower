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
            child: SingleChildScrollView(
              key: const Key('feed/subtitles'),
              scrollDirection: Axis.vertical,
              child: Column(children: narrationWidgets(feedContent)),
            ),
          ),
        )));
  }

  double oneLineHeight() {
    final textPainter = TextPainter(
      text: const TextSpan(text: 'Sample'),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    )..layout();
    return textPainter.height;
  }

  NarrationStops getNarrationStops(String playableFolder) {
    if (!Get.isRegistered<NarrationStops>(tag: playableFolder)) {
      Get.put(NarrationStops(), tag: playableFolder);
    }
    return Get.find<NarrationStops>(tag: playableFolder);
  }

  List<Widget> narrationWidgets(FeedContent feedContent) {
    final playableFolder = feedContent.tourFolder;
    if (playableFolder != null) {
      final narrationStops = getNarrationStops(playableFolder);
      return narrationStops.narrations.map((narration) => Text(key: narration.key, narration.line)).toList();
    }
    return [];
  }
}
