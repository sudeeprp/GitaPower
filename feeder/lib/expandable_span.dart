import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ExpansionController extends GetxController {
  final showMeaning = false.obs;
}

Widget expansionTapper(String prompt, ExpansionController expander) {
  return GestureDetector(
      onTap: () {
        expander.showMeaning.value = !expander.showMeaning.value;
      },
      child: Text(prompt, style: TextStyle(color: Colors.blue), textScaler: TextScaler.linear(0.8)));
}

class ExpandableSpan extends StatelessWidget {
  const ExpandableSpan(this.meaningRichText, {this.identifier, super.key});
  final Widget meaningRichText;
  final String? identifier;

  @override
  Widget build(BuildContext context) {
    final ExpansionController expander = Get.find(tag: identifier);
    return Obx(() => expander.showMeaning.value? meaningRichText : expansionTapper('translate', expander),
    );
  }
}
