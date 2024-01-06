import 'package:askys/choice_selector.dart';
import 'package:askys/content_source.dart';
import 'package:askys/feed_shloka.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:askys/notecontent.dart';

const priornextNote = '{"2-41.md": {"prior": "applnote_37", "next": "applnote_39"}}';
const compiledNotes = '''
[{"note_id": "applnote_37", "text": "When outcomes don'\u2019't matter, we can\u2019t do anything wrong.", "file": "2-40.md"}]
''';

void main() {
  setUp(() {
    final dio = Dio();
    final dioAdapter = DioAdapter(dio: dio);
    dio.httpClientAdapter = dioAdapter;
    dioAdapter.onGet('${GitHubFetcher.compiledPath}/md_prior_next_note.json',
        (svr) => svr.reply(200, priornextNote));
    Get.put(GitHubFetcher(dio));
  });
  testWidgets('shows shloka feed with header', (tester) async {
    final choices = Choices();
    Get.put(choices);
    Get.put(ContentNotes());
    await tester.pumpWidget(const GetMaterialApp(home: Scaffold(body: FeedShloka('2-41.md'))));
    await tester.pumpAndSettle();
    expect(find.textContaining('When outcomes', findRichText: true), findsOneWidget);
    expect(find.textContaining('व्यवसायात्मिका'), findsOneWidget);
    choices.headPreference.value = HeadPreference.meaning;
    await tester.pumpAndSettle();
    expect(find.textContaining('intention'), findsOneWidget);
  });
  testWidgets('tap on feed navigates to the content', (tester) async {});
  testWidgets('shows note with feed', (tester) async {});
}
