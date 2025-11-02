import 'package:askys/content_themes.dart';
import 'package:askys/expandable_span.dart';
import 'package:askys/mdcontent.dart';
import 'package:askys/content_actions.dart';
import 'package:askys/screenify.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:askys/choice_selector.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:float_column/float_column.dart';
import 'chaptercontent.dart';
import 'notecontent.dart';
import 'matter_forinline.dart';

final _multipleSpaces = RegExp(r"\s+");
final _anchors = RegExp(r"<a name='([\w]+)'><\/a>\s*");

class CurrentTextElement {
  CurrentTextElement(this.mdElement, this.sectionType, this.isSectionTop);
  final md.Element mdElement;
  final SectionType sectionType;
  final bool isSectionTop;
}

class WidgetMaker implements md.NodeVisitor {
  final List<TextSpan> Function(MatterForInline matterForInline) _inlineMaker;
  final List<Widget> Function(SectionContent, SectionType) _widgetMaker;
  final List<String>? showPatterns;
  final String? searchPhrase;
  SectionType? _previousSectionType;
  List<CurrentTextElement> elementForCurrentText = [];
  List<String> noteIdsInPage = [];
  List<Widget> collectedWidgets = [];
  List<MatterForInline> collectedInlines = [];
  WidgetMaker(this._widgetMaker, this._inlineMaker, {this.showPatterns, this.searchPhrase});

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

  SectionContent _collectedElements(SectionType sectionType) {
    List<TextSpan> collectedElements = [];
    final visibleInlines = selectVisibleInlines(collectedInlines, sectionType);
    final inlinesForDisplay = removeConsecutiveSpaces(visibleInlines);
    for (final inlineMatter in inlinesForDisplay) {
      collectedElements.addAll(_inlineMaker(inlineMatter));
    }
    final isRelevantToSearch = collectedInlines.any((inline) => inline.isRelevantToSearch);
    return SectionContent(collectedElements, isRelevantToSearch);
  }

  @override
  void visitElementAfter(md.Element element) {
    if (elementForCurrentText.last.isSectionTop) {
      collectedWidgets.addAll(_widgetMaker(_collectedElements(elementForCurrentText.last.sectionType),
          elementForCurrentText.last.sectionType));
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
      final sectionType =
          elementForCurrentText.isNotEmpty ? elementForCurrentText.last.sectionType : SectionType.commentary;
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
          collectedInlines
              .add(MatterForInline(noteId, sectionType, 'anchor', elmclass: elmclass, link: link));
        }
      }
    }
    final processedText = _textForElement(markdownText.textContent, element.mdElement);
    if (processedText.isNotEmpty) {
      final inlineMatters = makeMatterForInlines(processedText, element.sectionType, tag,
          elmclass: elmclass, link: link, showPatterns: showPatterns, searchPhrase: searchPhrase);
      collectedInlines.addAll(inlineMatters);
    }
  }

  bool _isSeparate(String elementTag) {
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
    return _previousSectionType == SectionType.commentary || _previousSectionType == SectionType.note;
  }
}

