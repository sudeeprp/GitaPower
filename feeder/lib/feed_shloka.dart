import 'package:askys/chapter_shloka_widget.dart';
import 'package:askys/choice_selector.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FeedShloka extends StatelessWidget {
  const FeedShloka(this.mdFilename, {super.key});
  final String mdFilename;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final Choices choices = Get.find();
      final headPreference = choices.headPreference.value;
      return formShlokaTitle(mdFilename, headPreference, context) ?? const Text('Not found');
    });
  }
}
