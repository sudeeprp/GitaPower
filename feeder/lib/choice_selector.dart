import 'package:flutter/material.dart';
import 'package:get/get.dart';

enum Theme {
  dark,
  light,
  classic,
}

class ThemePick {
  ThemePick(this.name, this.theme, {this.background, this.textColor, this.imagerep});
  final String name;
  final Color? background;
  final Color? textColor;
  final Theme? theme;
  final Image? imagerep;
}

final darkTheme = ThemePick('Dark', Theme.dark, background: Colors.black, textColor: Colors.white);
final lightTheme = ThemePick('Light', Theme.light, background: Colors.white, textColor: Colors.black);
final classicTheme = ThemePick('Classic', Theme.classic, background: Colors.yellow.shade700, textColor: Colors.black12);

class Choices extends GetxController {
  var theme = Theme.classic.obs;
}

class TextSample extends StatelessWidget {
  final ThemePick _themePick;
  const TextSample(this._themePick, {Key? key}) : super(key: key);
  
  @override
  Widget build(context) {
    Choices c = Get.find();
    BoxDecoration? boxOutline;
    if (c.theme.value == _themePick.theme) {
      boxOutline = BoxDecoration(border: Border.all(color: Colors.blueAccent));
    }
    return Expanded(
      child: Container(margin: const EdgeInsets.all(5.0), padding: const EdgeInsets.all(2.0),
        decoration: boxOutline,
        child: Container(color: _themePick.background, margin: const EdgeInsets.all(3.0), padding: const EdgeInsets.all(2.0),
          child: Text(_themePick.name, style: TextStyle(backgroundColor: _themePick.background, color: _themePick.textColor),
            textScaleFactor: 1.5,),
    )));
  }
}

class ChoiceSelector extends StatelessWidget {
  const ChoiceSelector({Key? key}) : super(key: key);

  @override
  Widget build(context) {
    return Scaffold(
      appBar: AppBar(leading: const Icon(Icons.album), title: const Text('Preferences'),),
      body: Column(children: [
        Row(children: [TextSample(darkTheme), TextSample(lightTheme), TextSample(classicTheme)]),
    ]));
  }
}
