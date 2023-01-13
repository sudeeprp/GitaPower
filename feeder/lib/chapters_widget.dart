import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:askys/chaptercontent.dart';

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
                  children: chapter.shokas
                      .map((shlokaTitle) => ListTile(
                            title: Text(shlokaTitle),
                            onTap: () {
                              Get.toNamed('/shloka',
                                  arguments: '$shlokaTitle.md');
                            },
                          ))
                      .toList(),
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
}