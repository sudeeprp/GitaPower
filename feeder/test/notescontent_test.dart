import 'package:askys/content_source.dart';
import 'package:askys/notecontent.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';

void main() {
  setUp(() {
    final dio = Dio();
    final dioAdapter = DioAdapter(dio: dio);
    dio.httpClientAdapter = dioAdapter;
    dioAdapter.onGet('${GitHubFetcher.compiledPath}/md_to_note_ids_compiled.json',
        (server) => server.reply(200, '[{"1-1.md": []}, {"1-2.md": []}]'));
    dioAdapter.onGet(
        '${GitHubFetcher.compiledPath}/notes_compiled.json', (server) => server.reply(200, '[]'));
    Get.put(GitHubFetcher(dio));
  });
  testWidgets('Decodes compiled notes and filenames into notes TOC', (WidgetTester tester) async {
    const List<Map<String, String>> compiledNotes = [
      {"note_id": "applopener_1", "text": "Who am I?", "file": "Back-to-Basics.md"},
      {"note_id": "applnote_2", "text": "I am not my body, am I?", "file": "Back-to-Basics.md"},
      {
        "note_id": "applnote_3",
        "text": "I am not just a thought, am I?",
        "file": "Back-to-Basics.md"
      },
      {"note_id": "applopener_6", "text": "What am I doing?", "file": "Chapters.md"},
      {
        "note_id": "applnote_7",
        "text": "Is it about \u2018doing\u2019 or \u2018making it happen\u2019?",
        "file": "Chapters.md"
      }
    ];
    final openers = compilationsToOpeners(compiledNotes);
    expect(openers.length, equals(2));
    expect(openers[0].noteId, equals('applopener_1'));
    expect(openers[0].notes.length, equals(3));
    expect(openers[0].notes[0].noteId, equals('applopener_1'));
    expect(openers[0].notes[1].noteId, equals('applnote_2'));
    expect(openers[0].notes[1].mdFilename, equals('Back-to-Basics.md'));
    expect(openers[1].openerContent, equals('What am I doing?'));
    expect(openers[1].notes[0].noteId, equals('applopener_6'));
    expect(openers[1].notes[1].noteId, equals('applnote_7'));
  });
  test('maps md to its previous note', () {
    const List<Map<String, List<String>>> mdToNoteIds = [
      {"Chapter_2.md": []},
      {
        "2-11.md": ["applnote_15"]
      },
      {"2-12.md": []},
    ];
    const List<Map<String, String>> notesCompiled = [
      {"note_id": "applopener_14", "text": "The Self is eternal", "file": "Chapter_1.md"},
      {"note_id": "applnote_15", "text": "I am not my body", "file": "2-11.md"},
    ];
    final mdsToInitialNotes = mapMdsToTheirNotes(mdToNoteIds, notesCompiled);
    expect(mdsToInitialNotes['Chapter_2.md'], equals(null));
    expect(mdsToInitialNotes['2-11.md'], equals(null));
    expect(mdsToInitialNotes['2-12.md'], equals('I am not my body'));
  });
  test('loses links when translated to plain text', () {
    expect(
        toPlainText('Practice [devotion](b.md#bhakti) always'), equals('Practice devotion always'));
    expect(toPlainText('What am I?'), equals('What am I?'));
  });
  testWidgets('tells the next and previous md files of a given md', (tester) async {
    final contentNotes = ContentNotes();
    Get.put(contentNotes);
    await tester.pumpAndSettle();
    expect(contentNotes.nextmd('1-1.md'), equals('1-2.md'));
    expect(contentNotes.nextmd('1-2.md'), equals(null));
    expect(contentNotes.prevmd('1-2.md'), equals('1-1.md'));
    expect(contentNotes.prevmd('1-1.md'), equals(null));
  });
}
