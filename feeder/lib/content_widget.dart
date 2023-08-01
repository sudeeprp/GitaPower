import 'package:askys/mdcontent.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:askys/choice_selector.dart';
import 'package:markdown/markdown.dart' as md;

import 'chaptercontent.dart';
import 'notecontent.dart';

enum SectionType {
  chapterHeading,
  topicHead,
  shlokaNumber,
  shlokaSA,
  shlokaSAHK,
  meaning,
  commentary,
  note
}

final _multipleSpaces = RegExp(r"\s+");
final _anchors = RegExp(r"<a name='([\w]+)'><\/a>\s*");

class CurrentTextElement {
  CurrentTextElement(this.mdElement, this.sectionType, this.isSectionTop);
  final md.Element mdElement;
  final SectionType sectionType;
  final bool isSectionTop;
}

class MatterForInline {
  MatterForInline(
      this.text, this.sectionType, this.tag, this.elmclass, this.link);
  final String text;
  SectionType sectionType;
  String tag;
  String? elmclass;
  String? link;
}

class WidgetMaker implements md.NodeVisitor {
  final List<TextSpan> Function(MatterForInline matterForInline) _inlineMaker;
  final List<Widget> Function(List<TextSpan>, SectionType) _widgetMaker;
  SectionType? _previousSectionType;
  List<CurrentTextElement> elementForCurrentText = [];
  List<String> noteIdsInPage = [];
  List<Widget> collectedWidgets = [];
  List<MatterForInline> collectedInlines = [];
  WidgetMaker(this._widgetMaker, this._inlineMaker);

  List<Widget> parse(String markdownContent) {
    List<String> lines = markdownContent.split('\n');
    // print(lines);
    if(lines[0].contains("Chapter")){
      lines.remove(lines[0]);
    }
    md.Document document = md.Document(encodeHtml: false);
    for (md.Node node in document.parseLines(lines)) {
      node.accept(this);
    }
    return collectedWidgets;
  }

  void _moveToNextSection() {
    collectedInlines = [];
  }

  SectionType _detectSectionType(md.Element element) {
    final classToSectionType = {
      'language-shloka-sa': SectionType.shlokaSA,
      'language-shloka-sa-hk': SectionType.shlokaSAHK
    };
    final tagToSectionType = {
      'h1': (element) => SectionType.chapterHeading,
      'h2': (element) => _headingType(element.textContent),
      'pre': (element) =>
          classToSectionType[element.children[0].attributes['class']],
      'p': (element) =>
          _startsWithDevanagari(element.textContent) && !_inMidstOfCommentary()
              ? SectionType.meaning
              : SectionType.commentary,
      'blockquote': (element) => SectionType.note,
    };
    final tagConverter = tagToSectionType[element.tag];
    if (tagConverter != null) {
      return tagConverter(element)!;
    } else {
      return SectionType.commentary;
    }
  }

  List<TextSpan> _collectedElements() {
    List<TextSpan> collectedElements = [];
    for (final inlineMatter in collectedInlines) {
      collectedElements.addAll(_inlineMaker(inlineMatter));
    }
    return collectedElements;
  }

  @override
  void visitElementAfter(md.Element element) {
    if (elementForCurrentText.last.isSectionTop) {
      collectedWidgets.addAll(_widgetMaker(
          _collectedElements(), elementForCurrentText.last.sectionType));
      _previousSectionType = elementForCurrentText.last.sectionType;
      _moveToNextSection();
    }
    elementForCurrentText.removeAt(elementForCurrentText.length - 1);
  }

  @override
  bool visitElementBefore(md.Element element) {
    if (_isSeparate(element.tag)) {
      final sectionType = _detectSectionType(element);
      elementForCurrentText.add(CurrentTextElement(element, sectionType, true));
    } else {
      final sectionType = elementForCurrentText.isNotEmpty
          ? elementForCurrentText.last.sectionType
          : SectionType.commentary;
      elementForCurrentText
          .add(CurrentTextElement(element, sectionType, false));
    }
    return true;
  }

