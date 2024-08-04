import 'package:askys/choice_selector.dart';
import 'package:askys/content_actions.dart';
import 'package:askys/content_source.dart';
import 'package:askys/feed_widget.dart';
import 'package:askys/feedcontent.dart';
import 'package:askys/home.dart';
import 'package:askys/notecontent.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';

void main() {
  setUp(() {
    Get.put(Choices());
    final dio = Dio();
    final dioAdapter = DioAdapter(dio: dio);
    dioAdapter.onGet(
        '${GitHubFetcher.playablesUrl}/bring_the_best_in_you/playable.json',
        (server) => server.reply(
            200,
            '[{"line": "l1", "link": "1-1", "speech": "s1.mp3", "show": ["k11", "k12"]}, '
            '{"line": "l2", "speech": "s2.mp3"}, '
            '{"line": "l3", "speech": "s3.mp3", "link": "1-3"}]'));
    dio.httpClientAdapter = dioAdapter;

    Get.put(GitHubFetcher(dio));
    Get.put(FeedContent.random());
    Get.put(ContentNotes());
    Get.put(ContentActions());
  });
  void switchOpeners(bool openersAreVisible) {
    final FeedContent feedContent = Get.find();
    for (int i = 0; i < feedContent.openerCovers.length; i++) {
      feedContent.openerCovers[i].value = openersAreVisible;
    }
  }

  testWidgets('shows three shlokas', (tester) async {
    await tester.pumpWidget(GetMaterialApp(home: Scaffold(body: buildFeed())));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('feed/1')), findsOneWidget);
    expect(find.byKey(const Key('feed/2')), findsOneWidget);
    expect(find.byKey(const Key('feed/3')), findsOneWidget);
  });
  testWidgets('tapping on a feed navigates to the shloka', (tester) async {
    switchOpeners(false);
    final FeedContent feedContent = Get.find();
    await tester.pumpAndSettle();
    String? navigatedShloka;
    await tester.pumpWidget(GetMaterialApp(home: Scaffold(body: buildFeed()), getPages: [
      GetPage(
          name: '/shloka/:mdFilename',
          page: () {
            navigatedShloka = Get.parameters['mdFilename'];
            return const Text('reached');
          })
    ]));
    await tester.pumpAndSettle();
    final shlokaFinder = find.byType(GestureDetector);
    var tapOffset = tester.getTopLeft(find.byWidget(shlokaFinder.evaluate().first.widget));
    tapOffset += const Offset(50, 100);
    await tester.tapAt(tapOffset);
    await tester.pumpAndSettle();
    expect(feedContent.threeShlokas.contains(navigatedShloka), true);
  });
  testWidgets('switches to curated shlokas', (tester) async {
    final ContentNotes contentNotes = Get.find();
    contentNotes.notesLoaded.value = true;
    await tester.pumpWidget(GetMaterialApp(
        home: Scaffold(body: buildFeed()),
        getPages: [GetPage(name: '/feed', page: () => feedScreen())]));
    await tester.pumpAndSettle();
    navigateApplink(Uri.parse('/gitapower/feed/2-34.9-13.15-14'));
    await tester.pumpAndSettle();
    expect(find.text('2-34'), findsOneWidget);
  });
  testWidgets('can tap on play only when narration is available', (tester) async {
    final ContentNotes contentNotes = Get.find();
    contentNotes.notesLoaded.value = true;
    await tester.pumpWidget(GetMaterialApp(
        home: Scaffold(body: feedScreen()),
        getPages: [GetPage(name: '/feed', page: () => feedScreen())]));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('feedplay')), findsNothing);
    navigateApplink(Uri.parse('/gitapower/feed/2-34.9-13.15-14.bring_the_best_in_you'));
    await tester.pumpAndSettle();
    final player = find.byKey(const Key('feedplay'));
    expect(player, findsOneWidget);
    await tester.tap(player);
    await tester.pumpAndSettle();
  });
  testWidgets('shows the opener questions, hides on swipe', (tester) async {
    switchOpeners(true);
    await tester.pumpAndSettle();
    final FeedContent feedContent = Get.find();
    expect(feedContent.openerQs[0], isNotEmpty);
    expect(feedContent.openerQs[1], isNotEmpty);
    expect(feedContent.openerQs[2], isNotEmpty);

    expect(feedContent.openerCovers[0].value, equals(true));

    await tester.pumpWidget(GetMaterialApp(home: Scaffold(body: buildFeed())));
    expect(find.text(feedContent.openerQs[0]), findsWidgets);
    expect(find.text(feedContent.openerQs[1]), findsWidgets);
    expect(find.text(feedContent.openerQs[2]), findsWidgets);
    const overqPos = 1;
    final firstOpener = find.byKey(const Key('overq/$overqPos'));
    await tester.dragFrom(tester.getTopLeft(firstOpener), const Offset(1000, 0));
    await tester.pumpAndSettle();
    expect(feedContent.openerCovers[overqPos - 1].value, equals(false));
  });
  test('picks only filenames with shlokas', () async {
    final shlokaMDs = allShlokaMDs();
    expect(shlokaMDs.length, equals(600)); // counted 600 shloka files
  });
  test('recognizes chapter and shloka numbers for comparison', () {
    final singleShlokaRef = mdFilenameToShlokaNumber('12-3.md');
    expect(singleShlokaRef.chapterNumber, equals(12));
    expect(singleShlokaRef.shlokaNumber, 3);
    final doubleShlokaRefAsFirst = mdFilenameToShlokaNumber('1-3_to_1-20.md');
    expect(doubleShlokaRefAsFirst.chapterNumber, equals(1));
    expect(doubleShlokaRefAsFirst.shlokaNumber, equals(3));
  });
  test('creates a random sorted feed', () {
    bool firstComesBefore(String firstMD, String secondMD) {
      final firstShlokaRef = mdFilenameToShlokaNumber(firstMD);
      final secondShlokaRef = mdFilenameToShlokaNumber(secondMD);
      return firstShlokaRef.chapterNumber < secondShlokaRef.chapterNumber ||
          (firstShlokaRef.chapterNumber == secondShlokaRef.chapterNumber &&
              firstShlokaRef.shlokaNumber < secondShlokaRef.shlokaNumber);
    }

    final feedMDs = createRandomFeed(['2-4.md', '3-5.md', '10-10.md', '18-4.md', '18-50.md']);
    expect(feedMDs.length, equals(3));
    expect(firstComesBefore(feedMDs[0], feedMDs[1]), isTrue);
    expect(firstComesBefore(feedMDs[1], feedMDs[2]), isTrue);
  });
  testWidgets('retrieves tour stops from tour folder', (tester) async {
    final feedContent = FeedContent.random();
    feedContent
        .setCuratedShlokaMDs(['2-1.md', '3-11.md', '4-12.md'], tourFolder: 'bring_the_best_in_you');
    await tester.pumpAndSettle();
    expect(feedContent.tourStops, isNotEmpty);
  });
  test('toggles opener cover visibility', () {
    final FeedContent feedContent = Get.find();
    feedContent.openerCovers[0].value = false;
    feedContent.toggleOpenerCovers();
    expect(feedContent.openerCovers[0].value, equals(true));
    feedContent.toggleOpenerCovers();
    expect(feedContent.openerCovers[0].value, equals(false));
    expect(feedContent.openerCovers[2].value, equals(false));
  });
}
