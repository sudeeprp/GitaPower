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
      if (toc.chaptersLoaded.value) {
        List<ExpansionTile> tocListElements = toc.chapters
            .map((chapter) => ExpansionTile(
                  title: Text(chapter.title),
                  controlAffinity: ListTileControlAffinity.leading,
                  children: chapter.shokas.map((shlokaTitleText) {
                    final mdFilename = Chapter.titleToFilename(shlokaTitleText);
                    return ListTile(
                      title: _formShlokaTitle(shlokaTitleText, mdFilename),
                      onTap: () => Get.toNamed('/shloka/$mdFilename'),
                    );
                  }).toList(),
                ))
            .toList();
        return Scaffold(body: ListView(children: tocListElements));
      } else {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [CircularProgressIndicator()],
        );
      }
    });
  }

  Widget _formShlokaTitle(String shlokaTitleText, String mdFilename) {
    final titleWidgets = [Text(shlokaTitleText)];
    final headerText = shlokas.headers[mdFilename];
    if (headerText != null) {
      titleWidgets.add(Text(headerText, style: TextStyle(color: Colors.deepOrange.shade900)));
    }
    return Column(children: titleWidgets);
  }
}
