import 'package:askys/mdcontent.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:askys/choice_selector.dart';
import 'package:markdown/markdown.dart' as md;

enum SectionType { chapterHeading, shlokaNumber, shlokaSA, shlokaSAHK, meaning, commentary, note }

class TextElement {
  TextElement(this.mdElement, this.sectionType, this.isSectionTop);
  final md.Element mdElement;
  final SectionType sectionType;
  final bool isSectionTop;
}

class WidgetMaker implements md.NodeVisitor {
  final List<TextSpan> Function(
          String text, SectionType sectionType, String tag, String? elmclass, String? link)
      _inlineMaker;
  final List<Widget> Function(List<TextSpan>, SectionType) _widgetMaker;
  List<TextElement> elementForCurrentText = [];
  List<Widget> collectedWidgets = [];
  List<TextSpan> collectedElements = [];
  Map<String, GlobalKey> anchorKeys = {};
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
      'h1': (element) => SectionType.chapterHeading,
      'h2': (element) => SectionType.shlokaNumber,
      'pre': (element) => classToSectionType[element.children[0].attributes['class']],
      'p': (element) =>
          _startsWithDevanagari(element.textContent) ? SectionType.meaning : SectionType.commentary,
      'blockquote': (element) => SectionType.note,
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
    if (elementForCurrentText.last.isSectionTop) {
      collectedWidgets
          .addAll(_widgetMaker(collectedElements, elementForCurrentText.last.sectionType));
      collectedElements = [];
      _moveToNextSection();
    }
    elementForCurrentText.removeAt(elementForCurrentText.length - 1);
  }

  @override
  bool visitElementBefore(md.Element element) {
    const widgetSeparators = ['h1', 'h2', 'p', 'pre', 'blockquote'];
    if (widgetSeparators.contains(element.tag)) {
      final sectionType = _detectSectionType(element);
      elementForCurrentText.add(TextElement(element, sectionType, true));
    } else {
      final sectionType = elementForCurrentText.isNotEmpty
          ? elementForCurrentText.last.sectionType
          : SectionType.commentary;
      elementForCurrentText.add(TextElement(element, sectionType, false));
    }
    return true;
  }

  @override
  void visitText(md.Text markdownText) {
    final element = elementForCurrentText.last;
    var tag = element.mdElement.tag;
    if (elementForCurrentText.length >= 2 &&
        elementForCurrentText[elementForCurrentText.length - 2].mdElement.tag == 'blockquote') {
      tag = 'note';
    }
    if (_isAnchor(markdownText.textContent)) {
      tag = 'anchor';
      _addAnchors(markdownText.textContent);
    }
    final processedText = _textForElement(markdownText.textContent, element.mdElement);
    if (processedText.isNotEmpty) {
      collectedElements.addAll(_inlineMaker(processedText, element.sectionType, tag,
          element.mdElement.attributes['class'], element.mdElement.attributes['href']));
    }
  }

  final _multipleSpaces = RegExp(r"\s+");
  final _anchors = RegExp(r"<a name='([\w]+)'><\/a>\s*");

  String _textForElement(String inputText, md.Element element) {
    if (element.tag == 'code') {
      return inputText.trim();
    } else {
      return inputText.replaceAll(_multipleSpaces, " ").replaceAll(_anchors, "");
    }
  }

  void _addAnchors(String anchorLine) {
    final anchorMatches = _anchors.allMatches(anchorLine);
    for (final anchor in anchorMatches) {
      final noteId = anchor.group(1);
      if (noteId != null) {
        final keyOfAnchor = GlobalKey(debugLabel: noteId);
        collectedElements.add(TextSpan(children: [
          WidgetSpan(child: Container(key: keyOfAnchor, child: _anchorWidget(noteId))),
        ]));
        anchorKeys[noteId] = keyOfAnchor;
      }
    }
  }

  Widget _anchorWidget(String noteId) {
    if (noteId.startsWith('appl')) {
      return Image.asset('images/right-foot.png', key: Key(noteId));
    } else {
      return SizedBox(width: 1, height: 1, key: Key(noteId));
    }
  }
}

bool _isAnchor(String inputText) {
  return inputText.startsWith('<a name=');
}

bool _startsWithDevanagari(String? content) {
  if (content == null) {
    return false;
  } else {
    return RegExp('^[\u0900-\u097F]+').hasMatch(content);
  }
}

List<TextSpan> _renderMeaning(
    List<TextSpan> spans, MeaningMode meaningMode, ScriptPreference scriptChoice) {
  List<TextSpan> spansToRender = [];
  if (meaningMode == MeaningMode.expanded) {
    if (scriptChoice == ScriptPreference.devanagari) {
      spansToRender = spans.where((textSpan) => textSpan.text?[0] != '[').toList();
    } else if (scriptChoice == ScriptPreference.sahk) {
      spansToRender = spans.where((textSpan) => !_startsWithDevanagari(textSpan.text)).toList();
    }
  } else {
    spansToRender = spans
        .where((textSpan) => textSpan.text?[0] != '[' && !_startsWithDevanagari(textSpan.text))
        .toList();
  }
  return spansToRender;
}

