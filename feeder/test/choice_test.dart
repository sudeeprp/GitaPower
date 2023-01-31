import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:askys/choice_selector.dart';
import 'package:get/get.dart';

bool containerIsSelected(Container c) {
  return c.decoration != null &&
      (c.decoration as BoxDecoration).border?.bottom.color.value != null;
}

void main() {
  testWidgets('Shows initial default theme as Classic',
      (WidgetTester tester) async {
    Get.put(Choices());
    await tester.pumpWidget(const MaterialApp(home: ChoiceSelector()));

    final classicChoiceFinder = find.byKey(const Key('sample/Classic'));
    expect(classicChoiceFinder, findsOneWidget);
    expect(containerIsSelected(tester.widget<Container>(classicChoiceFinder)),
        true);
    Get.delete<Choices>();
  });
  testWidgets('Shows the chosen theme from last selection',
      (WidgetTester tester) async {
    final choices = Choices();
    choices.theme.value = ReadingTheme.dark;
    Get.put(choices);
    await tester.pumpWidget(const MaterialApp(home: ChoiceSelector()));
    final lastChoiceFinder = find.byKey(const Key('sample/Dark'));
    expect(lastChoiceFinder, findsOneWidget);
    expect(
        containerIsSelected(tester.widget<Container>(lastChoiceFinder)), true);
    Get.delete<Choices>();
  });
  testWidgets('Switches the selection based on the choice',
      (WidgetTester tester) async {
    final choices = Choices();
    choices.script.value = ScriptPreference.devanagari;
    Get.put(choices);
    await tester.pumpWidget(const MaterialApp(home: ChoiceSelector()));
    expect(
        containerIsSelected(
            tester.widget<Container>(find.byKey(const Key('sample/Classic')))),
        true);
    choices.theme.value = ReadingTheme.light;
    await tester.pump();
    expect(
        containerIsSelected(
            tester.widget<Container>(find.byKey(const Key('sample/Classic')))),
        false);
    expect(
        containerIsSelected(
            tester.widget<Container>(find.byKey(const Key('sample/Light')))),
        true);
    await tester.tap(find.byType(Switch));
    await tester.pump();
    expect(choices.script.value, equals(ScriptPreference.sahk));
    Get.delete<Choices>();
  });
  testWidgets('Records the users theme', (WidgetTester tester) async {
    final choices = Choices();
    Get.put(choices);
    await tester.pumpWidget(const MaterialApp(home: ChoiceSelector()));
    await tester.tap(find.byKey(const Key('sample/Dark')));
    await tester.pump();
    expect(choices.theme.value, equals(ReadingTheme.dark));
  });
}