bool _hasAnchor(String inputText) {
  return inputText.trim().startsWith('<a name=');
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

Widget optimizedWidget(List<InlineSpan> spans) {
  if (spans.length == 1) {
    return Text.rich(spans[0]);
  } else {
    return Text.rich(TextSpan(children: spans));
  }
}

Widget constructCommentary(List<TextSpan> spans) {
  final List<InlineSpan> commenter = [
    WidgetSpan(
        child: Floatable(
      float: FCFloat.start,
      child: Padding(padding: const EdgeInsets.only(left: 1, top: 10, right: 5), child: avataraRamanuja()),
    )),
  ];
  return FloatColumn(children: [TextSpan(children: commenter + spans)]);
}

Widget avataraRamanuja({String? key}) {
  return GestureDetector(
    onTap: () => Get.toNamed('/shloka/ramanuja.md/ramanuja3'),
    child: CircleAvatar(
        key: key != null ? Key(key) : null, radius: 20, backgroundImage: AssetImage('images/ramanuja3.png')),
  );
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
  if (sectionType == SectionType.shlokaSA) {
    return scriptChoice == ScriptPreference.devanagari;
  } else if (sectionType == SectionType.shlokaSAHK) {
    return scriptChoice == ScriptPreference.sahk;
  }
  return true;
}

Widget _horizontalScrollForOneLiners(SectionType sectionType, Widget w) {
  const horizontalMargins = EdgeInsets.symmetric(horizontal: 8);
  if (sectionType == SectionType.shlokaSAHK || sectionType == SectionType.shlokaSA) {
    return SingleChildScrollView(scrollDirection: Axis.horizontal, padding: horizontalMargins, child: w);
  } else {
    return Padding(padding: horizontalMargins, child: w);
  }
}

Widget _buildNote(BuildContext context, Widget content) {
  return Card(
    color: contentColors(context)?.noteBackground,
    elevation: 3,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
    child: Row(children: [
      Padding(
          padding: const EdgeInsets.only(left: 3, top: 2, bottom: 2),
          child: Image.asset('images/one-step.png')),
      Expanded(child: Padding(padding: const EdgeInsets.only(left: 3, top: 8, bottom: 8), child: content))
    ]),
  );
}

List<MatterForInline> removeConsecutiveSpaces(List<MatterForInline> inputInlineSeq) {
  String lastEnding = ' ';
  List<MatterForInline> visibleInlineSeq = [];
  for (var oneInline in inputInlineSeq) {
    String outputText = oneInline.text;
    if (RegExp(r'\s$').hasMatch(lastEnding) && RegExp(r'^\s').hasMatch(oneInline.text)) {
      outputText = oneInline.text.replaceFirst(RegExp(r'^\s+'), '');
    }
    if (outputText.isNotEmpty) {
      final visibleInline = oneInline;
      visibleInline.text = outputText;
      visibleInlineSeq.add(visibleInline);
      lastEnding = oneInline.text[oneInline.text.length - 1];
    }
  }
  return visibleInlineSeq;
}

List<MatterForInline> selectVisibleInlines(List<MatterForInline> inlineMatterSeq, SectionType sectionType) {
  if (sectionType != SectionType.meaning) {
    return inlineMatterSeq;
  }
  final Choices choice = Get.find();
  List<MatterForInline> visibleInlines = [];
  if (choice.meaningMode.value == MeaningMode.expanded) {
    if (choice.script.value == ScriptPreference.devanagari) {
      visibleInlines = inlineMatterSeq.where((oneInline) => !_isSAHK(oneInline.text)).toList();
    } else if (choice.script.value == ScriptPreference.sahk) {
      visibleInlines = inlineMatterSeq.where((oneInline) => !_startsWithDevanagari(oneInline.text)).toList();
    }
  } else {
    visibleInlines = inlineMatterSeq
        .where((oneInline) => !_isSAHK(oneInline.text) && !_startsWithDevanagari(oneInline.text))
        .toList();
  }
  return visibleInlines;
}

Widget _contentSpacing(BuildContext context, Widget w) {
  return Container(
    decoration: BoxDecoration(
      color: contentColors(context)?.commentaryBackground,
      boxShadow: <BoxShadow>[
        BoxShadow(
            color: Colors.grey.withValues(alpha: 0.5),
            blurRadius: 2.0,
            spreadRadius: -16.0,
            offset: const Offset(5.0, 22.0))
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

TextStyle? styleFor(BuildContext context, String tag,
    {String? elmclass, Presentation? presentation, bool isRelevantToSearch = false}) {
  FontWeight? fontWeight;
  if (presentation != null && presentation == Presentation.emphasis) {
    fontWeight = FontWeight.bold;
  }
  Color? backgroundColor;
  if (isRelevantToSearch) {
    backgroundColor = Colors.yellow.withValues(alpha: 0.5);
  }
  if (elmclass == 'language-shloka-sa') {
    return GoogleFonts.roboto(
        color: contentColors(context)?.codeTextColor,
        fontSize: 20,
        fontWeight: fontWeight,
        backgroundColor: backgroundColor);
  } else if (tag == 'code') {
    return GoogleFonts.roboto(
        color: contentColors(context)?.codeTextColor,
        fontSize: 18,
        fontWeight: fontWeight,
        backgroundColor: backgroundColor);
  } else if (tag == 'h1') {
    return Theme.of(context).textTheme.headlineMedium;
  } else if (tag == 'h2') {
    return Theme.of(context).textTheme.headlineSmall?.copyWith(height: 3, backgroundColor: backgroundColor);
  } else if (tag == 'em') {
    return GoogleFonts.roboto(
        height: 1.5,
        fontStyle: FontStyle.italic,
        fontSize: 16,
        fontWeight: fontWeight,
        backgroundColor: backgroundColor);
  } else if (tag == 'note') {
    return TextStyle(fontSize: 14, fontWeight: fontWeight, backgroundColor: backgroundColor);
  } else {
    return TextStyle(
        color: contentColors(context)?.commentaryTextColor,
        height: 1.75,
        fontSize: 18,
        fontWeight: fontWeight,
        backgroundColor: backgroundColor);
  }
}

class SectionContent {
  List<TextSpan> spans;
  bool isRelevantToSearch;
  SectionContent(this.spans, this.isRelevantToSearch);
}

class ContentWidget extends StatelessWidget {
  ContentWidget(this.mdFilename, this.initialAnchor, this.prevmd, this.nextmd,
      {this.onTap, this.searchPhrase, super.key}) {
    Get.lazyPut(() => MDContent(mdFilename), tag: mdFilename);
  }

  final String mdFilename;
  final String? initialAnchor;
  final String? nextmd;
  final String? prevmd;
  final void Function()? onTap;
  final String? searchPhrase;

  List<String>? playableShows() {
    final ShowWords showWords = Get.find();
    if (showWords.mdFilenamePlaying != null) {
      return showWords.words;
    }
    return null;
  }

  @override
  Widget build(context) {
    Map<String, GlobalKey> anchorKeys = {};
    List<Widget> textRichMaker(SectionContent sectionContent, SectionType sectionType) {
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
                child: Text.rich(TextSpan(children: sectionContent.spans),
                    style: Theme.of(context).textTheme.headlineSmall)),
          )
        ];
      }
      return [
        Obx(() {
          GlobalKey? searchKey;
          bool visibility = _isVisible(sectionType);
          if (sectionContent.isRelevantToSearch) {
            searchKey = GlobalKey();
            visibility = true;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (searchKey!.currentContext != null) {
                Scrollable.ensureVisible(searchKey.currentContext!,
                    duration: const Duration(milliseconds: 300));
              }
            });
          }
          return Visibility(
            key: searchKey,
            visible: visibility,
            child: _sectionContainer(context, sectionType, _spansToText(sectionContent.spans, sectionType)),
          );
        }),
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
            style: styleFor(context, 'anchor')?.copyWith(color: Colors.blue),
            recognizer: TapGestureRecognizer()..onTap = () => navigateToLink(inlineMatter.link),
          )
        ];
      }
      return [
        TextSpan(
          text: inlineMatter.text,
          style: styleFor(context, inlineMatter.tag,
              elmclass: inlineMatter.elmclass,
              presentation: inlineMatter.presentation,
              isRelevantToSearch: inlineMatter.isRelevantToSearch),
        )
      ];
    }

    MDContent md = Get.find(tag: mdFilename);
    return Center(
        child: SingleChildScrollView(
      child: DefaultTextStyle(
        style: DefaultTextStyle.of(context).style.apply(fontSizeFactor: 1.3),
        child: Obx(() {
          final widgetMaker = WidgetMaker(textRichMaker, formatMaker,
              showPatterns: playableShows(), searchPhrase: searchPhrase);
          final widgetsMade = widgetMaker.parse(md.mdContent.value);
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
              onTap: onTap,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: widgetsMade,
              ));
        }),
      ),
    ));
  }

  Widget _spansToText(List<TextSpan> spans, SectionType sectionType) {
    if (spans.isEmpty) {
      return const Text('');
    } else if (sectionType == SectionType.commentary) {
      return constructCommentary(spans);
    } else if (sectionType == SectionType.anchor) {
      return SizedBox.shrink(child: Text.rich(TextSpan(children: spans)));
    } else if (sectionType == SectionType.meaning) {
      return ExpandableMeaning(optimizedWidget(spans), identifier: mdFilename);
    } else if (sectionType == SectionType.shlokaSA || sectionType == SectionType.shlokaSAHK) {
      return ExpandableShloka(optimizedWidget(spans), identifier: mdFilename);
    } else {
      return optimizedWidget(spans);
    }
  }
}

