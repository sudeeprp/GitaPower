import 'package:askys/content_themes.dart';
import 'package:askys/feedcontent.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum ReadingTheme { dark, light }

enum ScriptPreference { devanagari, sahk }

enum MeaningMode { short, expanded }

enum HeadPreference { shloka, meaning }

enum BrowsingPreference { chapters, notes }

Future<void> storePreferences(ReadingTheme theme, ScriptPreference script, MeaningMode meaningMode,
    HeadPreference headPreference, BrowsingPreference browsingPreference) async {
  final storedPreferences = await SharedPreferences.getInstance();
  storedPreferences.setString('theme', EnumToString.convertToString(theme));
  storedPreferences.setString('script', EnumToString.convertToString(script));
  storedPreferences.setString('meaning', EnumToString.convertToString(meaningMode));
  storedPreferences.setString('head', EnumToString.convertToString(headPreference));
  storedPreferences.setString('browsing', EnumToString.convertToString(browsingPreference));
}

T _fromStored<T>(List<T> enumValues, String? storedValue, T defaultValue) {
  try {
    if (storedValue != null) {
      final storedEnum = EnumToString.fromString(enumValues, storedValue);
      return storedEnum ?? defaultValue;
    }
  } finally {}
  return defaultValue;
}

class Choices extends GetxController {
  var theme = ThemeMode.system == ThemeMode.dark ? ReadingTheme.dark.obs : ReadingTheme.light.obs;
  var script = ScriptPreference.devanagari.obs;
  var meaningMode = MeaningMode.short.obs;
  var headPreference = HeadPreference.shloka.obs;
  var browsingPreference = BrowsingPreference.chapters.obs;
  final appearanceChoices = {
    ReadingTheme.dark: ThemeMode.dark,
    ReadingTheme.light: ThemeMode.light,
  };
  Future<void> storeAllPreferences() async {
    await storePreferences(
        theme.value, script.value, meaningMode.value, headPreference.value, browsingPreference.value);
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
    browsingPreference.listen((_) => storeAllPreferences());
    try {
      final storedPreferences = await SharedPreferences.getInstance();
      theme.value = _fromStored(ReadingTheme.values, storedPreferences.getString('theme'), theme.value);
      script.value =
          _fromStored(ScriptPreference.values, storedPreferences.getString('script'), script.value);
      meaningMode.value =
          _fromStored(MeaningMode.values, storedPreferences.getString('meaning'), meaningMode.value);
      headPreference.value =
          _fromStored(HeadPreference.values, storedPreferences.getString('head'), headPreference.value);
      browsingPreference.value = _fromStored(
          BrowsingPreference.values, storedPreferences.getString('browsing'), browsingPreference.value);
    } catch (e) {
      // ignore: avoid_print
      print(e);
    }
    super.onInit();
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
      child: Image.asset('images/expand_meaning${contentAssetSuffix(context)}.png', width: 48, height: 48),
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
      child: Image.asset('images/shloka_visible${contentAssetSuffix(context)}.png', width: 48, height: 48),
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

class BrowsingPreferenceIcon extends StatelessWidget {
  const BrowsingPreferenceIcon(this.browsingPreference, this.iconFile, {super.key});

  final BrowsingPreference browsingPreference;
  final String iconFile;

  @override
  Widget build(BuildContext context) {
    final Choices choice = Get.find();
    return GestureDetector(
      onTap: () {
        choice.browsingPreference.value = browsingPreference;
      },
      child: Obx(() {
        final boxShadow = choice.browsingPreference.value == browsingPreference
            ? BoxShadow(
                color: Colors.blue.withValues(alpha: 0.3),
                offset: const Offset(0, 4),
                blurRadius: 10,
              )
            : BoxShadow(
                color: Colors.grey.withValues(alpha: 0.2),
                offset: const Offset(0, 2),
                blurRadius: 6,
              );
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            // color: isSelected ? Colors.blue : Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [boxShadow],
          ),
          child: Image.asset(iconFile, width: 48, height: 48),
        );
      }),
    );
  }
}

class PersonalizeIcon extends StatelessWidget {
  const PersonalizeIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.toNamed('/personalize'),
      child: const Icon(Icons.settings, size: 48),
    );
  }
}
