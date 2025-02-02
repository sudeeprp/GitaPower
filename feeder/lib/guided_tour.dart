import 'package:askys/choice_selector.dart';
import 'package:askys/choices_row.dart';
import 'package:askys/content_widget.dart';
import 'package:askys/feedcontent.dart';
import 'package:askys/feedplay_icon.dart';
import 'package:askys/moving_subtitles.dart';
import 'package:askys/screenify.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

void guidedTour() {
  Get.toNamed('/guided');
}

Widget guidedTourScreen() {
  final playable = Playable('Bring the best in you', '/gitapower/feed/8-25.14-1.18-1.bring_the_best_in_you',
      'bring_the_best_in_you');
  curateToFeed(playable);
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
      if (constraints.maxWidth > constraints.maxHeight) {
        return landscapeLayout(constraints);
      } else {
        return portraitLayout(constraints);
      }
    });
  }

  Widget landscapeLayout(BoxConstraints constraints) {
    return Column(children: [
      Text('Landscape (${constraints.maxWidth} x ${constraints.maxHeight})'),
      MovingSubtitles(),
    ]);
  }

  Widget portraitLayout(BoxConstraints constraints) {
    return Column(children: [
      Text('Portrait (${constraints.maxWidth} x ${constraints.maxHeight})'),
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
    final FeedContent feedContent = Get.find();
    return Row(children: [
      Text('Follow Along'),
      FeedPlayIcon(feedContent.tour.state.value, key: const Key('guided/feedplay')),
    ]);
  }
}

class ShlokaSet extends StatelessWidget {
  const ShlokaSet({super.key});

  @override
  Widget build(BuildContext context) {
    final FeedContent feedContent = Get.find();
    return Obx(() => Expanded(child: CarouselView.weighted(
      flexWeights: [1, 7, 1],
      children: feedContent.tour.tourStops.where((s)=> s.link != null).map((s)=> oneShloka(s.link!)).toList(),
    )));
  }

  Widget oneShloka(String link, {Key? oneShlokaKey}) {
    final parts = link.split('/');
    final mdFilename = parts[0];
    final initialAnchor = parts.length > 1 ? parts[1] : null;
    return LayoutBuilder(builder: (context, constraints) {
      if (constraints.maxWidth > 300) {
        return buildContent(mdFilename,
          initialAnchor: initialAnchor,
          onTap: () => Get.toNamed('/shloka/$mdFilename'),
          key: oneShlokaKey);
      } else {
        return Text(link);
      }
    });
  }
}
