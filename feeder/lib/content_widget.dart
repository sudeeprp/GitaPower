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

class WidgetMaker implements md.NodeVisitor {
  final List<TextSpan> Function(String text, String tag, String? elmclass) _inlineMaker;
  final List<Widget> Function(List<TextSpan>, SectionType) _widgetMaker;
  stack.Stack<md.Element> elementForCurrentText = stack.Stack();
  List<Widget> collectedWidgets = [];
  List<TextSpan> collectedElements = [];
  var currentSectionIndex = 0;
  WidgetMaker(this._widgetMaker, this._inlineMaker);

  List<Widget> parse(String markdownContent) {
    List<String> lines = markdownContent.split('\n');
    md.Document document = md.Document(encodeHtml: false);
    for (md.Node node in document.parseLines(lines)) {
      node.accept(this);
    }
    return collectedWidgets;
  }
  void _moveToNextSection() {
    if (currentSectionIndex < SectionType.values.length - 1) {
      currentSectionIndex++;
    }
  }

  @override
  void visitElementAfter(md.Element element) {
    const widgetSeparators = ['h2', 'p', 'pre'];
    if (widgetSeparators.contains(element.tag)) {
      collectedWidgets.addAll(_widgetMaker(collectedElements, SectionType.values[currentSectionIndex]));
      collectedElements = [];
      _moveToNextSection();
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

bool _startsWithDevanagari(String? content) {
  if (content == null) {
    return false;
  } else {
    return RegExp('^[\u0900-\u097F]+').hasMatch(content);
  }
}

Text _spansToText(List<TextSpan> spans, SectionType sectionType) {
  Choices choice = Get.find();
  final scriptChoice = choice.script.value;
  List<TextSpan> visibleSpans = [];
  if (sectionType == SectionType.meaning) {
    if (scriptChoice == ScriptPreference.devanagari) {
      visibleSpans = spans.where((textSpan) => textSpan.text?[0] != '[').toList();
    } else if (scriptChoice == ScriptPreference.sahk) {
      visibleSpans = spans.where((textSpan) => !_startsWithDevanagari(textSpan.text)).toList();
    }
  } else {
    visibleSpans = spans;
  }
  if (visibleSpans.isEmpty) {
    return const Text('');
  } else if (visibleSpans.length == 1) {
    return Text.rich(visibleSpans[0]);
  } else {
    return Text.rich(TextSpan(children: visibleSpans));
  }
}

TextStyle? _styleFor(String tag, String? elmclass) {
  if (elmclass == 'language-shloka-sa') {
    return const TextStyle(color: Colors.red, fontSize: 20);
  } else if (tag == 'code') {
    return GoogleFonts.robotoMono(color: Colors.red, fontSize: 16);
  } else {
    return const TextStyle(height: 1.5);
  }
}
List<TextSpan> formatMaker(String content, String tag, String? elmclass) {
  return [TextSpan(text: content, style: _styleFor(tag, elmclass))];
}

bool _isVisible(SectionType sectionType) {
  Choices choice = Get.find();
  // Assignment to a local variable is needed. Otherwise GetX throws an error when "return true" doesn't access any observable.
  final scriptChoice = choice.script.value;
  if (sectionType == SectionType.shlokaSA) {
    return scriptChoice == ScriptPreference.devanagari;
  } else if (sectionType == SectionType.shlokaSAHK) {
    return scriptChoice == ScriptPreference.sahk;
  }
  return true;
}

Widget _enclosure(SectionType sectionType, Widget w) {
  if (sectionType == SectionType.shlokaSAHK || sectionType == SectionType.shlokaSA) {
    return SingleChildScrollView(scrollDirection: Axis.horizontal, child: w);
  } else {
    return w;
  }
}

List<Widget> textRichMaker(List<TextSpan> spans, SectionType sectionType) {
  return [Obx(()=> Visibility(
    visible: _isVisible(sectionType),
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 5),
      child: _enclosure(sectionType, _spansToText(spans, sectionType)),
    )
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
  final String mdFilename;
  ContentWidget(this.mdFilename, {Key? key}): super(key: key) {
    Get.lazyPut(() => MDContent(mdFilename), tag: mdFilename);
  }

  @override
  Widget build(context) {
    MDContent md = Get.find(tag: mdFilename);
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
