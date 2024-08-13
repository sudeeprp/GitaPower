import 'package:askys/tell_if_error.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';

void main() {
  testWidgets('does not crash on player related errors', (tester) async {
    await tester.pumpWidget(const GetMaterialApp(home: Scaffold(body: Text('home'))));
    void testError(dynamic exceptionInstance) async {
      await tellIfError(() async {
        throw exceptionInstance;
      }, durationToShow: const Duration(milliseconds: 50));
    }

    testError(PlayerException(500, 'player exception'));
    testError(PlayerInterruptedException('player exception'));
    testError('some unknown exception');
    await tester.pumpAndSettle();
  });
}
