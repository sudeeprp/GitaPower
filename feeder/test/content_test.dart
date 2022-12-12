import 'package:flutter/material.dart';
import 'package:askys/choice_selector.dart';
import 'package:askys/content_widget.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

void main() {
  testWidgets('Renders a single markdown line as a RichText',
      (WidgetTester tester) async {
    Get.put(Choices());
    final BuildContext context = tester.element(find.byType(Container));
    final widgetWithOneMD = mdToWidgets('one two three', context);
    expect(widgetWithOneMD.length, equals(1));
    await tester
        .pumpWidget(GetMaterialApp(home: Column(children: widgetWithOneMD)));
    expect(find.text('one two three', findRichText: true), findsOneWidget);
  });
  testWidgets('Renders each line as a RichText', (WidgetTester tester) async {
    final BuildContext context = tester.element(find.byType(Container));
    final widgets = mdToWidgets('# Heading\n\nWith some text', context);
    expect(widgets.length, equals(2));
    expect(widgets[0].text.toPlainText(), equals('Heading'));
    expect(widgets[1].text.toPlainText(), equals('With some text'));
  });
  testWidgets('Renders text with inline code in one RichText',
      (WidgetTester tester) async {
    final BuildContext context = tester.element(find.byType(Container));
    final widgets = mdToWidgets('Text with `code`', context);
    expect(widgets.length, equals(1));
    expect(widgets[0].text.toPlainText(), equals('Text with code'));
  });
}