class ShlokaContentReader extends StatelessWidget {
  const ShlokaContentReader(this.mdFilename, {this.initialAnchor, super.key});

  final String mdFilename;
  final String? initialAnchor;
  @override
  Widget build(BuildContext context) {
    final ChaptersTOC chapterstoc = Get.find();
    final prevmd = chapterstoc.prevmd(mdFilename);
    final nextmd = chapterstoc.nextmd(mdFilename);
    var contentWidget = buildContent(mdFilename,
        initialAnchor: initialAnchor,
        prevmd: prevmd,
        nextmd: nextmd,
        onTap: Get.find<ContentActions>().showForAWhile,
        key: key);
    var contentActions = Get.find<ContentActions>();
    contentActions.initialShowForAWhile();
    return Stack(children: [contentWidget, ...navigationButtons(context, mdFilename, nextmd, prevmd)]);
  }
}

Widget preContentNote(BuildContext context, String mdFilename) {
  final ContentNotes contentNotes = Get.find();
  return Obx(() {
    if (contentNotes.notesLoaded.value) {
      final preNote = contentNotes.noteForMD(mdFilename);
      if (preNote != null) {
        return Row(children: [
          Image.asset('images/one-step.png', width: 32, height: 32),
          const SizedBox(width: 8),
          Expanded(
              child: Text(toPlainText(preNote),
                  style: styleFor(context, 'note')?.copyWith(fontSize: 10), softWrap: true, maxLines: 3)),
        ]);
      }
    }
    return const SizedBox.shrink();
  });
}

