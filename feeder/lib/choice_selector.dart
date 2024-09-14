import 'package:askys/feedcontent.dart';
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
  var theme = ThemeMode.system == ThemeMode.dark ? ReadingTheme.dark.obs : ReadingTheme.light.obs;
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
      storeAllPreferences();
    });
    script.listen((_) => storeAllPreferences());
    meaningMode.listen((_) => storeAllPreferences());
    headPreference.listen((_) => storeAllPreferences());
    try {
      final storedPreferences = await SharedPreferences.getInstance();
      theme.value = _fromStored(ReadingTheme.values, storedPreferences.getString('theme'), theme.value);
      script.value =
          _fromStored(ScriptPreference.values, storedPreferences.getString('script'), script.value);
      meaningMode.value =
          _fromStored(MeaningMode.values, storedPreferences.getString('meaning'), meaningMode.value);
      headPreference.value =
          _fromStored(HeadPreference.values, storedPreferences.getString('head'), headPreference.value);
    } catch (e) {
      // ignore: avoid_print
      print(e);
    }
    super.onInit();
  }
}

class ThemeSelectionIcon extends StatelessWidget {
  const ThemeSelectionIcon({super.key});

  @override
  Widget build(BuildContext context) {
    final Choices choice = Get.find();
    return GestureDetector(
      onTap: () => choice.theme.value =
          choice.theme.value == ReadingTheme.light ? ReadingTheme.dark : ReadingTheme.light,
      child: Obx((() {
        final Choices choices = Get.find();
        return choices.theme.value == ReadingTheme.light
            ? const Icon(Icons.dark_mode_outlined, color: Colors.black, size: 48)
            : const Icon(Icons.light_mode_outlined, color: Colors.grey, size: 48);
      })),
    );
  }
}

class ScriptSelectionIcon extends StatelessWidget {
  const ScriptSelectionIcon({super.key});

  @override
  Widget build(BuildContext context) {
    final Choices choice = Get.find();
    return GestureDetector(
      onTap: () {
        choice.headPreference.value = HeadPreference.shloka;
        choice.script.value = choice.script.value == ScriptPreference.devanagari
            ? ScriptPreference.sahk
            : ScriptPreference.devanagari;
      },
      child: Image.asset('images/translate.png', width: 48, height: 48),
    );
  }
}

class MeaningExpansionIcon extends StatelessWidget {
  const MeaningExpansionIcon({super.key});

  @override
  Widget build(BuildContext context) {
    final Choices choice = Get.find();
    return GestureDetector(
      onTap: () => choice.meaningMode.value =
          choice.meaningMode.value == MeaningMode.short ? MeaningMode.expanded : MeaningMode.short,
      child: Obx(() {
        final Choices choices = Get.find();
        return Image.asset(
            choices.theme.value == ReadingTheme.light
                ? 'images/expand_meaning_light.png'
                : 'images/expand_meaning_dark.png',
            width: 48,
            height: 48);
      }),
    );
  }
}

class HeaderPreferenceIcon extends StatelessWidget {
  const HeaderPreferenceIcon({super.key});

  @override
  Widget build(BuildContext context) {
    final Choices choice = Get.find();
    return GestureDetector(
      onTap: () => choice.headPreference.value = choice.headPreference.value == HeadPreference.shloka
          ? HeadPreference.meaning
          : HeadPreference.shloka,
      child: Obx(() {
        final Choices choices = Get.find();
        return Image.asset(
            choices.theme.value == ReadingTheme.light
                ? 'images/shloka_visible_light.png'
                : 'images/shloka_visible_dark.png',
            width: 48,
            height: 48);
      }),
    );
  }
}

class OpenerPreferenceIcon extends StatelessWidget {
  const OpenerPreferenceIcon({super.key});

  @override
  Widget build(BuildContext context) {
    final FeedContent feedContent = Get.find();
    return GestureDetector(
      onTap: feedContent.toggleOpenerCovers,
      child: Image.asset('images/opener_cover.png', width: 48, height: 48),
    );
  }
}
