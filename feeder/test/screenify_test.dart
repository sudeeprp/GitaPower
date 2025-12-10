import 'package:askys/choices_row.dart';
import 'package:askys/screenify.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

void main() {
  testWidgets('bottom navigation bar present on screen', (tester) async {
    final testWidget = screenify(
      const Text('Test Body'),
      appBar: AppBar(title: const Text('Test App')),
      choicesRow: choicesRow(const [Icon(Icons.home)], const [Icon(Icons.settings)]),
    );

    await tester.pumpWidget(GetMaterialApp(home: testWidget));
    await tester.pumpAndSettle();

    final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
    expect(scaffold.bottomNavigationBar, isNotNull);
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
