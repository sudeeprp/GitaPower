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
    String shlokaTitleText, String mdFilename, HeadPreference headPreference, Color codeColor) {
  final List<Widget> titleWidgets = [Text(shlokaTitleText, textScaleFactor: 1.2)];
  String? headerText;
  const headerContents = {
    HeadPreference.shloka: {
      'scrollDirection': Axis.horizontal,
      'textScaleFactor': 1.5,
    },
    HeadPreference.meaning: {
      'scrollDirection': Axis.vertical,
      'textScaleFactor': 1.2,
    },
  };
  if (headPreference == HeadPreference.shloka) {
    headerText = shlokas.headers[mdFilename]?['shloka'];
  } else {
    headerText = shlokas.headers[mdFilename]?['meaning'];
  }
  if (headerText != null) {
    return Card(
      elevation: 10,
      // margin: const EdgeInsets.symmetric(horizontal: 2),
      child: SingleChildScrollView(
        scrollDirection: headerContents[headPreference]!['scrollDirection'] as Axis,
        child: textPadding(Text(
          headerText,
          style: TextStyle(color: codeColor, height: 1.5),
          textScaleFactor: headerContents[headPreference]!['textScaleFactor'] as double,
        ))),
    );
  }
  return null;
  // return Column(crossAxisAlignment: CrossAxisAlignment.start, children: titleWidgets);
  // return Card(
  //   elevation: 10,
  //   child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: titleWidgets));
}

Widget textPadding(Widget textChild) {
  return Padding(padding: const EdgeInsets.symmetric(horizontal: 3), child: textChild);
}

Widget addBorder(Widget child) {
  return Padding(
      padding: const EdgeInsets.only(top: 6, bottom: 6, left: 0, right: 0),
      child: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.white.withOpacity(0.1),
              offset: const Offset(-4.0, -4.0),
              blurRadius: 16.0,
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              offset: const Offset(4.0, 4.0),
              blurRadius: 16.0,
            ),
          ],
        ),
        child: child,
      ),
  );
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
          subtitle: _formShlokaTitle(shlokaTitleText, mdFilename, headPreference, codeColor),
          // contentPadding: const EdgeInsets.symmetric(vertical: 16),
          // visualDensity: const VisualDensity(vertical: 3),
          minVerticalPadding: 16,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(16))) ,
          onTap: () => Get.toNamed('/shloka/$mdFilename'),
        );
      }).toList();
      return ListView(children: shlokaWidgets);
    });
  }
}
