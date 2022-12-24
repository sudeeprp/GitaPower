import 'package:flutter/material.dart';
import 'package:askys/choice_selector.dart';
import 'package:askys/content_widget.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:markdown/markdown.dart' as md;

List<TextSpan> oneTextMaker(String content, String tag, String? elmclass)=> [TextSpan(text: content)];
List<Widget> textRichMaker(List<TextSpan> spans, SectionType sectionType) {
  if (spans.isEmpty) {
    return [];
  } else if (spans.length == 1) {
    return [Text.rich(spans[0])];
  } else {
    return [Text.rich(TextSpan(children: spans))];
  }
}

void main() {
  testWidgets('Renders a plain-text markdown line together',
      (WidgetTester tester) async {
    // Get.put(Choices());
    // final BuildContext context = tester.element(find.byType(Container));
    final widgetWithOneMD = WidgetMaker(textRichMaker, oneTextMaker).parse('one two three');
    expect(widgetWithOneMD.length, equals(1));
    await tester
        .pumpWidget(GetMaterialApp(home: Column(children: widgetWithOneMD)));
    expect(find.text('one two three'), findsOneWidget);
  });
  testWidgets('Text with inline code remains inline in one widget', (WidgetTester tester) async {
    List<String> mdTexts = [];
    List<TextSpan> mdTextCollector(String content, String tag, String? elmclass) {
      mdTexts.add(content);
      return [TextSpan(text: content)];
    }
    final widgetsWithInlineCode = WidgetMaker(textRichMaker, mdTextCollector).parse('inline `code`');
    expect(widgetsWithInlineCode.length, equals(1));
    expect(mdTexts[0], equals('inline '));
    expect(mdTexts[1], equals('code'));
  });
  testWidgets('Multiline code is in separate widget', (WidgetTester tester) async {
    final widgetsWithMultilineCode = WidgetMaker(textRichMaker, oneTextMaker).parse('''
## 2-54
```shloka-sa
अर्जुन उवाच -
स्थितप्रज्ञस्य 
```
''');
    expect(widgetsWithMultilineCode.length, equals(2));
  });
  testWidgets('Single newline appears as whitespace', (WidgetTester tester) async {
    final widgetsForSingleNewline = WidgetMaker(textRichMaker, oneTextMaker).parse('''
To describe someone standing 
[firm in wisdom](sthitaprajna_xlat)
''');
    expect(widgetsForSingleNewline.length, equals(1));
  });
  testWidgets('Double newline makes a new row', (WidgetTester tester) async {
    final widgetsForTwoLines = WidgetMaker(textRichMaker, oneTextMaker).parse('''
how does he behave?

While describing this
''');
    expect(widgetsForTwoLines.length, equals(2));
  });
}