Text _spansToText(List<TextSpan> spans, SectionType sectionType) {
  Choices choice = Get.find();
  final scriptChoice = choice.script.value;
  final meaningMode = choice.meaningMode.value;
  List<TextSpan> visibleSpans = [];
  if (sectionType == SectionType.meaning) {
    visibleSpans = _renderMeaning(spans, meaningMode, scriptChoice);
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
  } else if (tag == 'h1') {
    return GoogleFonts.rubik(height: 3);
  } else if (tag == 'h2') {
    return GoogleFonts.workSans(height: 3);
  } else if (tag == 'em') {
    return GoogleFonts.bubblerOne(height: 1.2);
  } else {
    return const TextStyle(height: 1.5);
  }
}

GestureRecognizer? _actionFor(SectionType sectionType, String tag) {
  if (sectionType == SectionType.meaning) {
    return TapGestureRecognizer()
      ..onTap = () {
        final Choices choice = Get.find();
        if (choice.meaningMode.value == MeaningMode.short) {
          choice.meaningMode.value = MeaningMode.expanded;
        } else {
          choice.meaningMode.value = MeaningMode.short;
        }
      };
  } else {
    return null;
  }
}

void _navigateToLink(String? link) {
  String mdFilename = 'broken-link.md';
  String noteId = '';
  if (link != null) {
    final linkParts = link.split('#');
    mdFilename = linkParts[0];
    if (linkParts.length > 1) {
      noteId = linkParts[1];
    }
  }
  Get.toNamed('/shloka/$mdFilename/$noteId');
}

List<TextSpan> Function(String, SectionType, String, String?, String?) makeFormatMaker(
    BuildContext context) {
  List<TextSpan> formatMaker(
      String contentText, SectionType sectionType, String tag, String? elmclass, String? link) {
    if (tag == 'note') {
      return [
        TextSpan(children: [WidgetSpan(child: _buildNote(context, contentText))])
      ];
    }
    if (tag == 'a') {
      return [
        TextSpan(
          text: contentText,
          style: const TextStyle(color: Colors.blue),
          recognizer: TapGestureRecognizer()..onTap = () => _navigateToLink(link),
        )
      ];
    }
    return [
      TextSpan(
          text: contentText,
          style: _styleFor(tag, elmclass),
          recognizer: _actionFor(sectionType, tag))
    ];
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

Widget _horizontalScrollForShloka(SectionType sectionType, Widget w) {
  if (sectionType == SectionType.shlokaSAHK || sectionType == SectionType.shlokaSA) {
    return SingleChildScrollView(scrollDirection: Axis.horizontal, child: w);
  } else {
    return w;
  }
}

Widget _buildNote(BuildContext context, String noteContent) {
  return Container(
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.background.withOpacity(0.1),
      borderRadius: BorderRadius.circular(8),
    ),
    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
    child: Text(noteContent, textScaleFactor: 0.8),
  );
}

BoxDecoration? _sectionDecoration(BuildContext context, SectionType sectionType) {
  if (sectionType == SectionType.meaning) {
    return const BoxDecoration(border: Border(bottom: BorderSide()));
  } else {
    return null;
  }
}

Widget _sectionContainer(BuildContext context, SectionType sectionType, Widget content) {
  return Container(
    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 5),
    decoration: _sectionDecoration(context, sectionType),
    child: _horizontalScrollForShloka(sectionType, content),
  );
}

class ContentWidget extends StatelessWidget {
  ContentWidget(this.mdFilename, this.initialAnchor, {Key? key}) : super(key: key) {
    Get.lazyPut(() => MDContent(mdFilename), tag: mdFilename);
  }

  final String mdFilename;
  final String? initialAnchor;

  @override
  Widget build(context) {
    List<Widget> textRichMaker(List<TextSpan> spans, SectionType sectionType) {
      return [
        Obx(() => Visibility(
              visible: _isVisible(sectionType),
              child: _sectionContainer(context, sectionType, _spansToText(spans, sectionType)),
            ))
      ];
    }

    MDContent md = Get.find(tag: mdFilename);
    return Center(
        child: SingleChildScrollView(
            child: DefaultTextStyle(
                style: DefaultTextStyle.of(context).style.apply(fontSizeFactor: 1.3),
                child: Obx(() {
                  final widgetMaker = WidgetMaker(textRichMaker, makeFormatMaker(context));
                  final widgetsMade = widgetMaker.parse(md.mdContent.value);
                  final collectedAnchorKeys = widgetMaker.anchorKeys;
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    BuildContext? anchorContext;
                    if (collectedAnchorKeys.containsKey(initialAnchor)) {
                      anchorContext = collectedAnchorKeys[initialAnchor]?.currentContext;
                    }
                    if (anchorContext != null) {
                      Scrollable.ensureVisible(anchorContext);
                    }
                  });
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: widgetsMade,
                  );
                }))));
  }
}

ContentWidget buildContent(String mdFilename, {String? initialAnchor, Key? key}) {
  return ContentWidget(mdFilename, initialAnchor, key: key);
}
