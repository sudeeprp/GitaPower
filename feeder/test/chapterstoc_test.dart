import 'package:askys/chaptercontent.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('converts applnotes into chapters and shlokas', (WidgetTester tester) async {
    const List<Map<String, List<String>>> notesJsonStr = [
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
    final chapters = mdNotesToChapters(notesJsonStr);
    expect(chapters[0].title, equals('Chapter 1'));
    expect(chapters[0].shokas[0], equals('Chapter 1'));
    expect(chapters[0].shokas.length, equals(4));
    expect(chapters[1].title, equals('Chapter 2'));
    expect(chapters[1].shokas.length, equals(3));
  });
}
