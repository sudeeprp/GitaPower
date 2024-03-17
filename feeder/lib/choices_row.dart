import 'package:flutter/material.dart';

const double choiceSpacing = 8;

Widget choicesRow(List<Widget> choiceIcons) {
  return Container(
    color: Colors.black12,
    child: Row(mainAxisAlignment: MainAxisAlignment.end, children: choiceIcons),
  );
}
