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

Widget? _formShlokaTitle(
    String mdFilename, HeadPreference headPreference, Color codeColor, BuildContext context) {
  const headerContents = {
    HeadPreference.shloka: {'scrollDirection': Axis.horizontal, 'textScaleFactor': 1.3},
    HeadPreference.meaning: {
      'scrollDirection': Axis.vertical,
      'textScaleFactor': 1.2,
    },
  };
  String? headerText;
  if (headPreference == HeadPreference.shloka) {
    headerText = shlokas.headers[mdFilename]?['shloka'];
  } else {
    headerText = shlokas.headers[mdFilename]?['meaning'];
  }
  if (headerText != null) {
    return Card(
      elevation: 10,
      color: Theme.of(context).cardColor,
      child: SingleChildScrollView(
          scrollDirection: headerContents[headPreference]!['scrollDirection'] as Axis,
          child: textPadding(Text(
            headerText,
            style: TextStyle(color: codeColor, height: 1.5),
            textScaler:
                TextScaler.linear(headerContents[headPreference]!['textScaleFactor'] as double),
          ))),
    );
  }
  return null;
}

Widget textPadding(Widget textChild) {
  return Padding(padding: const EdgeInsets.symmetric(horizontal: 3), child: textChild);
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
          title: Text(shlokaTitleText),
          subtitle: _formShlokaTitle(mdFilename, headPreference, codeColor, context),
          minVerticalPadding: 16,
          onTap: () => Get.toNamed('/shloka/$mdFilename'),
        );
      }).toList();
      return ListView(children: shlokaWidgets);
    });
  }
}
