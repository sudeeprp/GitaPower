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
}
