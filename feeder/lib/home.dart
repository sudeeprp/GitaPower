import 'package:askys/chapter_shloka_widget.dart';
import 'package:askys/choice_selector.dart';
import 'package:askys/notes_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:askys/choice_bindings.dart';
import 'package:askys/content_widget.dart';
import 'package:askys/begin_widget.dart';
import 'package:askys/chapters_widget.dart';
import 'package:askys/feed_widget.dart';
import 'package:askys/screenify.dart';

ThemeData lightTheme() {
  final defaultLightTheme = ThemeData.light();
  const codeTextLight = TextStyle(color: Color(0xFF800000), height: 1.5);
  return defaultLightTheme.copyWith(
      cardColor: const Color(0xFFFFFFFF),
      textTheme: defaultLightTheme.textTheme.copyWith(labelMedium: codeTextLight));
}

ThemeData darkTheme() {
  final defaultDarkTheme = ThemeData.dark();
  const codeTextDark =
      TextStyle(color: Color.fromARGB(255, 236, 118, 82), height: 1.5, fontWeight: FontWeight.w300);
  return defaultDarkTheme.copyWith(
    cardColor: const Color(0xFF000000),
    textTheme: defaultDarkTheme.textTheme.copyWith(labelMedium: codeTextDark),
  );
}

List<Widget> choicesForContent() {
  return const [
    ScriptSelectionIcon(),
    HeaderPreferenceIcon(),
    MeaningExpansionIcon(),
    ThemeSelectionIcon()
  ];
}

Widget makeMyHome() {
  return GetMaterialApp(
      title: 'The Gita',
      initialBinding: ChoiceBinding(),
      theme: lightTheme(),
      darkTheme: darkTheme(),
      home: const Home(),
      getPages: [
        GetPage(
            name: '/notes',
            page: () => screenify(const NotesWidget(),
                choicesRow: choicesRow(const [ThemeSelectionIcon()]))),
        GetPage(
            name: '/feed',
            page: () => screenify(buildFeed(), choicesRow: choicesRow(choicesForContent()))),
        GetPage(
            name: '/chapters',
            page: () => screenify(const ChaptersWidget(key: Key('toc')),
                choicesRow: choicesRow(const [ThemeSelectionIcon()]))),
        GetPage(
            name: '/shlokaheaders/:chapter',
            page: () => chapterShlokaScreen(Get.parameters['chapter']!)),
        GetPage(
            name: '/shloka/:mdFilename',
            page: () => screenify(buildContentWithNote(Get.parameters['mdFilename']!),
                choicesRow: choicesRow(choicesForContent()))),
        GetPage(
            name: '/shloka/:mdFilename/:noteId',
            page: () => screenify(
                buildContentWithNote(Get.parameters['mdFilename']!,
                    initialAnchor: Get.parameters['noteId']),
                choicesRow: choicesRow(choicesForContent()))),
      ]);
}

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(context) {
    return screenify(
      const BeginWidget(),
      appBar: AppBar(
          leading: Image.asset('images/sunidhi-krishna.png'), title: const Text("Krishna's Gita")),
      choicesRow: choicesRow(const [ThemeSelectionIcon()]),
    );
  }
}

Row choicesRow(List<Widget> choiceIcons) {
  return Row(mainAxisAlignment: MainAxisAlignment.end, children: choiceIcons);
}