  @override
  void visitText(md.Text markdownText) {
    final element = elementForCurrentText.last;
    final elmclass = element.mdElement.attributes['class'];
    final link = element.mdElement.attributes['href'];
    var tag = element.mdElement.tag;
    if (elementForCurrentText.length >= 2 &&
        elementForCurrentText[elementForCurrentText.length - 2].mdElement.tag ==
            'blockquote') {
      tag = 'note';
    }
    if (_hasAnchor(markdownText.textContent)) {
      final anchorMatches = _anchors.allMatches(markdownText.textContent);
      for (final anchor in anchorMatches) {
        final noteId = anchor.group(1);
        if (noteId != null) {
          noteIdsInPage.add(noteId);
          collectedInlines.add(MatterForInline(
              noteId, element.sectionType, 'anchor', elmclass, link));
        }
      }
    }
    final processedText =
        _textForElement(markdownText.textContent, element.mdElement);
    if (processedText.isNotEmpty) {
      final inlineMatter = MatterForInline(
          processedText, element.sectionType, tag, elmclass, link);
      collectedInlines.add(inlineMatter);
    }
  }

  bool _isSeparate(elementTag) {
    const widgetSeparators = ['h1', 'h2', 'p', 'pre', 'blockquote'];
    return widgetSeparators.contains(elementTag) &&
        (elementForCurrentText.isEmpty ||
            elementForCurrentText.last.mdElement.tag != 'blockquote');
  }

  String _textForElement(String inputText, md.Element element) {
    if (element.tag == 'code') {
      return inputText.trim();
    } else {
      return inputText
          .replaceAll(_multipleSpaces, " ")
          .replaceAll(_anchors, "");
    }
  }

  bool _inMidstOfCommentary() {
    return _previousSectionType == SectionType.commentary ||
        _previousSectionType == SectionType.note;
  }
}

bool _hasAnchor(String inputText) {
  return inputText.startsWith('<a name=');
}

bool _startsWithDevanagari(String? content) {
  if (content == null) {
    return false;
  } else {
    return RegExp('^[\u0900-\u097F]+').hasMatch(content);
  }
}

SectionType _headingType(String? content) {
  if (content != null && RegExp('^[0-9]').hasMatch(content)) {
    return SectionType.shlokaNumber;
  }
  return SectionType.topicHead;
}

bool _isSAHK(String? content) {
  return content != null && content.isNotEmpty && content[0] == '[';
}

List<TextSpan> _renderMeaning(List<TextSpan> spans, MeaningMode meaningMode,
    ScriptPreference scriptChoice) {
  List<TextSpan> spansToRender = [];
  if (meaningMode == MeaningMode.expanded) {
    if (scriptChoice == ScriptPreference.devanagari) {
      spansToRender =
          spans.where((textSpan) => !_isSAHK(textSpan.text)).toList();
    } else if (scriptChoice == ScriptPreference.sahk) {
      spansToRender = spans
          .where((textSpan) => !_startsWithDevanagari(textSpan.text))
          .toList();
    }
  } else {
    spansToRender = spans
        .where((textSpan) =>
            !_isSAHK(textSpan.text) && !_startsWithDevanagari(textSpan.text))
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
    return Text.rich(
      TextSpan(children: visibleSpans),
      style: const TextStyle(fontSize: 18),
    );
  }
}

