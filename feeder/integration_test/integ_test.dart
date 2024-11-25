// import 'package:askys/choice_selector.dart';
import 'package:askys/home.dart';
import 'package:flutter_test/flutter_test.dart';
// import 'package:get/get.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding();
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  Future<void> screenshot(String name) async {
    await binding.convertFlutterSurfaceToImage();
    await binding.takeScreenshot(name);
  }

  Future<void> captureScreens(WidgetTester tester, String theme) async {
    await tester.pumpAndSettle();
    await screenshot('home-$theme');
    // await Get.offNamed('/tour');
    // await tester.pumpAndSettle();
    // await screenshot('tour-$theme');
  }

  group('end-to-end test', () {
    testWidgets('capture screens', (tester) async {
      await tester.pumpWidget(makeMyHome());
      // Choices choices = Get.find();
      // choices.theme.value = ReadingTheme.light;
      await captureScreens(tester, 'light');
      // choices.theme.value = ReadingTheme.dark;
      // await captureScreens(tester, 'dark');
    });
  });
}
