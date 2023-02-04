import 'package:flutter/material.dart';
import 'package:askys/content_widget.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

List<TextSpan> oneTextMaker(
        String content, String tag, String? elmclass, String? link) =>
    [TextSpan(text: content)];
List<Widget> simpleTextRichMaker(
    List<TextSpan> spans, SectionType sectionType) {
  if (spans.isEmpty) {
    return [];
  } else if (spans.length == 1) {
    return [Text.rich(spans[0])];
  } else {
    return [Text.rich(TextSpan(children: spans))];
  }
}

class TextMade {
  TextMade(this.content, this.tag, this.elmclass, this.link);
  String? content;
  String? tag;
  String? elmclass;
  String? link;
}

class WidgetMade {
  WidgetMade(this.spans, this.sectionType);
  List<TextSpan>? spans;
  SectionType? sectionType;
}

class ParseRecords {
  List<TextMade> textsMade = [];
  List<WidgetMade> widgetsMade = [];
}

ParseRecords md2widgets(mdContent) {
  var parseRecords = ParseRecords();
  List<TextSpan> inlineMaker(
      String content, String tag, String? elmclass, String? link) {
    parseRecords.textsMade.add(TextMade(content, tag, elmclass, link));
    return [];
  }

  List<Widget> widgetMaker(List<TextSpan> spans, SectionType sectionType) {
    parseRecords.widgetsMade.add(WidgetMade(spans, sectionType));
    return [];
  }

  WidgetMaker(widgetMaker, inlineMaker).parse(mdContent);
  return parseRecords;
}

void main() {
  testWidgets('Renders a plain-text markdown line together',
      (WidgetTester tester) async {
    final widgetWithOneMD =
        WidgetMaker(simpleTextRichMaker, oneTextMaker).parse('one two three');
    expect(widgetWithOneMD.length, equals(1));
    await tester
        .pumpWidget(GetMaterialApp(home: Column(children: widgetWithOneMD)));
    expect(find.text('one two three'), findsOneWidget);
  });
  test('Text with inline code remains inline in one widget', () {
    final inlineCode = md2widgets('inline `source`');
    expect(inlineCode.textsMade[0].content, equals('inline '));
    expect(inlineCode.textsMade[0].tag, equals('p'));
    expect(inlineCode.textsMade[1].content, equals('source'));
    expect(inlineCode.textsMade[1].tag, equals('code'));
    expect(inlineCode.widgetsMade.length, equals(1));
  });
  test('Text with multiline code is in separate widget', () {
    final headShloka = md2widgets('''
## 2-54
```shloka-sa
अर्जुन उवाच -
स्थितप्रज्ञस्य
```
''');
    expect(headShloka.textsMade[0].content, equals('2-54'));
    expect(headShloka.textsMade[0].tag, equals('h2'));
    expect(headShloka.textsMade[1].content,
        equals('अर्जुन उवाच -\nस्थितप्रज्ञस्य'));
    expect(headShloka.textsMade[1].tag, equals('code'));
    expect(headShloka.textsMade[1].elmclass, equals('language-shloka-sa'));
    expect(headShloka.widgetsMade.length, equals(2));
  });
  test('Makes a single newline with link to span in a single widget', () {
    final oneNewline = md2widgets('''
To describe someone standing
[firm](sthitaprajna_xlat)
''');
    expect(oneNewline.textsMade[0].content,
        equals('To describe someone standing '));
    expect(oneNewline.textsMade[1].content, equals('firm'));
    expect(oneNewline.textsMade[1].tag, equals('a'));
    expect(oneNewline.textsMade[1].link, equals('sthitaprajna_xlat'));
    expect(oneNewline.widgetsMade.length, equals(1));
  });
  test('Double newline makes a new row', () {
    final multiNewline = md2widgets('''
how does he behave?

While describing this
''');
    expect(multiNewline.widgetsMade.length, equals(2));
  });
  test('leading newline in non-code is ignored', () {
    final leadingnl = md2widgets('''

line after newline''');
    expect(leadingnl.textsMade[0].content, equals('line after newline'));
  });
}
