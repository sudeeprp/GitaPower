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
  static final codeColorForDark = const Color.fromARGB(255, 236, 118, 82).withOpacity(0.9);
  var theme = Get.isDarkMode ? ReadingTheme.dark.obs : ReadingTheme.light.obs;
  var codeColor = Get.isDarkMode ? Rx<Color>(codeColorForDark) : Rx<Color>(codeColorForLight);
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
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 25),
        child: Column(children: [
          const Text('Theme', textScaleFactor: 2.5),
          Row(children: [
            const Expanded(child: Text('Light', textAlign: TextAlign.right, textScaleFactor: 2)),
            Expanded(
                child: Obx(() => Switch(
                    value: choice.theme.value == ReadingTheme.dark,
                    onChanged: (bool newValue) {
                      choice.theme.value = newValue ? ReadingTheme.dark : ReadingTheme.light;
                    }))),
            const Expanded(child: Text('Dark', textAlign: TextAlign.left, textScaleFactor: 2)),
          ]),
        ]));
  }
}

class ScriptSelector extends StatelessWidget {
  const ScriptSelector({super.key});

  @override
  Widget build(context) {
    Choices choice = Get.find();
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 25),
        child: Column(children: [
          const Text('Devanagari', textScaleFactor: 2.5),
          Row(children: [
            const Expanded(child: Text('bhakti', textAlign: TextAlign.right, textScaleFactor: 2)),
            Expanded(
                child: Obx(() => Switch(
                    value: choice.script.value == ScriptPreference.devanagari,
                    onChanged: (bool newValue) {
                      choice.script.value =
                          newValue ? ScriptPreference.devanagari : ScriptPreference.sahk;
                    }))),
            const Expanded(child: Text('भक्ति', textAlign: TextAlign.left, textScaleFactor: 2)),
          ]),
        ]));
  }
}
