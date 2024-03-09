import 'package:askys/mdcontent.dart';
import 'package:askys/content_actions.dart';
import 'package:drop_cap_text/drop_cap_text.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:askys/choice_selector.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:float_column/float_column.dart';

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
  explainer,
  note,
  anchor
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
  MatterForInline(this.text, this.sectionType, this.tag, this.elmclass, this.link);
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
    md.Document document = md.Document(encodeHtml: false);
    for (md.Node node in document.parseLines(lines)) {
      node.accept(this);
    }
    return collectedWidgets;
  }

  void _moveToNextSection() {
    collectedInlines = [];
  }

  bool _containsExplainer(md.Element element) {
    if (element.children != null) {
      for (final childNode in element.children!) {
        if (childNode is md.Element && childNode.tag == 'em') {
          return true;
        }
      }
    }
    return false;
  }

  SectionType _sectionTypeInPara(md.Element element) {
    if (_startsWithDevanagari(element.textContent) && !_inMidstOfCommentary()) {
      return SectionType.meaning;
    } else if (element.textContent.startsWith('<a name=') && element.textContent.endsWith('</a>')) {
      return SectionType.anchor;
    } else if (_containsExplainer(element)) {
      return SectionType.explainer;
    }
    return SectionType.commentary;
  }

  SectionType _detectSectionType(md.Element element) {
    final classToSectionType = {
      'language-shloka-sa': SectionType.shlokaSA,
      'language-shloka-sa-hk': SectionType.shlokaSAHK
    };
    final tagToSectionType = {
      'h1': (element) => SectionType.chapterHeading,
      'h2': (element) => _headingType(element.textContent),
      'pre': (element) => classToSectionType[element.children[0].attributes['class']],
      'p': (element) => _sectionTypeInPara(element),
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
      collectedWidgets
          .addAll(_widgetMaker(_collectedElements(), elementForCurrentText.last.sectionType));
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
      elementForCurrentText.add(CurrentTextElement(element, sectionType, false));
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
        elementForCurrentText[elementForCurrentText.length - 2].mdElement.tag == 'blockquote') {
      tag = 'note';
    }
    if (_hasAnchor(markdownText.textContent)) {
      final anchorMatches = _anchors.allMatches(markdownText.textContent);
      for (final anchor in anchorMatches) {
        final noteId = anchor.group(1);
        if (noteId != null) {
          noteIdsInPage.add(noteId);
          final sectionType = noteId.startsWith('appl') ? SectionType.anchor : element.sectionType;
          collectedInlines.add(MatterForInline(noteId, sectionType, 'anchor', elmclass, link));
        }
      }
    }
    final processedText = _textForElement(markdownText.textContent, element.mdElement);
    if (processedText.isNotEmpty) {
      final inlineMatter = MatterForInline(processedText, element.sectionType, tag, elmclass, link);
      collectedInlines.add(inlineMatter);
    }
  }

  bool _isSeparate(elementTag) {
    const widgetSeparators = ['h1', 'h2', 'p', 'pre', 'blockquote'];
    return widgetSeparators.contains(elementTag) &&
        (elementForCurrentText.isEmpty || elementForCurrentText.last.mdElement.tag != 'blockquote');
  }

  String _textForElement(String inputText, md.Element element) {
    if (element.tag == 'code') {
      return inputText.trim();
    } else {
      return inputText.replaceAll(_multipleSpaces, " ").replaceAll(_anchors, "");
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

List<TextSpan> _renderMeaning(
    List<TextSpan> spans, MeaningMode meaningMode, ScriptPreference scriptChoice) {
  List<TextSpan> spansToRender = [];
  if (meaningMode == MeaningMode.expanded) {
    if (scriptChoice == ScriptPreference.devanagari) {
      spansToRender = spans.where((textSpan) => !_isSAHK(textSpan.text)).toList();
    } else if (scriptChoice == ScriptPreference.sahk) {
      spansToRender = spans.where((textSpan) => !_startsWithDevanagari(textSpan.text)).toList();
    }
  } else {
    spansToRender = spans
        .where((textSpan) => !_isSAHK(textSpan.text) && !_startsWithDevanagari(textSpan.text))
        .toList();
  }
  return spansToRender;
}

Widget _spansToText(List<TextSpan> spans, SectionType sectionType) {
  Choices choice = Get.find();
  final scriptChoice = choice.script.value;
  final meaningMode = choice.meaningMode.value;
  List<InlineSpan> visibleSpans = [];
  if (sectionType == SectionType.meaning) {
    visibleSpans = _renderMeaning(spans, meaningMode, scriptChoice);
  } else {
    visibleSpans = spans;
  }
  if (visibleSpans.isEmpty) {
    return const Text('');
  } else if (sectionType == SectionType.commentary) {
    final List<InlineSpan> commenter = [
      WidgetSpan(
          child: Floatable(
              float: FCFloat.start,
              child: DropCap(
                width: 50,
                height: 50,
                child: const Padding(
                  padding: EdgeInsets.only(left: 1, top: 10, right: 5),
                  child:
                      CircleAvatar(radius: 20, backgroundImage: AssetImage('images/ramanuja3.png')),
                ),
              )))
    ];
    visibleSpans = commenter + spans;
    return FloatColumn(children: [TextSpan(children: visibleSpans)]);
  } else if (sectionType == SectionType.anchor) {
    return SizedBox.shrink(child: Text.rich(TextSpan(children: visibleSpans)));
  } else if (visibleSpans.length == 1) {
    return Text.rich(visibleSpans[0]);
  } else {
    return Text.rich(TextSpan(children: visibleSpans));
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

void navigateToLink(String? link) {
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
      WidgetSpan(child: Container(key: keyOfAnchor, child: _anchorWidget(noteId))),
    ])
  ];
}

Widget _anchorWidget(String noteId) {
  // anchor widget isn't visible, but is required to scroll to it on opening.
  return SizedBox(width: 1, height: 1, key: Key(noteId));
}

bool _isVisible(SectionType sectionType) {
  Choices choice = Get.find();
  // Assignment to a local variable is needed. Otherwise GetX throws an error when "return true" doesn't access any observable.
  final scriptChoice = choice.script.value;
  final headPreference = choice.headPreference.value;
  if (sectionType == SectionType.shlokaSA) {
    return scriptChoice == ScriptPreference.devanagari && headPreference == HeadPreference.shloka;
  } else if (sectionType == SectionType.shlokaSAHK) {
    return scriptChoice == ScriptPreference.sahk && headPreference == HeadPreference.shloka;
  }
  return true;
}

Widget _horizontalScrollForOneLiners(SectionType sectionType, Widget w) {
  const horizontalMargins = EdgeInsets.symmetric(horizontal: 8);
  if (sectionType == SectionType.shlokaSAHK || sectionType == SectionType.shlokaSA) {
    return SingleChildScrollView(
        scrollDirection: Axis.horizontal, padding: horizontalMargins, child: w);
  } else {
    return Padding(padding: horizontalMargins, child: w);
  }
}

Widget _buildNote(BuildContext context, Widget content) {
  return Card(
    elevation: 5,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
    child: Row(children: [
      Image.asset('images/one-step.png'),
      Expanded(
          child:
              Padding(padding: const EdgeInsets.only(left: 3, top: 8, bottom: 8), child: content))
    ]),
  );
}

String _tuneContentForDisplay(MatterForInline inlineMatter) {
  String contentForDisplay = inlineMatter.text;
  if (inlineMatter.sectionType == SectionType.meaning && inlineMatter.tag != 'code') {
    final Choices choice = Get.find();
    if (choice.meaningMode.value == MeaningMode.short) {
      contentForDisplay = inlineMatter.text.trimLeft();
    }
  }
  return contentForDisplay;
}

Widget _contentSpacing(BuildContext context, Widget w) {
  return Container(
    decoration: BoxDecoration(
      color: Theme.of(context).cardColor,
      boxShadow: <BoxShadow>[
        BoxShadow(
            color: Colors.grey, blurRadius: 3.0, spreadRadius: -15.0, offset: Offset(5.0, 25.0))
      ],
    ),
    margin: const EdgeInsets.symmetric(vertical: 10),
    child: w,
  );
}

Widget _sectionContainer(BuildContext context, SectionType sectionType, Widget content) {
  if (sectionType == SectionType.note) {
    return _buildNote(context, content);
  } else if (sectionType == SectionType.shlokaSA ||
      sectionType == SectionType.shlokaSAHK ||
      sectionType == SectionType.meaning) {
    return Container(
        decoration: BoxDecoration(
            image: DecorationImage(
          image: AssetImage(Theme.of(context).brightness == Brightness.light
              ? 'images/lightpaper.png'
              : 'images/darkpaper.png'),
          repeat: ImageRepeat.repeat,
        )),
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
          child: _horizontalScrollForOneLiners(sectionType, content),
        ));
  } else if (sectionType == SectionType.anchor) {
    return content;
  }
  return _contentSpacing(context, _horizontalScrollForOneLiners(sectionType, content));
}

