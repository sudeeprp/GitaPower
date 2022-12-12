import 'dart:ui';

import 'package:askys/markdownparser.dart';
import 'package:askys/mdcontent.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

List<Text> mdToWidgets(String markdown, BuildContext context) {
  final codeStyle = GoogleFonts.robotoMono();
  return [
    Text.rich(TextSpan(text: '2-54', style: Theme.of(context).textTheme.headline2)),
    Text.rich(TextSpan(text: '''
अर्जुन उवाच -
स्थितप्रज्ञस्य का भाषा समाधिस्थस्य केशव ।
स्थितधीः किम् प्रभाषेत किमासीत व्रजेत किम् ॥ ५४ ॥
''', style: codeStyle)),
    Text.rich(TextSpan(text: '''
arjuna uvAca -
sthitaprajJasya kA bhASA samAdhisthasya kezava |
sthitadhIH kim prabhASeta kimAsIta vrajeta kim || 54 ||
''', style: codeStyle)),
    Text.rich(TextSpan(children: [
      TextSpan(text: 'अर्जुन उवाच ', style: codeStyle),
      TextSpan(text: '[arjuna uvAca] ', style: codeStyle),
      TextSpan(text: 'Arjuna said- '),
    ]))
  ];
}

class ContentWidget extends StatelessWidget {
  const ContentWidget({Key? key}) : super(key: key);

  @override
  Widget build(context) {
    MDContent md = Get.find();
    return Center(
        child: Obx(() => SingleChildScrollView(
            child:
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: mdToWidgets(md.mdContent.value, context),
                ))));
  }
}
