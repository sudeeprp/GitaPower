import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:askys/choice_selector.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:enum_to_string/enum_to_string.dart';

void main() {
  testWidgets('expansion icon toggles shloka between meaning', (tester) async {
    final choices = Choices();
    Get.put(choices);
    final initialExpandMode = choices.meaningMode.value;
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: MeaningExpansionIcon())));
    await tester.tap(find.byType(MeaningExpansionIcon));
    await tester.pumpAndSettle();
    expect(choices.script.value, isNot(initialExpandMode));
    Get.delete<Choices>();
  });
  testWidgets('header preference icon toggles shloka visibility', (tester) async {
    final choices = Choices();
    Get.put(choices);
    final initialHeadPreference = choices.headPreference.value;
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: HeaderPreferenceIcon())));
    await tester.tap(find.byType(HeaderPreferenceIcon));
    await tester.pumpAndSettle();
    expect(choices.script.value, isNot(initialHeadPreference));
    Get.delete<Choices>();
  });
  testWidgets('browsing preference icon sets the browsing preference', (tester) async {
    final choices = Choices();
    choices.browsingPreference.value = BrowsingPreference.chapters;
    Get.put(choices);
    await tester.pumpWidget(const MaterialApp(
        home: Scaffold(body: BrowsingPreferenceIcon(BrowsingPreference.notes, 'images/one-step.png'))));
    final browsingPrefer = find.byType(BrowsingPreferenceIcon);
    await tester.tap(browsingPrefer);
    await tester.pumpAndSettle();
    expect(choices.browsingPreference.value, equals(BrowsingPreference.notes));
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
      'browsing': EnumToString.convertToString(BrowsingPreference.notes),
    };
    SharedPreferences.setMockInitialValues(values);
    Get.put(Choices());
    final Choices choices = Get.find();
    await tester.pumpAndSettle();
    expect(choices.theme.value, equals(ReadingTheme.dark));
    expect(choices.script.value, equals(ScriptPreference.sahk));
    expect(choices.meaningMode.value, equals(MeaningMode.expanded));
    expect(choices.headPreference.value, equals(HeadPreference.meaning));
    expect(choices.browsingPreference.value, equals(BrowsingPreference.notes));
    Get.delete<Choices>();
  });
  testWidgets('persists preferences', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    await storePreferences(ReadingTheme.light, ScriptPreference.sahk, MeaningMode.short,
        HeadPreference.shloka, BrowsingPreference.chapters);
    expect(preferences.getString('theme'), equals(EnumToString.convertToString(ReadingTheme.light)));
    expect(preferences.getString('script'), equals(EnumToString.convertToString(ScriptPreference.sahk)));
    expect(preferences.getString('meaning'), equals(EnumToString.convertToString(MeaningMode.short)));
    expect(preferences.getString('head'), equals(EnumToString.convertToString(HeadPreference.shloka)));
    expect(
        preferences.getString('browsing'), equals(EnumToString.convertToString(BrowsingPreference.chapters)));
  });
  testWidgets('persists preferences when changed', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    Get.put(Choices());
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: HeaderPreferenceIcon())));
    await tester.tap(find.byType(HeaderPreferenceIcon));
    await tester.pumpAndSettle();
    expect(preferences.getString('head'), isNotNull);
    Get.delete<Choices>();
  });
}
