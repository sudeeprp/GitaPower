import 'package:askys/choice_selector.dart';
import 'package:askys/feed_shloka.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

void main() {
  testWidgets('shows shloka feed with header', (tester) async {
    final choices = Choices();
    Get.put(choices);
    await tester.pumpWidget(const GetMaterialApp(home: Scaffold(body: FeedShloka('2-41.md'))));
    expect(find.textContaining('व्यवसायात्मिका'), findsOneWidget);
    choices.headPreference.value = HeadPreference.meaning;
    await tester.pumpAndSettle();
    expect(find.textContaining('intention'), findsOneWidget);
  });
  testWidgets('tap on feed navigates to the content', (tester) async {});
  testWidgets('shows note with feed', (tester) async {});
}
