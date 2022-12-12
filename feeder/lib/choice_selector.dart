import 'package:flutter/material.dart';
import 'package:get/get.dart';

enum ReadingTheme {
  dark,
  light,
  classic,
}

class ThemePick {
  ThemePick(this.name, this.theme, this.flutterTheme,
      {required this.shlokaColor, required this.shlokaBackground});
  final String name;
  final ReadingTheme theme;
  final ThemeData flutterTheme;
  final Color shlokaColor;
  final AssetImage shlokaBackground;
}

final appearanceChoices = {
  ReadingTheme.dark: ThemePick('Dark', ReadingTheme.dark, ThemeData.dark(),
      shlokaColor: const Color(0xff800000),
      shlokaBackground: const AssetImage('images/snskrtstationary.png')),
  ReadingTheme.light: ThemePick('Light', ReadingTheme.light, ThemeData.light(),
      shlokaColor: const Color.fromARGB(255, 41, 0, 128),
      shlokaBackground: const AssetImage('images/snskrtstationary.png')),
  ReadingTheme.classic: ThemePick(
      'Classic', ReadingTheme.classic, ThemeData.light(),
      shlokaColor: const Color(0xff800000),
      shlokaBackground: const AssetImage('images/snskrtstationary.png')),
};
const defaultAppearance = ReadingTheme.classic;

class Choices extends GetxController {
  var theme = defaultAppearance.obs;
  @override
  void onInit() {
    theme.listen((themeValue) {
      Get.changeTheme(appearanceChoices[themeValue]!.flutterTheme);
    });
    super.onInit();
  }
}

class TextSample extends StatelessWidget {
  final ThemePick _themePick;
  const TextSample(this._themePick, {Key? key}) : super(key: key);
  Widget _sampleTextContent() {
    return Column(children: [
      Text(
        _themePick.name,
        style: TextStyle(
            backgroundColor:
                _themePick.flutterTheme.textTheme.bodyText2!.backgroundColor,
            color: _themePick.flutterTheme.textTheme.bodyText2!.color),
        textScaleFactor: 1.5,
      ),
      Container(
          decoration: BoxDecoration(
              image: DecorationImage(
                  image: _themePick.shlokaBackground, fit: BoxFit.fill)),
          child: Text('मा शुच​:',
              style: TextStyle(color: _themePick.shlokaColor),
              textScaleFactor: 1.5)),
    ]);
  }

  @override
  Widget build(context) {
    Choices c = Get.find();
    return Obx(() => Expanded(
        child: InkWell(
            child: Container(
              key: Key('sample/${_themePick.name}'),
              margin: const EdgeInsets.all(5.0),
              padding: const EdgeInsets.all(2.0),
              decoration: (c.theme.value == _themePick.theme)
                  ? BoxDecoration(border: Border.all(color: Colors.blueAccent))
                  : null,
              child: Container(
                color: _themePick
                    .flutterTheme.textTheme.bodyText2!.backgroundColor,
                margin: const EdgeInsets.all(3.0),
                padding: const EdgeInsets.all(2.0),
                child: _sampleTextContent(),
              ),
            ),
            onTap: () => {c.theme.value = _themePick.theme})));
  }
}

class ThemeSelector extends StatelessWidget {
  const ThemeSelector({Key? key}) : super(key: key);

  @override
  Widget build(context) {
    return Row(children: [
      TextSample(appearanceChoices[ReadingTheme.dark]!),
      TextSample(appearanceChoices[ReadingTheme.light]!),
      TextSample(appearanceChoices[ReadingTheme.classic]!)
    ]);
  }
}

class ChoiceSelector extends StatelessWidget {
  const ChoiceSelector({Key? key}) : super(key: key);

  @override
  Widget build(context) {
    return Scaffold(
        appBar: AppBar(
          leading: const Icon(Icons.album),
          title: const Text('Preferences'),
        ),
        body: Column(children: const [
          Text('Version: textspans'),
          ThemeSelector(key: Key('theme-selector')),
        ]));
  }
}
