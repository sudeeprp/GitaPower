import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:askys/chaptercontent.dart';
import 'package:askys/chapter_headers.dart' as chapters;

class ChaptersWidget extends StatelessWidget {
  const ChaptersWidget({super.key});

  @override
  Widget build(context) {
    final ChaptersTOC toc = Get.find();
    return Obx(() {
      if (toc.chaptersLoaded.value) {
        List<Widget> tocListElements = toc.chapters
            .map((chapter) => _formChapterTitle(chapter.title, Chapter.titleToFilename(chapter.title)))
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
