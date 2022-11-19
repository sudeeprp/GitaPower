import 'package:flutter/material.dart';
import 'package:get/get.dart';

enum ReadingTheme {
  dark,
  light,
  classic,
}

class ThemePick {
  ThemePick(this.name, this.theme, {this.background, this.textColor, this.imagerep});
  final String name;
  final Color? background;
  final Color? textColor;
  final ReadingTheme theme;
  final Image? imagerep;
}

final darkTheme = ThemePick('Dark', ReadingTheme.dark, background: Colors.black, textColor: Colors.white);
final lightTheme = ThemePick('Light', ReadingTheme.light, background: Colors.white, textColor: Colors.black);
final classicTheme = ThemePick('Classic', ReadingTheme.classic, background: const Color(0xfff5f5dc), textColor: Colors.black);

class Choices extends GetxController {
  var theme = ReadingTheme.classic.obs;
}

class TextSample extends StatelessWidget {
  final ThemePick _themePick;
  const TextSample(this._themePick, {Key? key}) : super(key: key);
  Widget _sampleTextContent() {
    return RichText(text: TextSpan(children: [
      WidgetSpan(child: Text(_themePick.name, style: TextStyle(backgroundColor: _themePick.background, color: _themePick.textColor),
            textScaleFactor: 1.5,))
    ]));
  }
  @override
  Widget build(context) {
    Choices c = Get.find();
    return Obx(()=> Expanded(child: InkWell(child: 
      Container(key: Key('sample/${_themePick.name}'), margin: const EdgeInsets.all(5.0), padding: const EdgeInsets.all(2.0),
        decoration: (c.theme.value == _themePick.theme) ? BoxDecoration(border: Border.all(color: Colors.blueAccent)) : null,
        child: Container(color: _themePick.background, margin: const EdgeInsets.all(3.0), padding: const EdgeInsets.all(2.0),
          child: _sampleTextContent(),
        ),
      ), onTap: ()=> {c.theme.value = _themePick.theme})));
  }
}

class ThemeSelector extends StatelessWidget {
  const ThemeSelector({Key? key}) : super(key: key);

  @override
  Widget build(context) {
    return Row(children: [TextSample(darkTheme), TextSample(lightTheme), TextSample(classicTheme)]);
  }
}

class ChoiceSelector extends StatelessWidget {
  const ChoiceSelector({Key? key}) : super(key: key);

  @override
  Widget build(context) {
    return Scaffold(
      appBar: AppBar(leading: const Icon(Icons.album), title: const Text('Preferences'),),
      body: Column(children: const [
        ThemeSelector(key: Key('theme-selector')),
    ]));
  }
}
