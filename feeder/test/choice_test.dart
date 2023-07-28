import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:askys/choice_selector.dart';
import 'package:get/get.dart';

void main() {
  testWidgets('theme selector switches the theme', (tester) async {
    final choices = Choices();
    Get.put(choices);
    final initialTheme = choices.theme.value;
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: ThemeSelector())));
    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();
    expect(choices.theme.value, isNot(initialTheme));
    Get.delete<Choices>();
  });
  testWidgets('script selector switches the script preference', (tester) async {
    final choices = Choices();
    Get.put(choices);
    final initialScript = choices.script.value;
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: ScriptSelector())));
    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();
    expect(choices.script.value, isNot(initialScript));
    Get.delete<Choices>();
  });
  testWidgets('header selector switches header preference', (tester) async {
    final choices = Choices();
    Get.put(choices);
    final initialHeaderPref = choices.headPreference.value;
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: HeaderSelector())));
    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();
    expect(choices.headPreference, isNot(initialHeaderPref));
    Get.delete<Choices>();
  });
}
