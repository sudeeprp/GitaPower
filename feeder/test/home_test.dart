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

const compiledNotes = '''
[{"note_id": "applopener_11", "text": "Is there a different way?", "file": "1-1.md"}, {"note_id": "applnote_13", "text": "We often doubt", "file": "1-1.md"}]
''';

void main() {
  setUp(() {
    final dio = Dio();
    final dioAdapter = DioAdapter(dio: dio);
    dio.httpClientAdapter = dioAdapter;
    dioAdapter.onGet('${GitHubFetcher.compiledPath}/md_to_note_ids_compiled.json',
        (server) => server.reply(200, compiledMDtoNoteIds));
    dioAdapter.onGet('${GitHubFetcher.compiledPath}/notes_compiled.json',
        (server) => server.reply(200, compiledNotes));
    dioAdapter.onGet('${GitHubFetcher.mdPath}/1-1.md', (server) => server.reply(200, sample_1_1));
    Get.put(GitHubFetcher(dio));
  });
  testWidgets('Navigates to settings from the home screen', (WidgetTester tester) async {
    await tester.pumpWidget(makeMyHome());
    await tester.tap(find.byKey(const Key('home/settingsicon')));
    await tester.pumpAndSettle();
    expect(find.byType(ChoiceSelector), findsOneWidget);
  });
  testWidgets('Navigates to journey notes from the home screen', (WidgetTester tester) async {
    await tester.pumpWidget(makeMyHome());
    await tester.tap(find.byKey(const Key('begin/notestoc')));
    await tester.pumpAndSettle();
    expect(Get.currentRoute, '/notestoc');
  });
  testWidgets('Navigates to a shloka number within three taps', (WidgetTester tester) async {
    await tester.pumpWidget(makeMyHome());
    await tester.tap(find.byKey(const Key('begin/chapters'))); // tap #1
    await tester.pumpAndSettle();
    expect(Get.currentRoute, '/chapters');
    await tester.tap(find.text('Chapter 1')); // tap #2
    await tester.pumpAndSettle();
    await tester.tap(find.text('1-1')); // tap #3
    await tester.pumpAndSettle();
    expect(Get.currentRoute, '/shloka');
    expect(Get.arguments, '1-1.md');
  });
  testWidgets('Navigates to a note within three taps', (tester) async {
    await tester.pumpWidget(makeMyHome());
    await tester.tap(find.byKey(const Key('begin/notestoc'))); // tap #1
    await tester.pumpAndSettle();
    expect(Get.currentRoute, '/notestoc');
    await tester.tap(find.text('Is there a different way?')); // tap #2
    await tester.pumpAndSettle();
    await tester.tap(find.text('We often doubt')); // tap #3
    await tester.pumpAndSettle();
    expect(Get.currentRoute, '/note');
    expect(Get.arguments['mdFilename'], '1-1.md');
  });
}
