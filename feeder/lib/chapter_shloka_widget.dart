import 'package:askys/chaptercontent.dart';
import 'package:askys/screenify.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:askys/choice_selector.dart';
import 'package:askys/shloka_headers.dart' as shlokas;
import 'content_widget.dart';

Widget chapterShlokaScreen(String chapterMdName) {
  final chapterToShloka = Get.find<ChaptersTOC>();
  final chapterTitle = Chapter.filenameToTitle(chapterMdName);
  return Obx(() {
    if (chapterToShloka.chaptersLoaded.value) {
      final chapter = findChapterByTitle(chapterTitle, chapterToShloka.chapters);
      if (chapter.shokas.length == 1) {
        return screenify(buildContentWithNote(Chapter.titleToFilename(chapter.title)));
      } else {
        return screenify(ChapterShlokaWidget(chapter),
            appBar:
                AppBar(leading: Image.asset('images/bothfeet.png'), title: Text(chapter.title)));
      }
    }
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [CircularProgressIndicator()],
    );
  });
}

Chapter findChapterByTitle(String chapterTitle, List<Chapter> chapters) {
  final foundChapter =
      chapters.firstWhere((chapter) => chapter.title == chapterTitle, orElse: () => chapters.first);
  return foundChapter;
}

Widget? formShlokaTitle(String mdFilename, HeadPreference headPreference, BuildContext context) {
  Widget? headerTextView;
  if (headPreference == HeadPreference.shloka) {
    headerTextView = SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: textPadding(Text(
          shlokas.headers[mdFilename]?['shloka'] ?? '',
          style: Theme.of(context).textTheme.labelMedium?.copyWith(fontSize: 20),
        )));
  } else {
    headerTextView = SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: textPadding(Text(
          shlokas.headers[mdFilename]?['meaning'] ?? '',
          style: const TextStyle(fontSize: 18),
        )));
  }
  return Card(
    elevation: 10,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
    color: Theme.of(context).cardColor,
    child: headerTextView,
  );
}

Widget textPadding(Widget textChild) {
  return Padding(padding: const EdgeInsets.only(left: 3), child: textChild);
}

class ChapterShlokaWidget extends StatelessWidget {
  final Chapter chapter;
  const ChapterShlokaWidget(this.chapter, {super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final Choices choices = Get.find();
      final headPreference = choices.headPreference.value;
      final shlokaWidgets = chapter.shokas.map((shlokaTitleText) {
        final mdFilename = chapter.shlokaTitleToFilename(shlokaTitleText);
        return ListTile(
          title: Text(shlokaTitleText),
          subtitle: formShlokaTitle(mdFilename, headPreference, context),
          minVerticalPadding: 16,
          contentPadding: const EdgeInsets.only(left: 6),
          onTap: () => Get.toNamed('/shloka/$mdFilename'),
        );
      }).toList();
      return ListView(children: shlokaWidgets);
    });
  }
}
