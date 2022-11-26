import 'package:askys/choice_selector.dart';
import 'package:askys/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Navigates to settings from the home screen',
      (WidgetTester tester) async {
    await tester.pumpWidget(makeMyHome());
    await tester.tap(find.byKey(const Key('home/settingsicon')));
    await tester.pumpAndSettle();
    expect(find.byType(ChoiceSelector), findsOneWidget);
  });
}
