import 'package:app_links/app_links.dart';
import 'package:askys/browse_toc.dart';
import 'package:askys/chapter_shloka_widget.dart';
import 'package:askys/choice_selector.dart';
import 'package:askys/feedcontent.dart';
import 'package:askys/content_themes.dart';
import 'package:askys/guided_tour.dart';
import 'package:askys/personal_widget.dart';
import 'package:askys/search_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:askys/choice_bindings.dart';
import 'package:askys/content_widget.dart';
import 'package:askys/begin_widget.dart';
import 'package:askys/feed_widget.dart';
import 'package:askys/screenify.dart';
import 'package:askys/choices_row.dart';

final _appLinks = AppLinks();

void initialApplinkup() async {
  navigateApplink(await _appLinks.getInitialLink());
}

void navigateApplink(Uri? uri) {
  if (uri != null && uriPointsToFeed(uri)) {
    if (uri.pathSegments.length == 3) {
      String? tourFolder;
      final curation = uri.pathSegments[2].split('.');
      if (curation.length >= 3) {
        final filesWithoutExtn = curation.sublist(0, 3);
        final mdsInFeed = filesWithoutExtn.map((shlokaFile) => '$shlokaFile.md').toList();
        final FeedContent feedContent = Get.find();
        if (curation.length == 4) {
          tourFolder = curation[3];
          feedContent.setCuratedShlokaMDs(mdsInFeed, playableFolder: tourFolder);
          Get.toNamed('/guided/$tourFolder');
        } else {
          feedContent.setCuratedShlokaMDs(mdsInFeed);
          Get.toNamed('/feed');
        }
      }
    }
  }
}

bool uriPointsToFeed(Uri uri) {
  return uri.pathSegments.length >= 2 && uri.pathSegments[0] == 'gitapower' && uri.pathSegments[1] == 'feed';
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
      debugShowCheckedModeBanner: false,
      getPages: [
        GetPage(name: '/browse', page: browsingScreen),
        GetPage(name: '/feed', page: () => feedScreen()),
        GetPage(name: '/shlokaheaders/:chapter', page: () => chapterShlokaScreen(Get.parameters['chapter']!)),
        GetPage(
            name: '/shloka/:mdFilename',
            page: () => ContentScreen(Get.parameters['mdFilename']!, choicesRowForContent())),
        GetPage(
            name: '/shloka/:mdFilename/:noteId',
            page: () => ContentScreen(Get.parameters['mdFilename']!, choicesRowForContent(),
                initialAnchor: Get.parameters['noteId'])),
        GetPage(name: '/search', page: searchScreen),
        GetPage(
            name: '/personalize',
            page: () => screenify(PersonalWidget(), appBar: AppBar(title: const Text("Personalize")))),
        GetPage(name: '/guided/:tourFolder', page: () => guidedTourScreen(Get.parameters['tourFolder']!)),
      ]);
}

Widget feedScreen() {
  return screenify(FeedWidget(),
      choicesRow: choicesRow([SizedBox(width: choiceSpacing), widgetToHome()], choicesForFeed()));
}

Widget browsingScreen() {
  return screenify(BrowseToc(),
      appBar: AppBar(
          title: Row(children: [
        Image.asset('images/begin-chapters.png', height: 32, width: 32),
        const SizedBox(width: choiceSpacing),
        const Text("Chapters and Notes")
      ])),
      choicesRow: notesChaptersChoices());
}

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(context) {
    return screenify(
      const BeginWidget(),
      appBar: AppBar(leading: Image.asset('images/sunidhi-krishna.png'), title: const Text("Krishna's Gita")),
      choicesRow: choicesRow(
          [], const [PersonalizeIcon(key: Key('choice/preferences')), SizedBox(width: choiceSpacing)]),
    );
  }
}

List<Widget> choicesForContent() {
  return const [
    MeaningExpansionIcon(),
    SizedBox(width: choiceSpacing),
    PersonalizeIcon(),
    SizedBox(width: choiceSpacing),
  ];
}

Widget choicesRowForContent() {
  return choicesRow([SizedBox(width: choiceSpacing), widgetToHome()], choicesForContent());
}

List<Widget> choicesForFeed() {
  return const [
    PromptWidget(),
    SizedBox(width: choiceSpacing),
    PersonalizeIcon(),
    SizedBox(width: choiceSpacing),
  ];
}

Widget notesChaptersChoices() {
  return choicesRow([
    SizedBox(width: choiceSpacing),
    widgetToHome()
  ], [
    GestureDetector(onTap: () => Get.toNamed('/search'), child: const Icon(Icons.search, size: 48)),
    SizedBox(width: choiceSpacing),
    PersonalizeIcon(),
    SizedBox(width: choiceSpacing)
  ]);
}
