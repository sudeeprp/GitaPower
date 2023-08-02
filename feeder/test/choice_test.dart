import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:askys/choice_selector.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:enum_to_string/enum_to_string.dart';

void main() {
  testWidgets('theme selector switches the theme', (tester) async {
    final choices = Choices();
    Get.put(choices);
    final initialTheme = choices.theme.value;
    await tester.pumpWidget(MaterialApp(home: Scaffold(body: themeSelector())));
    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();
    expect(choices.theme.value, isNot(initialTheme));
    Get.delete<Choices>();
  });
  testWidgets('script selector switches the script preference', (tester) async {
    final choices = Choices();
    Get.put(choices);
    final initialScript = choices.script.value;
    await tester.pumpWidget(MaterialApp(home: Scaffold(body: scriptSelector())));
    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();
    expect(choices.script.value, isNot(initialScript));
    Get.delete<Choices>();
  });
  testWidgets('header selector switches header preference', (tester) async {
    final choices = Choices();
    Get.put(choices);
    final initialHeaderPref = choices.headPreference.value;
    await tester.pumpWidget(MaterialApp(home: Scaffold(body: headerSelector())));
    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();
    expect(choices.headPreference, isNot(initialHeaderPref));
    Get.delete<Choices>();
  });
  testWidgets('initializes defaults when nothing was stored', (tester) async {
    final choices = Choices();
    expect(choices.theme.value, equals(ReadingTheme.light));
    expect(choices.script.value, equals(ScriptPreference.devanagari));
    expect(choices.meaningMode.value, equals(MeaningMode.short));
    expect(choices.headPreference.value, equals(HeadPreference.shloka));
  });
  testWidgets('initializes from stored values', (tester) async {
    final Map<String, Object> values = <String, Object>{
      'theme': EnumToString.convertToString(ReadingTheme.dark),
      'script': EnumToString.convertToString(ScriptPreference.sahk),
      'meaning': EnumToString.convertToString(MeaningMode.expanded),
      'head': EnumToString.convertToString(HeadPreference.meaning),
    };
    SharedPreferences.setMockInitialValues(values);
    Get.put(Choices());
    final Choices choices = Get.find();
    await tester.pumpAndSettle();
    expect(choices.theme.value, equals(ReadingTheme.dark));
    expect(choices.script.value, equals(ScriptPreference.sahk));
    expect(choices.meaningMode.value, equals(MeaningMode.expanded));
    expect(choices.headPreference.value, equals(HeadPreference.meaning));
  });
}
