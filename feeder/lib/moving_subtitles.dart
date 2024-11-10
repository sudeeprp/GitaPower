import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:askys/feedcontent.dart';

class Narration {
  Narration(this.line);
  String line;
  GlobalKey key = GlobalKey();
}

class MovingSubtitles extends StatefulWidget {
  const MovingSubtitles({super.key});

  @override
  MovingSubtitlesState createState() => MovingSubtitlesState();
}

class MovingSubtitlesState extends State<MovingSubtitles> {
  List<Narration> narrations = [];
  @override
  void initState() {
    final FeedContent feedContent = Get.find();
    narrations = feedContent.tour.tourStops.map((stop) => Narration(stop.line)).toList();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      scrollToIndex(feedContent.tour.stopIndex.value);
    });
    feedContent.tour.stopIndex.listen((newIndex) => scrollToIndex(newIndex));
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final FeedContent feedContent = Get.find();

    return Obx(() => Visibility(
        visible: feedContent.tour.state.value == TourState.playing,
        child: SizedBox(
          height: oneLineHeight() * 3.5,
          child: Container(
            decoration: const BoxDecoration(border: Border(top: BorderSide())),
            child: SingleChildScrollView(
              key: const Key('feed/subtitles'),
              scrollDirection: Axis.vertical,
              child: Column(
                  children: narrations.map((narration) => Text(key: narration.key, narration.line)).toList()),
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