class ContentWidget extends StatelessWidget {
  ContentWidget(this.mdFilename, this.initialAnchor, this.contentNote, this.prevmd, this.nextmd,
      {super.key}) {
    Get.lazyPut(() => MDContent(mdFilename), tag: mdFilename);
  }

  final String mdFilename;
  final String? initialAnchor;
  final String? contentNote;
  final String? nextmd;
  final String? prevmd;

  @override
  Widget build(context) {
    Map<String, GlobalKey> anchorKeys = {};
    List<Widget> textRichMaker(List<TextSpan> spans, SectionType sectionType) {
      if (sectionType == SectionType.shlokaNumber) {
        return []; // Shloka number is now on the top-right
      }
      if (sectionType == SectionType.topicHead) {
        return [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 5),
            decoration: const BoxDecoration(border: Border(top: BorderSide(color: Colors.grey))),
            child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Text.rich(TextSpan(children: spans),
                    style: Theme.of(context).textTheme.headlineSmall)),
          )
        ];
      }
      return [
        Obx(() => Visibility(
              visible: _isVisible(sectionType),
              child: _sectionContainer(context, sectionType, _spansToText(spans, sectionType)),
            ))
      ];
    }

    TextStyle? styleFor(String tag, {String? elmclass}) {
      if (elmclass == 'language-shloka-sa') {
        return GoogleFonts.roboto(
            color: Theme.of(context).textTheme.labelMedium?.color, fontSize: 20);
      } else if (tag == 'code') {
        return GoogleFonts.roboto(
            color: Theme.of(context).textTheme.labelMedium?.color, fontSize: 18);
      } else if (tag == 'h1') {
        return Theme.of(context).textTheme.headlineMedium;
      } else if (tag == 'h2') {
        return Theme.of(context).textTheme.headlineSmall?.copyWith(height: 3);
      } else if (tag == 'em') {
        return GoogleFonts.caveat(height: 1.5, fontSize: 24);
      } else if (tag == 'note') {
        return const TextStyle(fontSize: 14);
      } else {
        return const TextStyle(height: 1.5, fontSize: 18);
      }
    }

    List<TextSpan> formatMaker(MatterForInline inlineMatter) {
      if (inlineMatter.tag == 'anchor') {
        return _anchorSpan(inlineMatter.text, anchorKeys);
      }
      if (inlineMatter.tag == 'a') {
        return [
          TextSpan(
            text: inlineMatter.text,
            style: styleFor('anchor')?.copyWith(color: Colors.blue),
            recognizer: TapGestureRecognizer()..onTap = () => navigateToLink(inlineMatter.link),
          ),
          const TextSpan(text: ' ')
        ];
      }
      var textContent = _tuneContentForDisplay(inlineMatter);
      return [
        TextSpan(
            text: textContent,
            style: styleFor(inlineMatter.tag, elmclass: inlineMatter.elmclass),
            recognizer: _actionFor(inlineMatter.sectionType, inlineMatter.tag))
      ];
    }

    void insertContentNote(List<Widget> contentWidgets) {
      if (contentNote != null) {
        contentWidgets.insert(
            0,
            _buildNote(
                context,
                IntrinsicHeight(
                    child: Row(children: [
                  Expanded(
                      flex: 17,
                      child: Text.rich(TextSpan(text: toPlainText(contentNote!)),
                          style: styleFor('note'))),
                  const VerticalDivider(thickness: 1, indent: 5, endIndent: 5, color: Colors.grey),
                  Expanded(
                    flex: 3,
                    child: Text(Chapter.filenameToShortTitle(mdFilename),
                        style: Theme.of(context).textTheme.bodySmall),
                  )
                ]))));
      }
    }

    MDContent md = Get.find(tag: mdFilename);
    return Stack(children: [
      Center(
          child: SingleChildScrollView(
        child: DefaultTextStyle(
          style: DefaultTextStyle.of(context).style.apply(fontSizeFactor: 1.3),
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
                Scrollable.ensureVisible(anchorContext, alignment: 0.3);
              }
            });
            return GestureDetector(
                onTap: Get.find<ContentActions>().showForAWhile,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: widgetsMade,
                ));
          }),
        ),
      )),
      ...navigationButtons(context, mdFilename, nextmd, prevmd),
    ]);
  }
}

ContentWidget buildContent(String mdFilename,
    {String? initialAnchor, String? contentNote, String? prevmd, String? nextmd, Key? key}) {
  return ContentWidget(mdFilename, initialAnchor, contentNote, prevmd, nextmd, key: key);
}

ContentWidget buildContentWithNote(String mdFilename, {String? initialAnchor, Key? key}) {
  final ContentNotes contentNotes = Get.find();
  var contentWidget = buildContent(mdFilename,
      initialAnchor: initialAnchor,
      contentNote: contentNotes.noteForMD(mdFilename),
      prevmd: contentNotes.prevmd(mdFilename),
      nextmd: contentNotes.nextmd(mdFilename),
      key: key);
  var contentActions = Get.find<ContentActions>();
  contentActions.showForAWhile();
  return contentWidget;
}
