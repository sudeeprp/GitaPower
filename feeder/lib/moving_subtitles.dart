import 'package:askys/guided_tour.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:askys/feedcontent.dart';

class MovingSubtitles extends StatelessWidget {
  const MovingSubtitles({super.key});

  @override
  Widget build(BuildContext context) {
    final FeedContent feedContent = Get.find();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      syncWithTheTour(feedContent);
    });
    return PopScope(
        onPopInvokedWithResult: resetTour,
        child: Obx(
          () => Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            color: Colors.deepPurple.shade50,
            child: SizedBox(
              height: oneLineHeight() * 5.5,
              child: narrationWidgets(feedContent),
            ),
          ),
        ));
  }

  double oneLineHeight() {
    final textPainter = TextPainter(
      text: const TextSpan(text: 'Sample'),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    )..layout();
    return textPainter.height;
  }

  Widget narrationWidgets(FeedContent feedContent) {
    GuidedTourController guidedTourController = Get.find();
    return PageView.builder(
      key: const Key('feed/narration'),
      controller: guidedTourController.followTurner,
      itemCount: feedContent.tour.tourStops.length,
      itemBuilder: (context, index) {
        final tourStop = feedContent.tour.tourStops[index];
        return Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: Text(
                  tourStop.line,
                  style: const TextStyle(color: Colors.black54),
                  textAlign: TextAlign.center,
                  textScaler: computeScaleToFit(tourStop.line, context),
                ),
              ),
            ));
      },
    );
  }

  TextScaler? computeScaleToFit(String textInWidget, BuildContext context) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: textInWidget,
        style: const TextStyle(color: Colors.black54),
      ),
      maxLines: 3,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: MediaQuery.of(context).size.width - 64);
    return textPainter.didExceedMaxLines ? TextScaler.linear(0.8) : null;
  }

  void syncWithTheTour(FeedContent feedContent) {
    GuidedTourController guidedTourController = Get.find();
    final followTurner = guidedTourController.followTurner;
    void scrollTo(int index) {
      if (followTurner.hasClients && index < feedContent.tour.tourStops.length) {
        followTurner.animateToPage(index,
            duration: const Duration(milliseconds: 250), curve: Curves.easeInOut);
      }
    }

    scrollTo(feedContent.tour.stopIndex.value);
    feedContent.tour.stopIndex.listen((newIndex) => scrollTo(newIndex));
  }

  void resetTour(popped, _) async {
    if (popped) {
      final FeedContent feedContent = Get.find();
      await feedContent.audioPlayer.stop();
      await feedContent.audioPlayer.seek(Duration(milliseconds: 0), index: 0);
      feedContent.tour.stopIndex.value = 0;
      feedContent.tour.state.value = TourState.idle;
    }
  }
}
