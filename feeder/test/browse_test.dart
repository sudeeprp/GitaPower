import 'package:askys/browse_toc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:askys/content_source.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

const compiledMDtoNoteIds = '''[
{"Back-to-Basics.md": ["applopener_1", "applnote_12"]},
{"Chapter_1.md": []},
{"1-1.md": ["applnote_13"]},
{"1-12.md": ["applnote_14"]},
{"Chapter_2.md": []},
{"2-1_to_2-3.md": ["applnote_15", "applopener_2", "applnote_16"]}
]''';

const notesCompiled = '''
[{"note_id": "applopener_1", "text": "Who am I?", "file": "Back-to-Basics.md"},
{"note_id": "applnote_12", "text": "I am not my body, am I?", "file": "Back-to-Basics.md"},
{"note_id": "applnote_13", "text": "I am not just a thought, am I?", "file": "1-1.md"},
{"note_id": "applnote_14", "text": "What shall I do...", "file": "1-12.md"},
{"note_id": "applnote_15", "text": "Get up", "file": "2-1_to_2-3.md"},
{"note_id": "applopener_2", "text": "What am I doing?", "file": "2-1_to_2-3.md"},
{"note_id": "applnote_16", "text": "I'll tell you", "file": "2-1_to_2-3.md"}
]''';

void main() {
  Get.testMode = true;
  setUp(() {
    final dio = Dio();
    final dioAdapter = DioAdapter(dio: dio);
    dio.httpClientAdapter = dioAdapter;
    dioAdapter.onGet('${GitHubFetcher.compiledPath}/md_to_note_ids_compiled.json',
        (server) => server.reply(200, compiledMDtoNoteIds));
    dioAdapter.onGet(
        '${GitHubFetcher.compiledPath}/notes_compiled.json', (server) => server.reply(200, notesCompiled));
    Get.put(GitHubFetcher(dio));
  });
  test('initializes openers in line with chapters', () async {
    final controller = Get.put(BrowseController());
    await Future.delayed(Duration(milliseconds: 250));
    expect(controller.browseItems.length, 10);
    expect(controller.browseItems[0], isA<ChapterEntry>());
    expect(controller.browseItems[0].titleText, 'Back-to-Basics');
    expect(controller.browseItems[0].mdFilename, 'Back-to-Basics.md');
    expect(controller.browseItems[1], isA<OpenerEntry>());
    expect(controller.browseItems[1].titleText, 'Who am I?');
    expect(controller.browseItems[1].mdFilename, 'Back-to-Basics.md');
    expect(controller.browseItems[2], isA<NoteEntry>());
    expect(controller.browseItems[2].titleText, 'I am not my body, am I?');
    expect(controller.browseItems[3], isA<ChapterEntry>());
    expect(controller.browseItems[4], isA<NoteEntry>());
    expect(controller.browseItems[5], isA<NoteEntry>());
    expect(controller.browseItems[5].titleText, 'What shall I do...');
    expect(controller.browseItems[5].mdFilename, '1-12.md');
    // sampled up to 1-12.md
    Get.delete<BrowseController>();
  });
  testWidgets('browses chapters, openers, notes in openers', (tester) async {
    Get.put(BrowseController());
    await tester.pumpWidget(const GetMaterialApp(home: Scaffold(body: BrowseToc())));
    await tester.pumpAndSettle();
    expect(find.text('Back-to-Basics'), findsOneWidget);
    expect(find.text('Who am I?'), findsOneWidget);
    expect(find.text('I am not my body, am I?'), findsNothing);
    // Notes not visible by default. Opener needs to be expanded
    expect(find.text('What shall I do...'), findsNothing);
    // Expand the opener
    await tester.tap(find.text('Who am I?'));
    await tester.pumpAndSettle();
    expect(find.text('What shall I do...'), findsOneWidget);
    Get.delete<BrowseController>();
  });
}
