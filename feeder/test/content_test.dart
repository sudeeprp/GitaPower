import 'package:askys/choice_selector.dart';
import 'package:askys/content_widget.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

void main() {
  testWidgets('Renders all the words in a markdown',
      (WidgetTester tester) async {
    Get.put(Choices());
    await tester.pumpWidget(GetMaterialApp(home: mdToWidgets('one two three')));
  });
}