ContentWidget buildContent(String mdFilename,
    {String? initialAnchor,
    String? prevmd,
    String? nextmd,
    void Function()? onTap,
    String? searchPhrase,
    Key? key}) {
  Get.put(ExpansionController(), tag: mdFilename);
  return ContentWidget(mdFilename, initialAnchor, prevmd, nextmd,
      onTap: onTap, searchPhrase: searchPhrase, key: key);
}

Widget buildContentWithNote(String mdFilename, {String? initialAnchor, Key? key}) {
  return ShlokaContentReader(mdFilename, initialAnchor: initialAnchor);
}

ContentWidget buildContentFeed(String mdFilename, {Key? key, String? searchPhrase}) {
  return buildContent(mdFilename, onTap: () {
    Get.toNamed('/shloka/$mdFilename');
  }, searchPhrase: searchPhrase, key: key);
}

class ContentScreen extends StatelessWidget {
  const ContentScreen(this.mdFilename, this.choicesRow, {this.initialAnchor, super.key});

  final String mdFilename;
  final Widget choicesRow;
  final String? initialAnchor;

  @override
  Widget build(BuildContext context) {
    return screenify(buildContentWithNote(mdFilename, initialAnchor: initialAnchor),
        appBar: AppBar(title: preContentNote(context, mdFilename), actions: [
          Text(Chapter.filenameToShortTitle(mdFilename), style: Theme.of(context).textTheme.bodySmall),
          SizedBox(width: 12)
        ]),
        choicesRow: choicesRow);
  }
}
