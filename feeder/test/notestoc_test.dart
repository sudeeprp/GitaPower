import 'package:askys/notecontent.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Decodes compiled notes and filenames into notes TOC', (WidgetTester tester) async {
    const compiledNotesJsonStr = '''[
      {"note_id": "applopener_1", "text": "Who am I?", "file": "Back-to-Basics.md"},
        {"note_id": "applnote_2", "text": "I am not my body, am I?", "file": "Back-to-Basics.md"},
        {"note_id": "applnote_3", "text": "I am not just a thought, am I?", "file": "Back-to-Basics.md"},
      {"note_id": "applopener_6", "text": "What am I doing?", "file": "Chapters.md"},
        {"note_id": "applnote_7", "text": "Is it about \u2018doing\u2019 or \u2018making it happen\u2019?", "file": "Chapters.md"}
]''';
    final openers = compilationsToOpeners(compiledNotesJsonStr);
    expect(openers.length, equals(2));
    expect(openers[0].noteId, equals('applopener_1'));
    expect(openers[0].notes[0].noteId, equals('applnote_2'));
    expect(openers[0].notes[1].mdFilename, equals('Back-to-Basics.md'));
    expect(openers[1].openerContent, equals('What am I doing?'));
    expect(openers[1].notes[0].noteId, equals('applnote_7'));
  });
}
