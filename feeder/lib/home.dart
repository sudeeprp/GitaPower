import 'package:app_links/app_links.dart';
import 'package:askys/browse_toc.dart';
import 'package:askys/chapter_shloka_widget.dart';
import 'package:askys/choice_selector.dart';
import 'package:askys/feedcontent.dart';
import 'package:askys/content_themes.dart';
import 'package:askys/guided_tour.dart';
import 'package:askys/personal_widget.dart';
import 'package:askys/search_screen.dart';
import 'package:askys/tours_widget.dart';
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
        if (curation.length == 4) {
          tourFolder = curation[3];
          final mdsInFeed = filesWithoutExtn.map((shlokaFile) => '$shlokaFile.md').toList();
          final FeedContent feedContent = Get.find();
          feedContent.setCuratedShlokaMDs(mdsInFeed, playableFolder: tourFolder);
          Get.toNamed('/guided/$tourFolder');
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
        GetPage(
            name: '/tour',
            page: () => screenify(const ToursWidget(),
                appBar: AppBar(
                    toolbarHeight: 150, title: Image.asset('images/once-again.png', fit: BoxFit.contain)),
                choicesRow: choicesRow([], const [PersonalizeIcon(), SizedBox(width: choiceSpacing)]))),
        GetPage(name: '/browse', page: browsingScreen),
        GetPage(name: '/feed', page: () => feedScreen()),
        GetPage(name: '/shlokaheaders/:chapter', page: () => chapterShlokaScreen(Get.parameters['chapter']!)),
        GetPage(
            name: '/shloka/:mdFilename',
            page: () => screenify(buildContentWithNote(Get.parameters['mdFilename']!),
                choicesRow: choicesRow([], choicesForContent()))),
        GetPage(
            name: '/shloka/:mdFilename/:noteId',
            page: () => screenify(
                buildContentWithNote(Get.parameters['mdFilename']!, initialAnchor: Get.parameters['noteId']),
                choicesRow: choicesRow([], choicesForContent()))),
        GetPage(name: '/search', page: searchScreen),
        GetPage(
            name: '/personalize',
            page: () => screenify(PersonalWidget(), appBar: AppBar(title: const Text("Personalize")))),
        GetPage(name: '/guided/:tourFolder', page: () => guidedTourScreen(Get.parameters['tourFolder']!)),
      ]);
}

Widget feedScreen() {
  return screenify(buildFeed(), choicesRow: choicesRow([], choicesForFeed()));
}

Widget browsingScreen() {
  return screenify(BrowseToc(), choicesRow: notesChaptersChoices());
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

List<Widget> choicesForFeed() {
  return const [OpenerPreferenceIcon(), SizedBox(width: choiceSpacing)] + choicesForContent();
}

Widget notesChaptersChoices() {
  const notesChaptersTabs = [
    BrowsingPreferenceIcon(BrowsingPreference.chapters, 'images/begin-chapters.png'),
    SizedBox(width: choiceSpacing),
    BrowsingPreferenceIcon(BrowsingPreference.notes, 'images/one-step.png'),
  ];
  return choicesRow(notesChaptersTabs, [
    GestureDetector(onTap: () => Get.toNamed('/search'), child: const Icon(Icons.search, size: 48)),
    SizedBox(width: choiceSpacing),
    PersonalizeIcon(),
    SizedBox(width: choiceSpacing)
  ]);
}
