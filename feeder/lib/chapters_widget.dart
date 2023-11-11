import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:askys/chaptercontent.dart';
import 'package:askys/chapter_headers.dart' as chapters;

// << Move this to chapter_shloka_widget?
// import 'package:askys/choice_selector.dart';
// import 'package:askys/shloka_headers.dart' as shlokas;

class ChaptersWidget extends StatelessWidget {
  const ChaptersWidget({super.key});

  @override
  Widget build(context) {
    final ChaptersTOC toc = Get.find();
    return Obx(() {
      // << Move this to chapter_shloka_widget?
      // final Choices choices = Get.find();
      // final codeColor = choices.codeColor.value;
      // final headPreference = choices.headPreference.value;
      if (toc.chaptersLoaded.value) {
        List<Widget> tocListElements = toc.chapters
            .map((chapter) =>
                _formChapterTitle(chapter.title, Chapter.titleToFilename(chapter.title)))
            .toList();
        return Scaffold(body: ListView(children: tocListElements));
      } else {
        return const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [CircularProgressIndicator()],
        );
      }
    });
  }

  // << Move this to chapter_shloka_widget?
  // Widget _formShlokaTitle(
  //     String shlokaTitleText, String mdFilename, HeadPreference headPreference, Color codeColor) {
  //   final titleWidgets = [Text(shlokaTitleText)];
  //   String? headerText;
  //   if (headPreference == HeadPreference.shloka) {
  //     headerText = shlokas.headers[mdFilename]?['shloka'];
  //   } else {
  //     headerText = shlokas.headers[mdFilename]?['meaning'];
  //   }
  //   if (headerText != null) {
  //     titleWidgets.add(Text(headerText, style: TextStyle(color: codeColor)));
  //   }
  //   return Column(children: titleWidgets);
  // }

  Widget _formChapterTitle(String chapterHeading, String mdFilename) {
    final headerText = chapters.headers[mdFilename] ?? '';
    return ListTile(
      leading: Image.asset('images/bothfeet.png', width: 30, height: 30),
      title: Text(chapterHeading),
      subtitle: Text(headerText),
      onTap: () => Get.toNamed('/shlokaheaders/$mdFilename'),
    );
  }
}