TextStyle? _styleFor(String tag, String? elmclass) {
  if (elmclass == 'language-shloka-sa') {
    return TextStyle(color: Get.find<Choices>().codeColor.value, fontSize: 20);
  } else if (tag == 'code') {
    return GoogleFonts.robotoMono(
        color: Get.find<Choices>().codeColor.value, fontSize: 16);
  } else if (tag == 'h1') {
    return GoogleFonts.rubik(height: 3);
  } else if (tag == 'h2') {
    return GoogleFonts.workSans(height: 3);
  } else if (tag == 'em') {
    return GoogleFonts.bubblerOne(height: 1.2, fontSize: 16);
  } else if (tag == 'note') {
    return const TextStyle(fontSize: 14);
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

List<TextSpan> _anchorSpan(String noteId, Map<String, GlobalKey> anchorKeys) {
  final keyOfAnchor = GlobalKey(debugLabel: noteId);
  anchorKeys[noteId] = keyOfAnchor;
  return [
    TextSpan(children: [
      WidgetSpan(
          child: Container(key: keyOfAnchor, child: _anchorWidget(noteId))),
    ])
  ];
}

Widget _anchorWidget(String noteId) {
  if (noteId.startsWith('appl')) {
    return Image.asset('images/one-step.png', key: Key(noteId));
  } else {
    return SizedBox(width: 1, height: 1, key: Key(noteId));
  }
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

Widget _horizontalScrollForOneLiners(SectionType sectionType, Widget w) {
  if (sectionType == SectionType.shlokaSAHK ||
      sectionType == SectionType.shlokaSA) {
    return SingleChildScrollView(scrollDirection: Axis.horizontal, child: w);
  } else {
    return w;
  }
}

Widget _buildNote(BuildContext context, Widget content) {
  // print(content);
  return Container(
    // decoration: BoxDecoration(
    //   color: Theme.of(context).colorScheme.background.withOpacity(0.1),
    //   borderRadius: BorderRadius.circular(8),
    // ),
    padding: const EdgeInsets.only(top: 8, bottom: 16, left: 12, right: 12),
    alignment: Alignment.center,
    child: content,
  );
}

BoxDecoration? _sectionDecoration(
    BuildContext context, SectionType sectionType) {
  if (sectionType == SectionType.meaning) {
    return const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey)));
  } else {
    return null;
  }
}

String _tuneContentForDisplay(MatterForInline inlineMatter) {
  String contentForDisplay = inlineMatter.text;
  if (inlineMatter.sectionType == SectionType.meaning &&
      inlineMatter.tag != 'code') {
    final Choices choice = Get.find();
    if (choice.meaningMode.value == MeaningMode.short) {
      contentForDisplay = inlineMatter.text.trimLeft();
    }
  }
  return contentForDisplay;
}

Widget _sectionContainer(
    BuildContext context, SectionType sectionType, Widget content) {
  if (sectionType == SectionType.note) {
    return _buildNote(context, content);
  }
  // return Container(
  //   padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 5),
  //   decoration: _sectionDecoration(context, sectionType),
  //   child: _horizontalScrollForOneLiners(sectionType, content),
  // );
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    child: Center(
      child: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.white.withOpacity(0.1),
              offset: const Offset(-6.0, -6.0),
              blurRadius: 16.0,
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              offset: const Offset(6.0, 6.0),
              blurRadius: 16.0,
            ),
          ],
        ),
        child: Card(
          color: Theme.of(context).colorScheme.background,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: _horizontalScrollForOneLiners(sectionType, content),
          ),
        ),
      ),
    ),
  );
}

class ContentWidget extends StatelessWidget {
  ContentWidget(this.mdFilename, this.initialAnchor, this.contentNote,
      this.prevmd, this.nextmd,
      {Key? key})
      : super(key: key) {
    Get.lazyPut(() => MDContent(mdFilename), tag: mdFilename);
  }

  final String mdFilename;
  final String? initialAnchor;
  final String? contentNote;
  final String? nextmd;
  final String? prevmd;

