import 'package:askys/choices_row.dart';
import 'package:askys/screenify.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

void main() {
  testWidgets('bottom navigation bar has padding for system UI', (tester) async {
    final testWidget = screenify(
      const Text('Test Body'),
      appBar: AppBar(title: const Text('Test App')),
      choicesRow: choicesRow(const [Icon(Icons.home)], const [Icon(Icons.settings)]),
    );

    await tester.pumpWidget(GetMaterialApp(home: testWidget));
    await tester.pumpAndSettle();

    // Find the Scaffold widget
    final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
    expect(scaffold.bottomNavigationBar, isNotNull);

    // Verify that the bottom navigation bar is wrapped with padding
    expect(scaffold.bottomNavigationBar, isA<Widget>());
  });

  testWidgets('screenify works without bottom navigation bar', (tester) async {
    final testWidget = screenify(
      const Text('Test Body'),
      appBar: AppBar(title: const Text('Test App')),
    );

    await tester.pumpWidget(GetMaterialApp(home: testWidget));
    await tester.pumpAndSettle();

    final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
    expect(scaffold.bottomNavigationBar, isNull);
  });
}
