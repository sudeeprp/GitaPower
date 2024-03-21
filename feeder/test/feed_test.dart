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
import 'package:http_mock_adapter/http_mock_adapter.dart';

const threeShlokaContent = '''
[{"Back-to-Basics.md": ["applopener_1"]}, {"Chapter 1.md": []}, {"2-4.md": ["applnote_13"]}, {"10-10.md": []}, {"18-4.md": []}]
''';
const someCompiledNotes = '''
[{"note_id": "applopener_11", "text": "Is there a different way?", "file": "Back-to-Basics.md"}]
''';

void main() {
  setUp(() {
    Get.put(Choices());
    final dio = Dio();
    final dioAdapter = DioAdapter(dio: dio);
    dio.httpClientAdapter = dioAdapter;
    dioAdapter.onGet('${GitHubFetcher.mdPath}/2-4.md', (svr) => svr.reply(200, '`भजताम्`'));
    dioAdapter.onGet('${GitHubFetcher.mdPath}/10-10.md', (svr) => svr.reply(200, '`भजताम्`'));
    dioAdapter.onGet('${GitHubFetcher.mdPath}/18-4.md', (svr) => svr.reply(200, '`भजताम्`'));
    dioAdapter.onGet('${GitHubFetcher.compiledPath}/md_to_note_ids_compiled.json',
        (svr) => svr.reply(200, threeShlokaContent));
    dioAdapter.onGet('${GitHubFetcher.compiledPath}/notes_compiled.json',
        (server) => server.reply(200, someCompiledNotes));
    Get.put(GitHubFetcher(dio));
  });
  testWidgets('shows three shlokas', (tester) async {
    Get.put(FeedContent());
    Get.put(ContentNotes());
    Get.put(ContentActions());
    await tester.pumpWidget(GetMaterialApp(home: Scaffold(body: buildFeed())));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('feed/1')), findsOneWidget);
    expect(find.byKey(const Key('feed/2')), findsOneWidget);
    expect(find.byKey(const Key('feed/3')), findsOneWidget);
    Get.delete<ContentNotes>();
    Get.delete<FeedContent>();
  });
  test('picks only filenames with shlokas', () async {
    final shlokaMDs = await allShlokaMDs();
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
