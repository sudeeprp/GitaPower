import 'dart:io';
import 'package:integration_test/integration_test_driver_extended.dart';

Future<bool> screenshotMaker(String screenshotName, List<int> screenshotBytes,
    [Map<String, Object?>? args]) async {
  final File image = await File('screenshots/$screenshotName.png').create(recursive: true);
  image.writeAsBytesSync(screenshotBytes);
  return true;
}

Future<void> main() async {
  await integrationDriver(onScreenshot: screenshotMaker);
}
