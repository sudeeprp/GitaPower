import 'package:askys/choice_selector.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

Widget mdToWidgets(String markdown) {
  Choices choices = Get.find();
  return Obx(() => Text(markdown,
      style: TextStyle(
          backgroundColor: appearanceChoices[choices.theme]!.background,
          color: appearanceChoices[choices.theme]!.textColor),
      textScaleFactor: 1.5));
}

class Content extends StatelessWidget {
  const Content({Key? key}) : super(key: key);

  @override
  Widget build(context) {
    return Center(child: mdToWidgets('markdown to be loaded'));
  }
}
