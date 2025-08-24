import 'package:askys/begin_widget.dart';
import 'package:askys/content_source.dart';
import 'package:askys/feedcontent.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

void main() {
  testWidgets('tour or browse at the start', (WidgetTester tester) async {
    Get.put(GitHubFetcher(Dio()));
    Get.put(PlayablesTOC());
    await tester.pumpWidget(const GetMaterialApp(home: Scaffold(body: BeginWidget())));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('begin/browse')).hitTestable(), findsOneWidget);
    expect(find.byKey(const Key('begin/guides')).hitTestable(), findsOneWidget);
    Get.delete<PlayablesTOC>();
    Get.delete<GitHubFetcher>();
  });
  testWidgets('begin-item switches to content when tapped', (WidgetTester tester) async {
    bool switchedToTargetWidget = false;
    await tester.pumpWidget(GetMaterialApp(
        home: Column(children: [
          beginItem('browse', 'Start chapter by chapter', Image.asset('images/begin-chapters.png'),
              key: const Key('begin-to-tap'))
        ]),
        getPages: [
          GetPage(
              name: '/browse',
              page: () {
                switchedToTargetWidget = true;
                return const Text('target of browse');
              })
        ]));
    await tester.tap(find
        .byWidgetPredicate((widget) => widget is RichText && widget.text.toPlainText().contains('browse')));
    await tester.pump();
    expect(switchedToTargetWidget, equals(true));
  });
}
