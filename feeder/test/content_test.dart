import 'package:flutter/material.dart';
import 'package:askys/choice_selector.dart';
import 'package:askys/content_widget.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

List<Widget> oneTextMaker(String markdown)=> [Text(markdown)];
  
void main() {
  testWidgets('Renders a single markdown line as a RichText',
      (WidgetTester tester) async {
    // Get.put(Choices());
    // final BuildContext context = tester.element(find.byType(Container));
    final widgetWithOneMD = mdToWidgets('one two three', oneTextMaker);
    expect(widgetWithOneMD.length, equals(1));
    await tester
        .pumpWidget(GetMaterialApp(home: Column(children: widgetWithOneMD)));
    expect(find.text('one two three'), findsOneWidget);
  });
  testWidgets('Separates markdown with inline code', (WidgetTester tester) async {
    List<String> mdTexts = [];
    List<Widget> mdTextCollector(String text) {
      mdTexts.add(text);
      return [Text(text)];
    }
    final widgetsWithInlineCode = mdToWidgets('inline `code`', mdTextCollector);
    expect(widgetsWithInlineCode.length, equals(1)); // Needs to be one span with two nested spans
    expect(mdTexts[0], equals('inline '));
    expect(mdTexts[1], equals('code'));
  });
}
