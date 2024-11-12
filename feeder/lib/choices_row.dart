import 'package:flutter/material.dart';

const double choiceSpacing = 8;

Widget choicesRow(List<Widget> leftChoiceIcons, List<Widget> rightChoiceIcons) {
  return Container(
    color: Colors.black12,
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Row(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: leftChoiceIcons),
      Row(
          mainAxisAlignment: MainAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: rightChoiceIcons),
    ]),
  );
}
