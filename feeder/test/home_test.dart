import 'package:askys/choice_selector.dart';
import 'package:askys/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:askys/content_source.dart';

const compiledMDtoNoteIds = '''
[{"Back-to-Basics.md": ["applopener_1", "applnote_12"]}, {"Chapter 1.md": []}, {"1-1.md": ["applnote_13"]}, {"1-12.md": ["applnote_14"]}]
''';
const sample_1_1 = '''
## 1-1
```shloka-sa
धृतराष्ट्र उवाच -
धर्मक्षेत्रे
```
''';

void main() {
  setUp(() {
    final dio = Dio();
    final dioAdapter = DioAdapter(dio: dio);
    dio.httpClientAdapter = dioAdapter;
    dioAdapter.onGet(
        'https://raw.githubusercontent.com/RaPaLearning/gita-begin/main/compile/md_to_note_ids_compiled.json',
        (server) => server.reply(200, compiledMDtoNoteIds));
    dioAdapter.onGet(
        'https://raw.githubusercontent.com/RaPaLearning/gita-begin/main/gita/1-1.md',
        (server) => server.reply(200, sample_1_1));
    Get.put(GitHubFetcher(dio));
  });
  testWidgets('Navigates to settings from the home screen',
      (WidgetTester tester) async {
    await tester.pumpWidget(makeMyHome());
    await tester.tap(find.byKey(const Key('home/settingsicon')));
    await tester.pumpAndSettle();
    expect(find.byType(ChoiceSelector), findsOneWidget);
  });
  testWidgets('Navigates to journey notes from the home screen',
      (WidgetTester tester) async {
    await tester.pumpWidget(makeMyHome());
    await tester.tap(find.byKey(const Key('begin/notes')));
    await tester.pumpAndSettle();
    expect(Get.currentRoute, '/notes');
  });
  testWidgets('Navigates to a shloka number within three taps',
      (WidgetTester tester) async {
    await tester.pumpWidget(makeMyHome());
    await tester.tap(find.byKey(const Key('begin/chapters')));
    await tester.pumpAndSettle();
    expect(Get.currentRoute, '/chapters');
    await tester.tap(find.text('Chapter 1'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('1-1'));
    await tester.pumpAndSettle();
    expect(Get.currentRoute, '/shloka');
    expect(Get.arguments, '1-1.md');
  });
}
