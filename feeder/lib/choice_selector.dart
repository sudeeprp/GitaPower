import 'package:flutter/material.dart';
import 'package:get/get.dart';

enum ReadingTheme {
  dark,
  light,
  classic,
}

enum MeaningMode {
  short,
  expanded,
}

enum ScriptPreference {
  devanagari,
  sahk,
}

class Choices extends GetxController {
  static const codeColorForLight = Color(0xFF800000);
  static final codeColorForDark = Colors.deepOrange.shade900.withOpacity(0.9);
  var theme = ReadingTheme.light.obs;
  var codeColor = Rx<Color>(codeColorForLight);
  var script = ScriptPreference.devanagari.obs;
  var meaningMode = MeaningMode.short.obs;
  final appearanceChoices = {
    ReadingTheme.dark: ThemeData.dark(),
    ReadingTheme.light: ThemeData.light(),
  };
  @override
  void onInit() {
    theme.listen((themeValue) {
      Get.changeTheme(appearanceChoices[themeValue]!);
      codeColor.value = themeValue == ReadingTheme.dark ? codeColorForDark : codeColorForLight;
    });
    super.onInit();
  }
}

class ThemeSelector extends StatelessWidget {
  const ThemeSelector({Key? key}) : super(key: key);

  @override
  Widget build(context) {
    final Choices choice = Get.find();
    return Row(children: [
      const Text('Light'),
      Obx(() => Switch(
          value: choice.theme.value == ReadingTheme.dark,
          onChanged: (bool newValue) {
            choice.theme.value = newValue ? ReadingTheme.dark : ReadingTheme.light;
          })),
      const Text('Dark'),
    ]);
  }
}

class ScriptSelector extends StatelessWidget {
  const ScriptSelector({super.key});

  @override
  Widget build(context) {
    Choices choice = Get.find();
    return Row(children: [
      const Text('bhakti'),
      Obx(() => Switch(
          value: choice.script.value == ScriptPreference.devanagari,
          onChanged: (bool newValue) {
            choice.script.value = newValue ? ScriptPreference.devanagari : ScriptPreference.sahk;
          })),
      const Text('भक्ति'),
    ]);
  }
}
