import 'dart:ui';

import 'package:askys/markdownparser.dart';
import 'package:askys/mdcontent.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:askys/choice_selector.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:stack/stack.dart' as stack;

enum SectionType {
  shlokaNumber,
  shlokaSA,
  shlokaSAHK,
  meaning,
  commentary
}

class Section {
  Section(this.sectionType, this.content);
  SectionType sectionType;
  Widget content;
}

class WidgetMaker implements md.NodeVisitor {
  final List<TextSpan> Function(String text, String tag, String? elmclass) _inlineMaker;
  final List<Widget> Function(List<TextSpan>, md.Element) _widgetMaker;
  stack.Stack<md.Element> elementForCurrentText = stack.Stack();
  List<Widget> collectedWidgets = [];
  List<TextSpan> collectedElements = [];
  WidgetMaker(this._widgetMaker, this._inlineMaker);

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
    const widgetSeparators = ['h2', 'p', 'pre'];
    if (widgetSeparators.contains(element.tag)) {
      collectedWidgets.addAll(_widgetMaker(collectedElements, element));
      collectedElements = [];
    }
    elementForCurrentText.pop();
  }

  @override
  bool visitElementBefore(md.Element element) {
    elementForCurrentText.push(element);
    return true;
  }

  @override
  void visitText(md.Text markdownText) {
    final element = elementForCurrentText.top();
    final processedText = _textForElement(markdownText.textContent, element);
    collectedElements.addAll(_inlineMaker(processedText, element.tag, element.attributes['class']));
  }

  String _removeLeadingNewline(String wsCleaned) {
    if (wsCleaned[0] == "\n") {
      return wsCleaned.substring(1);
    } else {
      return wsCleaned;
    }
  }
  String _textForElement(String inputText, md.Element element) {
    if (element.tag == 'code') {
      return inputText.trim();
    } else {
      return _removeLeadingNewline(inputText).replaceAll(RegExp(r"\s+"), " ");
    }
  }
}

Text _spansToText(List<TextSpan> spans) {
  if (spans.isEmpty) {
    return const Text('');
  } else if (spans.length == 1) {
    return Text.rich(spans[0]);
  } else {
    return Text.rich(TextSpan(children: spans));
  }
}

TextStyle? _styleFor(String tag, String? elmclass) {
  if (elmclass == 'language-shloka-sa') {
    return const TextStyle(color: Colors.red, fontSize: 20);
  } else if (tag == 'code') {
    return GoogleFonts.robotoMono(color: Colors.red);
  } else {
    return null;
  }
}
List<TextSpan> formatMaker(String content, String tag, String? elmclass) {
  return [TextSpan(text: content, style: _styleFor(tag, elmclass))];
}

bool _isVisible(md.Element element) {
  Choices choice = Get.find();
  final elmclass = element.attributes['class'];
  if (elmclass == 'language-shloka-sa') {
    return choice.script.value == ScriptPreference.devanagari;
  } else if (elmclass == 'language-shloka-sa-hk') {
    return choice.script.value == ScriptPreference.sahk;
  }
  return true;
}

List<Widget> textRichMaker(List<TextSpan> spans, md.Element element) {
  return [Obx(()=> Visibility(
       visible: _isVisible(element),
       child: Padding(padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 5), child: _spansToText(spans))
       ))];
}

List<Widget> samplemdToWidgets(String markdown, BuildContext context) {
  return WidgetMaker(textRichMaker, formatMaker).parse(markdown);
}

// List<Widget> samplemdToWidgets(String markdown, BuildContext context) {
//   Choices choice = Get.find();
//   final codeStyle = GoogleFonts.robotoMono();
//   return [
//     Text.rich(TextSpan(text: '2-54', style: Theme.of(context).textTheme.headline2)),
//     Obx(()=> Visibility(
//       visible: choice.script.value == ScriptPreference.devanagari,
//       child: Text.rich(TextSpan(text: '''
// अर्जुन उवाच -
// स्थितप्रज्ञस्य का भाषा समाधिस्थस्य केशव ।
// स्थितधीः किम् प्रभाषेत किमासीत व्रजेत किम् ॥ ५४ ॥
// ''', style: codeStyle)))),
//     Obx(()=> Visibility(
//       visible: choice.script.value == ScriptPreference.sahk,
//       child: Text.rich(TextSpan(text: '''
// arjuna uvAca -
// sthitaprajJasya kA bhASA samAdhisthasya kezava |
// sthitadhIH kim prabhASeta kimAsIta vrajeta kim || 54 ||
// ''', style: codeStyle)))),
//     Obx(() => Text.rich(TextSpan(children: [
//       if (choice.isDevanagari()) TextSpan(text: 'अर्जुन उवाच ', style: codeStyle),
//       if (choice.isSAHK()) TextSpan(text: '[arjuna uvAca] ', style: codeStyle),
//       TextSpan(text: 'Arjuna said- '),
//     ])))
//   ];
// }

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
