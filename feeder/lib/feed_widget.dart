import 'package:askys/chaptercontent.dart';
import 'package:askys/choice_selector.dart';
import 'package:askys/choices_row.dart';
import 'package:askys/content_widget.dart';
import 'package:askys/matter_forinline.dart';
import 'package:askys/prompt_widget.dart';
import 'package:askys/screenify.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'feedcontent.dart';

bool isSectionInFeed(SectionType sectionType) {
  return sectionType == SectionType.shlokaSA ||
      sectionType == SectionType.shlokaSAHK ||
      sectionType == SectionType.meaning;
}

Widget openerLine(BuildContext context,
    {required String chapterNumber, required String openerQ, required String shortTitle}) {
  return Row(
    children: [
      Padding(
          padding: EdgeInsets.symmetric(horizontal: 4),
          child: Image.asset(
            'images/Chapter_$chapterNumber.png',
            width: 28,
            height: 28,
          )),
      Expanded(
        flex: 4,
        child: Text(openerQ,
            style: styleFor(context, 'note')?.copyWith(fontStyle: FontStyle.italic),
            softWrap: true,
            maxLines: 2),
      ),
      Expanded(
        flex: 1,
        child: Padding(
            padding: EdgeInsets.only(right: 4),
            child: Text(
              shortTitle,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.right,
            )),
      )
    ],
  );
}

class ShlokaInsideFeed extends StatelessWidget {
  ShlokaInsideFeed({required this.filename, required this.count, super.key});
  final FeedContent feedContent = Get.find();
  final String filename;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return InkWell(
          child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        elevation: 8,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(children: [
            // Decorative saffron vertical bar
            Container(
                width: 12,
                height: 48,
                decoration:
                    BoxDecoration(color: const Color(0xFFEE9A4D), borderRadius: BorderRadius.circular(6))),
            const SizedBox(width: 4),
            Expanded(
                child: Column(
              children: [
                openerLine(context,
                    chapterNumber: Chapter.filenameToChapterNumber(filename),
                    openerQ: feedContent.openerQs[count - 1].value,
                    shortTitle: Chapter.filenameToShortTitle(filename)),
                buildContentFeed(filename, isSectionVisible: isSectionInFeed, key: Key('feed/$count')),
              ],
            )),
          ]),
        ),
      ));
    });
  }
}

class FeedWidget extends StatelessWidget {
  const FeedWidget({super.key});
  @override
  Widget build(BuildContext context) {
    final FeedContent feedContent = Get.find();
    return Obx(() {
      if (feedContent.threeShlokas.length == 3) {
        int count = 1;
        return SingleChildScrollView(
            child: Column(
                children: feedContent.threeShlokas
                    .map((filename) => ShlokaInsideFeed(filename: filename, count: count++) as Widget)
                    .toList()));
      } else {
        return const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [CircularProgressIndicator()],
        );
      }
    });
  }
}

Widget feedScreen() {
  return screenify(FeedWidget(),
      appBar: AppBar(title: Text("Explore"), actions: [const PromptWidget()]),
      choicesRow: choicesRow([SizedBox(width: choiceSpacing), widgetToHome()],
          [PersonalizeIcon(), SizedBox(width: choiceSpacing)]));
}
