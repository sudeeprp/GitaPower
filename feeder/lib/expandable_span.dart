import 'package:askys/choice_selector.dart';
import 'package:askys/choices_row.dart';
import 'package:askys/content_themes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ExpansionController extends GetxController {
  final showShloka = true.obs;
  final showMeaning = false.obs;
  @override
  void onInit() {
    final Choices choices = Get.find();
    choices.meaningMode.listen((_) {
      showMeaning.value = true;
    });
    if (choices.headPreference.value == HeadPreference.meaning) {
      showShloka.value = false;
      showMeaning.value = true;
    }
    super.onInit();
  }
}

class ExpandableMeaning extends StatelessWidget {
  const ExpandableMeaning(this.meaningRichText, {this.identifier, super.key});
  final Widget meaningRichText;
  final String? identifier;

  @override
  Widget build(BuildContext context) {
    final ExpansionController expander = Get.find(tag: identifier);
    return Obx(
      () => expander.showMeaning.value ? meaningRichText : meaningTapper(expander, context),
    );
  }

  Widget meaningTapper(ExpansionController expander, BuildContext context) {
    return GestureDetector(
      onTap: () {
        expander.showMeaning.value = !expander.showMeaning.value;
      },
      child: Row(children: [
        Image.asset('images/expand_meaning${contentAssetSuffix(context)}.png', width: 16, height: 16),
        SizedBox(width: choiceSpacing),
        Text('translate', style: TextStyle(color: Colors.blue), textScaler: TextScaler.linear(0.8)),
      ]),
    );
  }
}

class ExpandableShloka extends StatelessWidget {
  const ExpandableShloka(this.shlokaText, {this.identifier, super.key});
  final Widget shlokaText;
  final String? identifier;

  @override
  Widget build(BuildContext context) {
    final ExpansionController expander = Get.find(tag: identifier);
    return Obx(
      () => expander.showShloka.value ? shlokaText : shlokaTapper(expander, context),
    );
  }

  Widget shlokaTapper(ExpansionController expander, BuildContext context) {
    return GestureDetector(
      onTap: () {
        expander.showShloka.value = !expander.showShloka.value;
      },
      child: Row(children: [
        Image.asset('images/shloka_visible${contentAssetSuffix(context)}.png', width: 16, height: 16),
        SizedBox(width: choiceSpacing),
        Text('source', style: TextStyle(color: Colors.deepOrange), textScaler: TextScaler.linear(0.8)),
      ]),
    );
  }
}
