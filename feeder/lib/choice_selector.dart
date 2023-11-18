import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum ReadingTheme { dark, light }

enum ScriptPreference { devanagari, sahk }

enum MeaningMode { short, expanded }

enum HeadPreference { shloka, meaning }

Future<void> storePreferences(ReadingTheme theme, ScriptPreference script, MeaningMode meaningMode,
    HeadPreference headPreference) async {
  final storedPreferences = await SharedPreferences.getInstance();
  storedPreferences.setString('theme', EnumToString.convertToString(theme));
  storedPreferences.setString('script', EnumToString.convertToString(script));
  storedPreferences.setString('meaning', EnumToString.convertToString(meaningMode));
  storedPreferences.setString('head', EnumToString.convertToString(headPreference));
}

T _fromStored<T>(List<T> enumValues, String? storedValue, T defaultValue) {
  try {
    if (storedValue != null) {
      final storedEnumd = EnumToString.fromString(enumValues, storedValue);
      return storedEnumd ?? defaultValue;
    }
  } finally {}
  return defaultValue;
}

class Choices extends GetxController {
  static const codeColorForLight = Color(0xFF800000);
  static const codeColorForDark = Color.fromARGB(255, 236, 118, 82);
  var theme = Get.isDarkMode ? ReadingTheme.dark.obs : ReadingTheme.light.obs;
  var codeColor = Get.isDarkMode ? Rx<Color>(codeColorForDark) : Rx<Color>(codeColorForLight);
  var script = ScriptPreference.devanagari.obs;
  var meaningMode = MeaningMode.short.obs;
  var headPreference = HeadPreference.shloka.obs;
  final appearanceChoices = {
    ReadingTheme.dark: ThemeMode.dark,
    ReadingTheme.light: ThemeMode.light,
  };
  Future<void> storeAllPreferences() async {
    await storePreferences(theme.value, script.value, meaningMode.value, headPreference.value);
  }

  @override
  void onInit() async {
    theme.listen((themeValue) {
      Get.changeThemeMode(appearanceChoices[themeValue]!);
      codeColor.value = themeValue == ReadingTheme.dark ? codeColorForDark : codeColorForLight;
      storeAllPreferences();
    });
    script.listen((_) => storeAllPreferences());
    meaningMode.listen((_) => storeAllPreferences());
    headPreference.listen((_) => storeAllPreferences());
    try {
      final storedPreferences = await SharedPreferences.getInstance();
      theme.value =
          _fromStored(ReadingTheme.values, storedPreferences.getString('theme'), theme.value);
      script.value =
          _fromStored(ScriptPreference.values, storedPreferences.getString('script'), script.value);
      meaningMode.value = _fromStored(
          MeaningMode.values, storedPreferences.getString('meaning'), meaningMode.value);
      headPreference.value = _fromStored(
          HeadPreference.values, storedPreferences.getString('head'), headPreference.value);
    } catch (e) {
      // ignore: avoid_print
      print(e);
    }
    super.onInit();
  }
}

Widget _makeSelector(String title, String leftChoice, String rightChoice, Widget child) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 25),
    child: Column(children: [
      Text(title, textScaler: const TextScaler.linear(1.8)),
      Row(children: [
        Expanded(
            child: Text(leftChoice,
                textAlign: TextAlign.right, textScaler: const TextScaler.linear(1.3))),
        Expanded(child: child),
        Expanded(
            child: Text(rightChoice,
                textAlign: TextAlign.left, textScaler: const TextScaler.linear(1.3))),
      ]),
    ]),
  );
}

Widget themeSelector() {
  final Choices choice = Get.find();
  return _makeSelector(
      'Theme',
      'Light',
      'Dark',
      Obx(() => Switch(
          value: choice.theme.value == ReadingTheme.dark,
          onChanged: (bool newValue) {
            choice.theme.value = newValue ? ReadingTheme.dark : ReadingTheme.light;
          })));
}

Widget scriptSelector() {
  final Choices choice = Get.find();
  return _makeSelector(
      'Devanagari',
      'bhakti',
      'भक्ति',
      Obx(() => Switch(
          value: choice.script.value == ScriptPreference.devanagari,
          onChanged: (bool newValue) {
            choice.script.value = newValue ? ScriptPreference.devanagari : ScriptPreference.sahk;
          })));
}

Widget headerSelector() {
  final Choices choice = Get.find();
  return _makeSelector(
      'Header',
      'meaning',
      'shloka',
      Obx(() => Switch(
          value: choice.headPreference.value == HeadPreference.shloka,
          onChanged: (bool newValue) {
            choice.headPreference.value = newValue ? HeadPreference.shloka : HeadPreference.meaning;
          })));
}
