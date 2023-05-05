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
  var theme = ReadingTheme.light.obs;
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
      const Text('Dark'),
      Obx(() => Switch(
          value: choice.theme.value == ReadingTheme.dark,
          onChanged: (bool newValue) {
            choice.theme.value = newValue ? ReadingTheme.dark : ReadingTheme.light;
          })),
      const Text('Light'),
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