  @override
  Widget build(context) {
    final choices = Get.find<Choices>();
    Map<String, GlobalKey> anchorKeys = {};
    List<Widget> textRichMaker(List<TextSpan> spans, SectionType sectionType) {
      if (sectionType == SectionType.shlokaNumber) {
        return []; // Shloka number is now on the top-right
      }
      if (sectionType == SectionType.topicHead) {
        return [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 5),
            decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: Colors.grey))),
            child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Obx(() => Text.rich(TextSpan(children: spans),
                    style: TextStyle(color: choices.codeColor.value)))),
          )
        ];
      }
      return [
        Obx(() => Visibility(
              visible: _isVisible(sectionType),
              child: _sectionContainer(
                  context, sectionType, _spansToText(spans, sectionType)),
            ))
      ];
    }

    List<TextSpan> formatMaker(MatterForInline inlineMatter) {
      if (inlineMatter.tag == 'anchor') {
        return _anchorSpan(inlineMatter.text, anchorKeys);
      }
      if (inlineMatter.tag == 'a') {
        return [
          TextSpan(
            text: inlineMatter.text,
            style: const TextStyle(color: Colors.blue),
            recognizer: TapGestureRecognizer()
              ..onTap = () => _navigateToLink(inlineMatter.link),
          ),
          const TextSpan(text: ' ')
        ];
      }
      var textContent = _tuneContentForDisplay(inlineMatter);
      // print(textContent.contains("Chapter"));
      return [
        TextSpan(
            text: textContent,
            style: _styleFor(inlineMatter.tag, inlineMatter.elmclass),
            recognizer: _actionFor(inlineMatter.sectionType, inlineMatter.tag))
      ];
    }

    void insertContentNote(List<Widget> contentWidgets) {
      if (contentNote != null) {
        //print(contentNote );
        contentWidgets.insert(
            0,
            _buildNote(
                context,
                Text.rich(
                  TextSpan(text: toPlainText(contentNote!)),
                  // style: _styleFor('note', null)
                  style: const TextStyle(fontSize: 24),
                )));
      }
    }

    MDContent md = Get.find(tag: mdFilename);
    return Scaffold(
      appBar: AppBar(
        title: Text(Chapter.filenameToTitle(mdFilename)),
      ),
      body: Stack(children: [
        Center(
            child: ListView(children: [
          DefaultTextStyle(
              style:
                  DefaultTextStyle.of(context).style.apply(fontSizeFactor: 1.3),
              child: Obx(() {
                final widgetMaker = WidgetMaker(textRichMaker, formatMaker);
                final widgetsMade = widgetMaker.parse(md.mdContent.value);
                insertContentNote(widgetsMade);
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  BuildContext? anchorContext;
                  if (anchorKeys.containsKey(initialAnchor)) {
                    anchorContext = anchorKeys[initialAnchor]?.currentContext;
                  }
                  if (anchorContext != null) {
                    Scrollable.ensureVisible(anchorContext);
                  }
                });
                return GestureDetector(
                    onHorizontalDragEnd: (details) {
                      if (details.velocity.pixelsPerSecond.dx < 0 &&
                          nextmd != null) {
                        Get.offNamed('/shloka/$nextmd');
                      } else if (details.velocity.pixelsPerSecond.dx > 0 &&
                          prevmd != null) {
                        Get.offNamed('/shloka/$prevmd');
                      }
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: widgetsMade,
                    ));
              }))
        ])),
        // Positioned(
        //     top: 0,
        //     right: 2,
        //     child: Text(
        //       Chapter.filenameToTitle(mdFilename),
        //       style: TextStyle(color: Theme.of(context).colorScheme.background.withOpacity(0.6)),
        //     )),
      ]),
    );
  }
}

ContentWidget buildContent(String mdFilename,
    {String? initialAnchor,
    String? contentNote,
    String? prevmd,
    String? nextmd,
    Key? key}) {
  return ContentWidget(mdFilename, initialAnchor, contentNote, prevmd, nextmd,
      key: key);
}

ContentWidget buildContentWithNote(String mdFilename,
    {String? initialAnchor, Key? key}) {
  final ContentNotes contentNotes = Get.find();
  return buildContent(mdFilename,
      initialAnchor: initialAnchor,
      contentNote: contentNotes.noteForMD(mdFilename),
      prevmd: contentNotes.prevmd(mdFilename),
      nextmd: contentNotes.nextmd(mdFilename),
      key: key);
}
