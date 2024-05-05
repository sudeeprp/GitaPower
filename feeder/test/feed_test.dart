import 'package:askys/choice_selector.dart';
import 'package:askys/content_actions.dart';
import 'package:askys/content_source.dart';
import 'package:askys/feed_widget.dart';
import 'package:askys/feedcontent.dart';
import 'package:askys/notecontent.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

void main() {
  setUp(() {
    Get.put(Choices());
    final dio = Dio();
    Get.put(GitHubFetcher(dio));
    Get.put(FeedContent.random());
  });
  testWidgets('shows three shlokas', (tester) async {
    Get.put(ContentNotes());
    Get.put(ContentActions());
    await tester.pumpWidget(GetMaterialApp(home: Scaffold(body: buildFeed())));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('feed/1')), findsOneWidget);
    expect(find.byKey(const Key('feed/2')), findsOneWidget);
    expect(find.byKey(const Key('feed/3')), findsOneWidget);
    Get.delete<ContentNotes>();
  });
  testWidgets('tapping on a feed navigates to the shloka', (tester) async {
    final FeedContent feedContent = Get.find();
    Get.put(ContentNotes());
    Get.put(ContentActions());
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
  testWidgets('shows the opener questions', (tester) async {
    final FeedContent feedContent = Get.find();
    Get.put(ContentNotes());
    Get.put(ContentActions());
    await tester.pumpAndSettle();
    expect(feedContent.openerQs[0], isNotEmpty);
    expect(feedContent.openerQs[1], isNotEmpty);
    expect(feedContent.openerQs[2], isNotEmpty);
    await tester.pumpWidget(GetMaterialApp(home: Scaffold(body: buildFeed())));
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
}
