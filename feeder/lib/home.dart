import 'package:app_links/app_links.dart';
import 'package:askys/chapter_shloka_widget.dart';
import 'package:askys/choice_selector.dart';
import 'package:askys/feedcontent.dart';
import 'package:askys/feedplay.dart';
import 'package:askys/notes_widget.dart';
import 'package:askys/tours_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:askys/choice_bindings.dart';
import 'package:askys/content_widget.dart';
import 'package:askys/begin_widget.dart';
import 'package:askys/chapters_widget.dart';
import 'package:askys/feed_widget.dart';
import 'package:askys/screenify.dart';
import 'package:askys/choices_row.dart';

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

final _appLinks = AppLinks();

void initialApplinkup() async {
  navigateApplink(await _appLinks.getInitialLink());
}

void navigateApplink(Uri? uri) {
  if (uri != null && uriPointsToFeed(uri)) {
    if (uri.pathSegments.length == 3) {
      // TODO: Take the docId from the URL
      // String? docId;
      final curation = uri.pathSegments[2].split('.');
      if (curation.length >= 3) {
        final filesWithoutExtn = curation.sublist(0, 3);
        // if (curation.length == 4) {
        //   docId = curation[3];
        // }
        final mdsInFeed = filesWithoutExtn.map((shlokaFile) => '$shlokaFile.md').toList();
        final FeedContent feedContent = Get.find();
        feedContent.setCuratedShlokaMDs(mdsInFeed);
      }
    }
    Get.toNamed('/feed');
  }
}

bool uriPointsToFeed(Uri uri) {
  return uri.pathSegments.length >= 2 &&
      uri.pathSegments[0] == 'gitapower' &&
      uri.pathSegments[1] == 'feed';
}

Widget makeMyHome() {
  _appLinks.uriLinkStream.listen(navigateApplink);
  WidgetsBinding.instance.addPostFrameCallback((_) => initialApplinkup());
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
                choicesRow:
                    choicesRow(const [ThemeSelectionIcon(), SizedBox(width: choiceSpacing)]))),
        GetPage(name: '/feed', page: () => feedScreen()),
        GetPage(
            name: '/chapters',
            page: () => screenify(const ChaptersWidget(key: Key('toc')),
                choicesRow:
                    choicesRow(const [ThemeSelectionIcon(), SizedBox(width: choiceSpacing)]))),
        GetPage(
            name: '/tour',
            page: () => screenify(const ToursWidget(),
                choicesRow:
                    choicesRow(const [ThemeSelectionIcon(), SizedBox(width: choiceSpacing)]))),
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

Widget feedScreen() {
  return screenify(buildFeed(), choicesRow: choicesRow(choicesForFeed()));
}

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(context) {
    return screenify(
      const BeginWidget(),
      appBar: AppBar(
          leading: Image.asset('images/sunidhi-krishna.png'), title: const Text("Krishna's Gita")),
      choicesRow: choicesRow(const [ThemeSelectionIcon(), SizedBox(width: choiceSpacing)]),
    );
  }
}

List<Widget> choicesForContent() {
  return const [
    ScriptSelectionIcon(),
    SizedBox(width: choiceSpacing),
    HeaderPreferenceIcon(),
    SizedBox(width: choiceSpacing),
    MeaningExpansionIcon(),
    SizedBox(width: choiceSpacing),
    ThemeSelectionIcon(),
    SizedBox(width: choiceSpacing),
  ];
}

List<Widget> choicesForFeed() {
  return const [
        FeedPlay(
          key: Key('feedplay'),
        ),
        SizedBox(width: choiceSpacing)
      ] +
      const [OpenerPreferenceIcon(), SizedBox(width: choiceSpacing)] +
      choicesForContent();
}
