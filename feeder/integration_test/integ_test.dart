import 'package:get/get.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:askys/home.dart';
import 'package:askys/choice_selector.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding();
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('end-to-end test', () {
    for (final theme in [ReadingTheme.light, ReadingTheme.dark]) {
      Future<void> screenIt(WidgetTester tester, String screenName) async {
        await tester.pumpWidget(makeMyHome());
        await tester.pumpAndSettle();
        if (screenName != 'home') {
          Get.offNamed(screenName);
        }
        Choices choices = Get.find();

        choices.theme.value = theme;
        await tester.pumpAndSettle();

        await binding.convertFlutterSurfaceToImage();
        await tester.pumpAndSettle();
        await binding.takeScreenshot(screenshotFilename(screenName, theme));
      }
      for (final screen in ['home', '/tour', '/feed', '/shlokaheaders/Chapter_4.md', '/shloka/4-4.md']) {
        testWidgets('$screen screenshot - ${theme.toString()}', (tester) async {
          await screenIt(tester, screen);
        });
      }
    }
  });
}

String screenshotFilename(String screenName, ReadingTheme theme) {
  return
   '${screenName.replaceFirst('/', '').replaceAll(RegExp(r'/.*$'), '')}-${theme.toString().replaceAll('ReadingTheme.', '')}';
}