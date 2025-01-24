import 'package:askys/choice_selector.dart';
import 'package:askys/choices_row.dart';
import 'package:askys/screenify.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

void guidedTour() {
  Get.toNamed('/guided');
}

Widget guidedTourScreen() {
  return screenify(GuidedTourWidget(),
      appBar: AppBar(title: const Text('Guided Tour (beta)')),
      choicesRow: choicesRow([], const [PersonalizeIcon(), SizedBox(width: choiceSpacing)]));
}

class GuidedTourWidget extends StatelessWidget {
  const GuidedTourWidget({super.key});

  @override
  Widget build(context) {
    // Choices:
    //   - ResponsiveGridList
    //   - GridView with SliverGridDelegateWithMaxCrossAxisExtent
    //   - Use a Wrap Widget
    //   - combine LayoutBuilder with either GridView or Wrap
    return LayoutBuilder(builder: (context, constraints) {
      if (constraints.maxWidth > constraints.maxHeight) {
        return Text('Landscape (${constraints.maxWidth} x ${constraints.maxHeight})');
      } else {
        return Text('Portrait (${constraints.maxWidth} x ${constraints.maxHeight})');
      }
    });
  }
}
