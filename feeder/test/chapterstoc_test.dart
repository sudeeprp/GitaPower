import 'package:askys/chaptercontent.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('converts applnotes into chapters and shlokas', (WidgetTester tester) async {
    const List<Map<String, List<String>>> mdToNoteIds = [
      {"Chapter_1.md": []},
      {
        "1-20_to_1-23.md": ["applnote_15"]
      },
      {"1-24_to_1-25.md": []},
      {
        "1-26_to_1-47.md": ["applnote_16"]
      },
      {"Chapter_2.md": []},
      {
        "2-1.md": ["applopener_17"]
      },
      {
        "2-2.md": ["applnote_18"]
      }
    ];
    final chapters = mdNotesToChapters(mdToNoteIds);
    expect(chapters[0].title, equals('Chapter 1'));
    expect(chapters[0].shokas[0], equals('Introduction'));
    expect(chapters[0].shokas.length, equals(4));
    expect(chapters[1].title, equals('Chapter 2'));
    expect(chapters[1].shokas.length, equals(3));
  });
  test('gets the next and previous in the navigation sequence', () {
    final chapterstoc = ChaptersTOC();
    expect(chapterstoc.nextmd('1-24_to_1-25.md'), equals('1-26_to_1-47.md'));
    expect(chapterstoc.nextmd('The_Beginning_of_Joy.md'), equals(null));
    expect(chapterstoc.prevmd('Chapter_14.md'), equals('13-34.md'));
    expect(chapterstoc.prevmd('Back-to-Basics.md'), equals(null));
  });
}
