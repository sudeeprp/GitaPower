import 'package:askys/mdcontent.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:askys/choice_selector.dart';
import 'package:markdown/markdown.dart' as md;

enum SectionType { shlokaNumber, shlokaSA, shlokaSAHK, meaning, commentary }

class WidgetMaker implements md.NodeVisitor {
  final List<TextSpan> Function(String text, String tag, String? elmclass, String? link)
      _inlineMaker;
  final List<Widget> Function(List<TextSpan>, SectionType) _widgetMaker;
  List<md.Element> elementForCurrentText = [];
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

  SectionType _detectSectionType(md.Element element) {
    final classToSectionType = {
      'language-shloka-sa': SectionType.shlokaSA,
      'language-shloka-sa-hk': SectionType.shlokaSAHK
    };
    final tagToSectionType = {
      'h2': (element) => SectionType.shlokaNumber,
      'pre': (element) => classToSectionType[element.children[0].attributes['class']],
      'p': (element) =>
          _startsWithDevanagari(element.textContent) ? SectionType.meaning : SectionType.commentary,
    };
    final tagConverter = tagToSectionType[element.tag];
    if (tagConverter != null) {
      return tagConverter(element)!;
    } else {
      return SectionType.commentary;
    }
  }

  @override
  void visitElementAfter(md.Element element) {
    const widgetSeparators = ['h2', 'p', 'pre'];
    if (widgetSeparators.contains(element.tag)) {
      final sectionType = _detectSectionType(element);
      collectedWidgets.addAll(_widgetMaker(collectedElements, sectionType));
      collectedElements = [];
      _moveToNextSection();
    }
    elementForCurrentText.removeAt(elementForCurrentText.length - 1);
  }

  @override
  bool visitElementBefore(md.Element element) {
    elementForCurrentText.add(element);
    return true;
  }

  @override
  void visitText(md.Text markdownText) {
    final element = elementForCurrentText[elementForCurrentText.length - 1];
    var tag = element.tag;
    if (elementForCurrentText.length >= 2 &&
        elementForCurrentText[elementForCurrentText.length - 2].tag == 'blockquote') {
      tag = 'note';
    }
    final processedText = _textForElement(markdownText.textContent, element);
    collectedElements.addAll(
        _inlineMaker(processedText, tag, element.attributes['class'], element.attributes['href']));
  }

  String _textForElement(String inputText, md.Element element) {
    if (element.tag == 'code') {
      return inputText.trim();
    } else {
      return inputText.replaceAll(RegExp(r"\s+"), " ");
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

List<TextSpan> Function(String, String, String?, String?) makeFormatMaker(BuildContext context) {
  List<TextSpan> formatMaker(String content, String tag, String? elmclass, String? link) {
    if (tag == 'note') {
      return [
        TextSpan(children: [
          WidgetSpan(
              child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.background.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            child: Text(content),
          ))
        ])
      ];
    }
    return [TextSpan(text: content, style: _styleFor(tag, elmclass))];
  }

  return formatMaker;
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

Widget _horizontalScroller(SectionType sectionType, Widget w) {
  if (sectionType == SectionType.shlokaSAHK || sectionType == SectionType.shlokaSA) {
    return SingleChildScrollView(scrollDirection: Axis.horizontal, child: w);
  } else {
    return w;
  }
}

List<Widget> textRichMaker(List<TextSpan> spans, SectionType sectionType) {
  return [
    Obx(() => Visibility(
        visible: _isVisible(sectionType),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 5),
          child: _horizontalScroller(sectionType, _spansToText(spans, sectionType)),
        )))
  ];
}

class ContentWidget extends StatelessWidget {
  final String mdFilename;
  ContentWidget(this.mdFilename, {Key? key}) : super(key: key) {
    Get.lazyPut(() => MDContent(mdFilename), tag: mdFilename);
  }

  @override
  Widget build(context) {
    MDContent md = Get.find(tag: mdFilename);
    return Center(
        child: Obx(() => SingleChildScrollView(
            child: DefaultTextStyle(
                style: DefaultTextStyle.of(context).style.apply(fontSizeFactor: 1.3),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: WidgetMaker(textRichMaker, makeFormatMaker(context))
                      .parse(md.mdContent.value),
                )))));
  }
}
