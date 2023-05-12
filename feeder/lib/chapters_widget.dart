import 'package:askys/choice_selector.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:askys/chaptercontent.dart';
import 'package:askys/shloka_headers.dart' as shlokas;

class ChaptersWidget extends StatelessWidget {
  const ChaptersWidget({super.key});

  @override
  Widget build(context) {
    final ChaptersTOC toc = Get.find();
    return Obx(() {
      final Choices choices = Get.find();
      final codeColor = choices.codeColor.value;
      if (toc.chaptersLoaded.value) {
        List<ExpansionTile> tocListElements = toc.chapters
            .map((chapter) => ExpansionTile(
                  title: _formChapterTitle(chapter.title, Chapter.titleToFilename(chapter.title)),
                  controlAffinity: ListTileControlAffinity.leading,
                  children: chapter.shokas.map((shlokaTitleText) {
                    final mdFilename = Chapter.titleToFilename(shlokaTitleText);
                    return ListTile(
                      title: _formShlokaTitle(shlokaTitleText, mdFilename, codeColor),
                      onTap: () => Get.toNamed('/shloka/$mdFilename'),
                    );
                  }).toList(),
                ))
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

  Widget _formShlokaTitle(String shlokaTitleText, String mdFilename, Color codeColor) {
    final titleWidgets = [Text(shlokaTitleText)];
    final headerText = shlokas.headers[mdFilename];
    if (headerText != null) {
      titleWidgets.add(Text(headerText, style: TextStyle(color: codeColor)));
    }
    return Column(children: titleWidgets);
  }

  Widget _formChapterTitle(String chapterHeading, String mdFilename) {
    final titleWidgets = [
      Align(alignment: Alignment.centerLeft, child: Text(chapterHeading)),
      Expanded(child: Image.asset('images/bothfeet.png', width: 15, height: 15)),
    ];
    final headerText = shlokas.headers[mdFilename];
    if (headerText != null) {
      titleWidgets.add(Align(alignment: Alignment.centerRight, child: Text(headerText)));
    }
    return Row(children: titleWidgets);
  }
}
