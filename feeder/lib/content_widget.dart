import 'dart:ui';

import 'package:askys/markdownparser.dart';
import 'package:askys/mdcontent.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:askys/choice_selector.dart';
import 'package:markdown/markdown.dart' as md;

class MarkdownParser implements md.NodeVisitor {
  final List<Widget> Function(String) _widgetMaker;
  List<Widget> collectedWidgets = [];
  MarkdownParser(this._widgetMaker);

  List<Widget> parse(String markdownContent) {
    List<String> lines = markdownContent.split('\n');
    md.Document document = md.Document(encodeHtml: false);
    for (md.Node node in document.parseLines(lines)) {
      node.accept(this);
    }
    return collectedWidgets;
  }

  @override
  void visitElementAfter(md.Element element) {
    // TODO: implement visitElementAfter
  }

  @override
  bool visitElementBefore(md.Element element) {
    return true;
  }

  @override
  void visitText(md.Text text) {
    collectedWidgets.addAll(_widgetMaker(text.textContent));
  }
}

List<Widget> mdToWidgets(String markdown, List<Widget> Function(String) widgetMaker) {
  return MarkdownParser(widgetMaker).parse(markdown);
}

List<Widget> samplemdToWidgets(String markdown, BuildContext context) {
  Choices choice = Get.find();
  final codeStyle = GoogleFonts.robotoMono();
  return [
    Text.rich(TextSpan(text: '2-54', style: Theme.of(context).textTheme.headline2)),
    Obx(()=> Visibility(
      visible: choice.script.value == ScriptPreference.devanagari,
      child: Text.rich(TextSpan(text: '''
अर्जुन उवाच -
स्थितप्रज्ञस्य का भाषा समाधिस्थस्य केशव ।
स्थितधीः किम् प्रभाषेत किमासीत व्रजेत किम् ॥ ५४ ॥
''', style: codeStyle)))),
    Obx(()=> Visibility(
      visible: choice.script.value == ScriptPreference.sahk,
      child: Text.rich(TextSpan(text: '''
arjuna uvAca -
sthitaprajJasya kA bhASA samAdhisthasya kezava |
sthitadhIH kim prabhASeta kimAsIta vrajeta kim || 54 ||
''', style: codeStyle)))),
    Obx(() => Text.rich(TextSpan(children: [
      if (choice.isDevanagari()) TextSpan(text: 'अर्जुन उवाच ', style: codeStyle),
      if (choice.isSAHK()) TextSpan(text: '[arjuna uvAca] ', style: codeStyle),
      TextSpan(text: 'Arjuna said- '),
    ])))
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
              DefaultTextStyle(
                style: DefaultTextStyle.of(context).style.apply(fontSizeFactor: 1.3),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: samplemdToWidgets(md.mdContent.value, context),
                ))
          )));
  }
}
