import 'package:askys/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:askys/content_source.dart';

const compiledMDtoNoteIds = '''
[{"Back-to-Basics.md": ["applnote_10", "applopener_11"]}, {"Chapter 1.md": []}, {"1-1.md": ["applnote_13"]}, {"1-12.md": ["applnote_14"]}, {"1-13.md": []}]
''';
const sampleBasics = 'Just a sample introduction';
final sample_1_1 = '''
# Chapter 1

## 1-1
```shloka-sa
धृतराष्ट्र उवाच -
धर्मक्षेत्रे
```
_Is anxiety due to rajas or tamas?_ 
${'one line\n' * 40}
<a name='applnote_13'></a>
> In our anxiety, we interpret anything that happens as a signal of doom.
''';
const sampleShloka = '''
## 2-70

```shloka-sa
आपूर्यमाणम्
```''';
const compiledNotes = '''
[{"note_id": "applopener_11", "text": "Is there a different way?", "file": "Back-to-Basics.md"}, {"note_id": "applnote_13", "text": "We often doubt", "file": "1-1.md"}]
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
    dioAdapter.onGet(
        '${GitHubFetcher.mdPath}/Back-to-Basics.md', (server) => server.reply(200, sampleBasics));
    dioAdapter.onGet(
        '${GitHubFetcher.mdPath}/1-12.md', (server) => server.reply(200, sampleShloka));
    dioAdapter.onGet(
        '${GitHubFetcher.mdPath}/1-13.md', (server) => server.reply(200, sampleShloka));
    Get.put(GitHubFetcher(dio));
  });
  testWidgets('Navigates to settings from the home screen', (tester) async {
    await tester.pumpWidget(makeMyHome());
    await tester.tap(find.byKey(const Key('home/settingsicon')));
    await tester.pumpAndSettle();
    expect(find.text('Theme'), findsOneWidget);
  });
  testWidgets('Navigates to journey notes from the home screen', (tester) async {
    await tester.pumpWidget(makeMyHome());
    await tester.tap(find.byKey(const Key('begin/notes')));
    await tester.pumpAndSettle();
    expect(Get.currentRoute, '/notes');
  });
  testWidgets('Navigates to a shloka number within three taps', (tester) async {
    await tester.pumpWidget(makeMyHome());
    await tester.tap(find.byKey(const Key('begin/chapters'))); // tap #1
    await tester.pumpAndSettle();
    expect(Get.currentRoute, '/chapters');
    await tester.tap(find.text('Chapter 1')); // tap #2
    await tester.pumpAndSettle();
    await tester.tap(find.text('1-1')); // tap #3
    await tester.pumpAndSettle();
    expect(Get.currentRoute, '/shloka/1-1.md');
  });
  testWidgets('Navigates to introduction when it is the only item in the chapter', (tester) async {
    await tester.pumpWidget(makeMyHome());
    await tester.tap(find.byKey(const Key('begin/chapters'))); // tap #1
    await tester.pumpAndSettle();
    await tester.tap(find.text('Back-to-Basics')); // tap #2
    await tester.pumpAndSettle();
    expect(find.text(sampleBasics), findsOneWidget);
  });
  testWidgets('Navigates to a note within three taps', (tester) async {
    await tester.pumpWidget(makeMyHome());
    await tester.tap(find.byKey(const Key('begin/notes'))); // tap #1
    await tester.pumpAndSettle();
    expect(Get.currentRoute, '/notes');
    await tester.tap(find.text('Is there a different way?')); // tap #2
    await tester.pumpAndSettle();
    await tester.tap(find.text('We often doubt')); // tap #3
    await tester.pumpAndSettle();
    expect(Get.currentRoute, '/shloka/1-1.md/applnote_13');
    expect(find.byKey(const Key('applnote_13')), findsOneWidget);
  });
  testWidgets('Shows feed with one tap', (tester) async {
    await tester.pumpWidget(makeMyHome());
    await tester.tap(find.byKey(const Key('begin/feed')));
    await tester.pumpAndSettle();
    expect(Get.currentRoute, '/feed');
  });
}
