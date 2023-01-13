import 'package:askys/chaptercontent.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Decodes applnotes into chapters and shlokas',
      (WidgetTester tester) async {
    const notesJsonStr = '''[
{"Chapter 1.md": []},
{"1-20 to 1-23.md": ["applnote_15"]},
{"1-24 to 1-25.md": []},
{"1-26 to 1-47.md": ["applnote_16"]},
{"Chapter 2.md": []},
{"2-1.md": ["applopener_17"]},
{"2-2.md": ["applnote_18"]}
]''';
    final chapters = notesJsonStrToChapters(notesJsonStr);
    expect(chapters[0].title, equals('Chapter 1'));
    expect(chapters[0].shokas.length, equals(3));
    expect(chapters[1].title, equals('Chapter 2'));
    expect(chapters[1].shokas.length, equals(2));
  });
}
