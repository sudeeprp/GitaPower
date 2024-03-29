import 'package:askys/begin_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

void main() {
  testWidgets('three choices are visible to begin', (WidgetTester tester) async {
    await tester.pumpWidget(const GetMaterialApp(home: BeginWidget()));
    expect(find.byKey(const Key('begin/notes')).hitTestable(), findsOneWidget);
    expect(find.byKey(const Key('begin/feed')).hitTestable(), findsOneWidget);
    expect(find.byKey(const Key('begin/chapters')).hitTestable(), findsOneWidget);
  });
  testWidgets('begin-item switches to content when tapped', (WidgetTester tester) async {
    bool switchedToTargetWidget = false;
    await tester.pumpWidget(GetMaterialApp(
        home: Column(children: [
          beginItem(
              'chapters', 'Start chapter by chapter', Image.asset('images/begin-chapters.png'),
              key: const Key('begin-to-tap'))
        ]),
        getPages: [
          GetPage(
              name: '/chapters',
              page: () {
                switchedToTargetWidget = true;
                return const Text('target of chapter');
              })
        ]));
    await tester.tap(find.byWidgetPredicate(
        (widget) => widget is RichText && widget.text.toPlainText().contains('chapters')));
    await tester.pump();
    expect(switchedToTargetWidget, equals(true));
  });
}
