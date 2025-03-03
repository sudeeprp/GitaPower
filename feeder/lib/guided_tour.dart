import 'package:askys/choice_selector.dart';
import 'package:askys/choices_row.dart';
import 'package:askys/content_widget.dart';
import 'package:askys/feedcontent.dart';
import 'package:askys/feedplay_icon.dart';
import 'package:askys/moving_subtitles.dart';
import 'package:askys/screenify.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// TODO: Why can't this replace the Tour class?
class GuidedTourController extends GetxController {
  PageController pageTurner = PageController();
  final mdLinksOfPages = <String>[].obs;
  void moveTo(TourState state, int stopIndex) {
    if (state == TourState.playing) {
      if (pageTurner.hasClients && mdLinksOfPages.isNotEmpty) {
        final Tour tour = Get.find<FeedContent>().tour;
        if (tour.tourStops[stopIndex].link != null) {
          final pageIndex = mdLinksOfPages.indexWhere((link) => link == tour.tourStops[stopIndex].link) +
              1; // add 1 for the cover
          pageTurner.animateToPage(pageIndex,
              duration: const Duration(milliseconds: 250), curve: Curves.easeInOut);
        }
      }
    }
  }

  @override
  void onInit() {
    super.onInit();
    initTour();
  }

  void initTour() {
    final Tour tour = Get.find<FeedContent>().tour;
    tour.state.listen((_) => moveTo(tour.state.value, tour.stopIndex.value));
    tour.stopIndex.listen((_) => moveTo(tour.state.value, tour.stopIndex.value));
    void fillLinksOfPages(_) {
      mdLinksOfPages.value = tour.tourStops.where((s) => s.link != null).map((s) => s.link!).toList();
    }

    fillLinksOfPages(true);
    tour.tourStops.listen(fillLinksOfPages);
  }
}

Widget guidedTourScreen(String tourFolder) {
  Get.find<GuidedTourController>().initTour();
  return Obx(() {
    final PlayablesTOC playablesTOC = Get.find();
    final nullPlayable = Playable('', '', '');
    final playable =
        playablesTOC.playables.firstWhere((p) => p.tourFolder == tourFolder, orElse: () => nullPlayable);
    if (playable != nullPlayable) {
      return screenify(GuidedTourWidget(playable),
          appBar: AppBar(
              title: Column(children: [
            const Text(
              'Guided Tour (beta)',
              textScaler: TextScaler.linear(0.75),
            ),
            Text(playable.title),
          ])),
          choicesRow: choicesRow([], const [PersonalizeIcon(), SizedBox(width: choiceSpacing)]));
    } else {
      return screenify(const Text('Loading tour...'));
    }
  });
}

void curateToFeed(Playable playable) {
  final FeedContent feedContent = Get.find();
  final uriComponents = playable.url.split('/');
  final filesWithoutExtn = uriComponents.last.split('.').sublist(0, 3);
  final mdsInFeed = filesWithoutExtn.map((shlokaFile) => '$shlokaFile.md').toList();
  feedContent.setCuratedShlokaMDs(mdsInFeed, playableFolder: playable.tourFolder);
}

class GuidedTourWidget extends StatelessWidget {
  const GuidedTourWidget(this.playable, {super.key});
  final Playable playable;

  @override
  Widget build(context) {
    // Choices:
    //   - ResponsiveGridList
    //   - GridView with SliverGridDelegateWithMaxCrossAxisExtent
    //   - Use a Wrap Widget
    //   - combine LayoutBuilder with either GridView or Wrap
    return LayoutBuilder(builder: (context, constraints) {
      return portraitLayout(constraints);
      // TODO: Build landscape layout
      // if (constraints.maxWidth > constraints.maxHeight) {
      //   return landscapeLayout(constraints);
      // } else {
      //   return portraitLayout(constraints);
      // }
    });
  }

  // Widget landscapeLayout(BoxConstraints constraints) {
  //   return Column(children: [
  //     Text('Landscape (${constraints.maxWidth} x ${constraints.maxHeight})'),
  //     MovingSubtitles(),
  //   ]);
  // }

  Widget portraitLayout(BoxConstraints constraints) {
    return Column(children: [
      // Text('Portrait (${constraints.maxWidth} x ${constraints.maxHeight})'),
      FollowAlongWidget(),
      MovingSubtitles(),
      ShlokaSet(),
    ]);
  }
}

class FollowAlongWidget extends StatelessWidget {
  const FollowAlongWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Text('Follow Along'),
      FeedPlayIcon(key: const Key('guided/feedplay')),
    ]);
  }
}

class ShlokaSet extends StatelessWidget {
  const ShlokaSet({super.key});

  @override
  Widget build(BuildContext context) {
    final GuidedTourController guidedTourController = Get.find();
    final mdLinksOfPages = guidedTourController.mdLinksOfPages;
    return Obx(() => Expanded(
            child: PageView(
          controller: guidedTourController.pageTurner,
          children: [tourCover(mdLinksOfPages)] + mdLinksOfPages.map(oneShloka).toList(),
        )));
  }

  Widget oneShloka(String link, {Key? oneShlokaKey}) {
    final parts = link.split('/');
    final mdFilename = parts[0];
    final initialAnchor = parts.length > 1 ? parts[1] : null;
    return buildContent(mdFilename,
        initialAnchor: initialAnchor, onTap: () => Get.toNamed('/shloka/$mdFilename'), key: oneShlokaKey);
    // return LayoutBuilder(builder: (context, constraints) {
    //   if (constraints.maxWidth > 300) {
    //     return buildContent(mdFilename,
    //         initialAnchor: initialAnchor, onTap: () => Get.toNamed('/shloka/$mdFilename'), key: oneShlokaKey);
    //   } else {
    //     return Text(link);
    //   }
    // });
  }

  Widget tourCover(List<String> stopNames) {
    return ListView(children: stopNames.map((md) => Text(md)).toList());
  }
}
