import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:askys/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Generate Play Store screenshots', (WidgetTester tester) async {
    await tester.pumpWidget(makeMyHome());
    await tester.pumpAndSettle();
    
    // Take screenshot of home screen
    await takeScreenshot('home_screen', tester);
    
    // Example of navigating and taking more screenshots
    /*
    await tester.tap(find.byKey(Key('settings_button')));
    await tester.pumpAndSettle();
    await takeScreenshot('settings_screen', tester);
    */
  });
}

Future<void> takeScreenshot(String name, WidgetTester tester) async {
  await tester.pumpAndSettle();

  final RenderRepaintBoundary boundary = 
      tester.renderObject(find.byType(RepaintBoundary).first);
  final ui.Image image = await boundary.toImage();
  final ByteData? byteData = 
      await image.toByteData(format: ui.ImageByteFormat.png);
  
  if (byteData != null) {
    final directory = Directory('screenshots');
    if (!directory.existsSync()) {
      directory.createSync();
    }

    final File file = File('screenshots/$name.png');
    await file.writeAsBytes(byteData.buffer.asUint8List());
  }
}