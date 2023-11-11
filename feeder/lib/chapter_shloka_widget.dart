import 'package:askys/chaptercontent.dart';
import 'package:askys/screenify.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:askys/choice_selector.dart';
import 'package:askys/shloka_headers.dart' as shlokas;

Widget chapterShlokaScreen(String chapterMdName) {
  final chapterToShloka = Get.find<ChaptersTOC>();
  final chapterTitle = Chapter.filenameToTitle(chapterMdName);
  return Obx(() {
    if (chapterToShloka.chaptersLoaded.value) {
      final chapter = findChapterByTitle(chapterTitle, chapterToShloka.chapters);
      return screenify(ChapterShlokaWidget(chapter),
          appBar: AppBar(leading: Image.asset('images/bothfeet.png'), title: Text(chapter.title)));
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

Widget _formShlokaTitle(
    String shlokaTitleText, String mdFilename, HeadPreference headPreference, Color codeColor) {
  final titleWidgets = [Text(shlokaTitleText)];
  String? headerText;
  if (headPreference == HeadPreference.shloka) {
    headerText = shlokas.headers[mdFilename]?['shloka'];
  } else {
    headerText = shlokas.headers[mdFilename]?['meaning'];
  }
  if (headerText != null) {
    titleWidgets.add(Text(headerText, style: TextStyle(color: codeColor)));
  }
  return Column(children: titleWidgets);
}

class ChapterShlokaWidget extends StatelessWidget {
  final Chapter chapter;
  const ChapterShlokaWidget(this.chapter, {super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final Choices choices = Get.find();
      final codeColor = choices.codeColor.value;
      final headPreference = choices.headPreference.value;
      final shlokaWidgets = chapter.shokas.map((shlokaTitleText) {
        final mdFilename = chapter.shlokaTitleToFilename(shlokaTitleText);
        return ListTile(
          title: _formShlokaTitle(shlokaTitleText, mdFilename, headPreference, codeColor),
          onTap: () => Get.toNamed('/shloka/$mdFilename'),
        );
      }).toList();
      return ListView(children: shlokaWidgets);
    });
  }
}
