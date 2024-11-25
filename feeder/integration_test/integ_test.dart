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
      Future<void> screenIt(WidgetTester tester, String screenName, {String? filename}) async {
        Choices choices = Get.find();
        choices.theme.value = theme;
        await tester.pumpAndSettle();

        await binding.convertFlutterSurfaceToImage();
        await tester.pumpAndSettle();
        filename ??= screenshotFilename(screenName, theme);
        await binding.takeScreenshot(filename);
      }

      testWidgets('home screenshot - ${theme.toString()}', (tester) async {
        await tester.pumpWidget(makeMyHome());
        await screenIt(tester, 'home');
      });
      testWidgets('browse chapters screenshot - ${theme.toString()}', (tester) async {
        await tester.pumpWidget(makeMyHome());
        Choices choices = Get.find();
        choices.browsingPreference.value = BrowsingPreference.chapters;
        await tester.pumpAndSettle();
        Get.offNamed('/browse');
        await tester.pumpAndSettle();
        await screenIt(tester, 'browse-chapters');
      });
      testWidgets('browse notes screenshot - ${theme.toString()}', (tester) async {
        await tester.pumpWidget(makeMyHome());
        Choices choices = Get.find();
        choices.browsingPreference.value = BrowsingPreference.notes;
        await tester.pumpAndSettle();
        Get.offNamed('/browse');
        await tester.pumpAndSettle();
        await screenIt(tester, 'browse-notes');
      });
      for (final screen in ['/tour', '/feed', '/shlokaheaders/Chapter_4.md', '/shloka/4-4.md']) {
        testWidgets('$screen screenshot - ${theme.toString()}', (tester) async {
          await tester.pumpWidget(makeMyHome());
          Get.offNamed(screen);
          await tester.pumpAndSettle();
          await screenIt(tester, screen);
        });
      }
    }
  });
}

String screenshotFilename(String screenName, ReadingTheme theme) {
  String themeName = theme.toString().replaceAll('ReadingTheme.', '');
  return '${screenName.replaceFirst('/', '').replaceAll(RegExp(r'/.*$'), '')}-$themeName';
}
