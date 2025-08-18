import 'package:askys/notecontent.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:askys/chaptercontent.dart';

class ChaptersWidget extends StatelessWidget {
  const ChaptersWidget({super.key});

  @override
  Widget build(context) {
    final ChaptersTOC chapToc = Get.find();
    final NotesTOC notesToc = Get.find();
    return Obx(() {
      if (chapToc.chaptersLoaded.value && notesToc.notesLoaded.value) {
        return Scaffold(
            body: SingleChildScrollView(
                child: Column(
                    children: chapToc.chapters
                        .map((chapter) =>
                            _formChapterTitle(chapter.title, Chapter.titleToFilename(chapter.title)))
                        .toList())));
      } else {
        return const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [CircularProgressIndicator()],
        );
      }
    });
  }

  Widget _formChapterTitle(String chapterHeading, String mdFilename) {
    return ListTile(
      leading: Image.asset('images/begin-chapters.png', width: 30, height: 30),
      title: Text(chapterHeading),
      subtitle: Column(children: [
        Text('one'),
        Text('two'),
      ]),
      onTap: () => Get.toNamed('/shlokaheaders/$mdFilename'),
    );
  }
}
