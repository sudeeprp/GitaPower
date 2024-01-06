import 'package:askys/notecontent.dart';
import 'package:askys/text_styles.dart';
import 'package:flutter/material.dart';

Widget buildNote(BuildContext context, Widget content) {
  return Card(
    elevation: 5,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
    child: Row(children: [
      Image.asset('images/one-step.png'),
      Expanded(child: Padding(padding: const EdgeInsets.only(left: 3), child: content))
    ]),
  );
}

class HeaderNote extends StatelessWidget {
  const HeaderNote(this.noteContent, this.shortTitle, {super.key});
  final String? noteContent;
  final String shortTitle;

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Expanded(
          flex: 9,
          child: buildNote(
              context,
              Text.rich(TextSpan(text: toPlainText(noteContent ?? '')),
                  style: styleFor(context, 'note')))),
      Expanded(
        flex: 1,
        child: Text(shortTitle, style: Theme.of(context).textTheme.bodySmall),
      ),
    ]);
  }
}
