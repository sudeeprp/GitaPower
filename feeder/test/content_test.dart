import 'package:askys/choice_selector.dart';
import 'package:askys/content_actions.dart';
import 'package:askys/content_source.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:askys/content_widget.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';

List<TextSpan> oneTextMaker(MatterForInline inlineMatter) => [TextSpan(text: inlineMatter.text)];
List<Widget> simpleTextRichMaker(List<TextSpan> spans, SectionType sectionType) {
  if (spans.isEmpty) {
    return [];
  } else if (spans.length == 1) {
    return [Text.rich(spans[0])];
  } else {
    return [Text.rich(TextSpan(children: spans))];
  }
}

class TextMade {
  TextMade(this.content, this.sectionType, this.tag, this.elmclass, this.link);
  String? content;
  SectionType sectionType;
  String? tag;
  String? elmclass;
  String? link;
}

class WidgetMade {
  WidgetMade(this.spans, this.sectionType);
  List<TextSpan>? spans;
  SectionType? sectionType;
}

class ParseRecords {
  List<TextMade> textsMade = [];
  List<WidgetMade> widgetsMade = [];
}

ParseRecords recordParseActions(mdContent) {
  var parseRecords = ParseRecords();
  List<TextSpan> inlineMaker(MatterForInline inlineMatter) {
    parseRecords.textsMade.add(TextMade(inlineMatter.text, inlineMatter.sectionType,
        inlineMatter.tag, inlineMatter.elmclass, inlineMatter.link));
    return [];
  }

  List<Widget> widgetMaker(List<TextSpan> spans, SectionType sectionType) {
    parseRecords.widgetsMade.add(WidgetMade(spans, sectionType));
    return [];
  }

  WidgetMaker(widgetMaker, inlineMaker).parse(mdContent);
  return parseRecords;
}

void _fireOnTap(Finder finder, String text) {
  final Element element = finder.evaluate().single;
  final paragraph = element.renderObject as RenderParagraph;
  // The children are the individual TextSpans which have GestureRecognizers
  paragraph.text.visitChildren((dynamic span) {
    if (span.text.contains(text)) {
      (span.recognizer as TapGestureRecognizer).onTap!();
      return false; // stop iterating, we found the one.
    } else {
      return true; // continue iterating.
    }
  });
}

void main() {
  setUp(() {
    final dio = Dio();
    final dioAdapter = DioAdapter(dio: dio);
    dio.httpClientAdapter = dioAdapter;
    dioAdapter.onGet('${GitHubFetcher.mdPath}/Back-to-Basics.md', (server) => server.reply(200, '''
## योग [yOga] - To associate, gain and realize

Yoga is about realization
'''));
    dioAdapter.onGet(
        '${GitHubFetcher.mdPath}/10-10-meaning.md',
        (server) => server.reply(200,
            '`भजताम्` `[bhajatAm]` who worship Me `सतत युक्तानाम्` `[satata yuktAnAm]` to be with Me always'));
    dioAdapter.onGet('${GitHubFetcher.mdPath}/10-11-shloka.md', (server) => server.reply(200, '''
```shloka-sa
तेषाम् एव अनुकम्पार्थम्
```
```shloka-sa-hk
teSAm eva anukampArtham
```'''));
    dioAdapter.onGet('${GitHubFetcher.mdPath}/10-12-anote.md', (server) => server.reply(200, '''
Arjuna says to Krishna - how do we think of You? [See here](10-11-shloka.md#why-think)

<a name='satva_rajas_tamas'></a>
<a name='applnote_156'></a>
>The Lord's qualities cannot be understood
'''));
    dioAdapter.onGet('${GitHubFetcher.mdPath}/6-41-anchor.md', (server) => server.reply(200, '''
<a name='greatness_of_yoga'></a>
A person diverts from the path of realizing the Self due to some desires.
'''));
    dioAdapter.onGet(
        '${GitHubFetcher.mdPath}/18-33-meaning-hyper.md',
        (server) => server.reply(200,
            '`सा धृतिः` `[sA dhRtiH]` - such [resolve](18-29.md#intellect_and_resolve) `सात्विकी` `[sAtvikI]` is sattva'));
    Get.put(GitHubFetcher(dio));
  });
  testWidgets('Renders a plain-text line', (tester) async {
    final widgetWithOneMD =
        WidgetMaker(simpleTextRichMaker, oneTextMaker).parse('work without being driven');
    expect(widgetWithOneMD.length, equals(1));
    await tester.pumpWidget(GetMaterialApp(home: Column(children: widgetWithOneMD)));
    expect(find.text('work without being driven'), findsOneWidget);
  });
  testWidgets('Renders content with meanings as per script preference', (tester) async {
    Get.put(Choices());
    Get.put(ContentActions());
    Get.find<Choices>().script.value = ScriptPreference.devanagari;
    await tester.pumpWidget(GetMaterialApp(home: Scaffold(body: buildContent('10-10-meaning.md'))));
    await tester.pumpAndSettle();

    // to start with, the shloka needs to be read continuously without the source in-between
    final continFinder =
        find.textContaining('who worship Me to be with Me always', findRichText: true);
    expect(continFinder, findsOneWidget);
    expect(find.textContaining('भजताम्', findRichText: true), findsNothing);
    expect(find.textContaining('[bhajatAm]', findRichText: true), findsNothing);

    _fireOnTap(continFinder, 'who worship Me'); // tap to expand with the source
    await tester.pumpAndSettle();
    expect(find.textContaining('भजताम्', findRichText: true), findsOneWidget);
    expect(find.textContaining('[bhajatAm]', findRichText: true), findsNothing);
    Get.find<Choices>().script.value = ScriptPreference.sahk;
    await tester.pumpAndSettle();
    expect(find.textContaining('[bhajatAm]', findRichText: true), findsOneWidget);
    expect(find.textContaining('भजताम्', findRichText: true), findsNothing);

    final meaningFinder = find.textContaining('who worship Me', findRichText: true);
    _fireOnTap(meaningFinder, 'who worship Me'); // tap again for the short meaning
    await tester.pumpAndSettle();
    expect(find.textContaining('भजताम्', findRichText: true), findsNothing);
    expect(find.textContaining('[bhajatAm]', findRichText: true), findsNothing);
    Get.delete<Choices>();
  });
  testWidgets('Renders shloka as per script preference', (tester) async {
    Get.put(Choices());
    Get.put(ContentActions());
    Get.find<Choices>().script.value = ScriptPreference.sahk;
    await tester.pumpWidget(GetMaterialApp(home: Scaffold(body: buildContent('10-11-shloka.md'))));
    await tester.pumpAndSettle();
    expect(find.textContaining('तेषाम्', findRichText: true), findsNothing);
    expect(find.textContaining('teSAm', findRichText: true), findsOneWidget);
    Get.delete<Choices>();
  });
  testWidgets('Renders note and hides the anchor', (tester) async {
    Get.put(Choices());
    Get.put(ContentActions());
    final contentWidget = buildContent('10-12-anote.md');
    await tester.pumpWidget(GetMaterialApp(home: Scaffold(body: contentWidget)));
    await tester.pumpAndSettle();
    expect(find.textContaining('applnote_156'), findsNothing);
    expect(find.byKey(const Key('applnote_156')), findsOneWidget);
    expect(find.byKey(const Key('satva_rajas_tamas')), findsOneWidget);
    expect(find.textContaining('cannot be understood'), findsOneWidget);
    Get.delete<Choices>();
  });
  testWidgets('Shows commentary following an anchor', (tester) async {
    Get.put(Choices());
    Get.put(ContentActions());
    final contentWidget = buildContent('6-41-anchor.md');
    await tester.pumpWidget(GetMaterialApp(home: Scaffold(body: contentWidget)));
    await tester.pumpAndSettle();
    expect(find.textContaining('greatness_of_yoga'), findsNothing);
    expect(find.textContaining('due to some desires'), findsOneWidget);
  });
  testWidgets('Navigates a link in the commentary', (tester) async {
    Get.put(Choices());
    Get.put(ContentActions());
    const targetFilename = '10-11-shloka.md';
    const targetNote = 'why-think';
    await tester.pumpWidget(GetMaterialApp(
      home: buildContent('10-12-anote.md'),
      getPages: [
        GetPage(
            name: '/shloka/$targetFilename/$targetNote', page: () => const Text('anchor reached'))
      ],
    ));
    await tester.pumpAndSettle();
    final linkFinder = find.textContaining('See here', findRichText: true);
    expect(linkFinder, findsOneWidget);
    _fireOnTap(linkFinder, 'See here');
    await tester.tap(linkFinder);
    await tester.pumpAndSettle();
    expect(Get.currentRoute, '/shloka/$targetFilename/$targetNote');
  });
  testWidgets('gives a space after a hyperlink in the meaning', (tester) async {
    Get.put(Choices());
    Get.put(ContentActions());
    await tester.pumpWidget(GetMaterialApp(home: buildContent('18-33-meaning-hyper.md')));
    await tester.pumpAndSettle();
    expect(find.textContaining('such resolve is sattva'), findsOneWidget);
  });
  testWidgets('shows second level headings in intro-basics', (tester) async {
    Get.put(Choices());
    Get.put(ContentActions());
    await tester.pumpWidget(GetMaterialApp(home: buildContent('Back-to-Basics.md')));
    await tester.pumpAndSettle();
    expect(find.textContaining('योग [yOga]'), findsOneWidget);
  });
  testWidgets('page-browse by clicking next and previous buttons', (tester) async {
    Get.put(Choices());
    Get.put(ContentActions());
    final shlokaContent = buildContent('10-11-shloka.md',
        prevmd: '10-10-meaning.md', nextmd: '10-12-anote.md', key: const Key('shloka-current'));
    await tester.pumpWidget(GetMaterialApp(
      home: shlokaContent,
      getPages: [
        GetPage(name: '/shloka/10-10-meaning.md', page: () => const Text('swiped to 10-10')),
        GetPage(name: '/shloka/10-11-shloka.md', page: () => shlokaContent),
        GetPage(name: '/shloka/10-12-anote.md', page: () => const Text('swiped to 10-12')),
      ],
    ));

    ContentActions contentActions = Get.find();
    contentActions.showForAWhile();
    await tester.pumpAndSettle();
    expect(find.widgetWithIcon(FloatingActionButton, Icons.navigate_next), findsOneWidget);
    await tester.tap(find.widgetWithIcon(FloatingActionButton, Icons.navigate_next));
    await tester.pumpAndSettle();
    expect(Get.currentRoute, '/shloka/10-12-anote.md');
    Get.toNamed('/shloka/10-11-shloka.md');
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithIcon(FloatingActionButton, Icons.navigate_before));
    await tester.pumpAndSettle();
    expect(Get.currentRoute, '/shloka/10-10-meaning.md');
  });
  testWidgets('hides page-browse buttons after a while', (tester) async {
    final contentActions = ContentActions();
    contentActions.actionsVisible.value = true;
    contentActions.hideAfterAWhile(1);
    await tester.pumpAndSettle(const Duration(seconds: 1, milliseconds: 500));
    expect(contentActions.actionsVisible.value, equals(false));
  });
  test('Text with inline code remains inline in one widget', () {
    final inlineCode = recordParseActions('inline `source`');
    expect(inlineCode.textsMade[0].content, equals('inline '));
    expect(inlineCode.textsMade[0].tag, equals('p'));
    expect(inlineCode.textsMade[1].content, equals('source'));
    expect(inlineCode.textsMade[1].tag, equals('code'));
    expect(inlineCode.widgetsMade.length, equals(1));
    expect(inlineCode.widgetsMade[0].sectionType, equals(SectionType.commentary));
  });
  test('Text with multiline code is in separate widget', () {
    final headShloka = recordParseActions('''
## 2-54
```shloka-sa
अर्जुन उवाच -
स्थितप्रज्ञस्य
```
''');
    expect(headShloka.textsMade[0].content, equals('2-54'));
    expect(headShloka.textsMade[0].tag, equals('h2'));
    expect(headShloka.textsMade[1].content, equals('अर्जुन उवाच -\nस्थितप्रज्ञस्य'));
    expect(headShloka.textsMade[1].tag, equals('code'));
    expect(headShloka.textsMade[1].elmclass, equals('language-shloka-sa'));
    expect(headShloka.widgetsMade.length, equals(2));
    expect(headShloka.widgetsMade[0].sectionType, equals(SectionType.shlokaNumber));
    expect(headShloka.widgetsMade[1].sectionType, equals(SectionType.shlokaSA));
  });
  test('Makes a single newline with link to span in a single widget', () {
    final oneNewline = recordParseActions('''
To describe someone standing
[firm](sthitaprajna_xlat)
''');
    expect(oneNewline.textsMade[0].content, equals('To describe someone standing '));
    expect(oneNewline.textsMade[1].content, equals('firm'));
    expect(oneNewline.textsMade[1].tag, equals('a'));
    expect(oneNewline.textsMade[1].link, equals('sthitaprajna_xlat'));
    expect(oneNewline.widgetsMade.length, equals(1));
  });
  test('Double newline makes a new row', () {
    final multiNewline = recordParseActions('''
how does he behave?

While describing this
''');
    expect(multiNewline.widgetsMade.length, equals(2));
  });
  test('leading newline in non-code is ignored', () {
    final leadingnl = recordParseActions('''

line after newline''');
    expect(leadingnl.textsMade[0].content, equals('line after newline'));
  });
  test('recognizes a blockquote tag as a note', () {
    final parsedNote = recordParseActions('''
>Do it for Krishna
''');
    expect(parsedNote.textsMade[0].content, equals('Do it for Krishna'));
    expect(parsedNote.textsMade[0].tag, equals('note'));
    expect(parsedNote.widgetsMade.length, equals(1));
  });
  test('retains text adjascent to an anchor', () {
    final parsedNote = recordParseActions('''
<a name='four_types_of_worshippers'></a>
These four categories of virtuous people
''');
    expect(parsedNote.textsMade[0].content, equals('four_types_of_worshippers'));
    expect(parsedNote.textsMade[1].content, equals('These four categories of virtuous people'));
  });
  test('chapter heading is in its own line', () {
    final chapterPage = recordParseActions('''
# Chapter 7

Lord Krishna described the way to realize the Self till Chapter 6.
''');
    expect(chapterPage.textsMade[0].content, equals('Chapter 7'));
    expect(chapterPage.textsMade[0].tag, equals('h1'));
    expect(chapterPage.textsMade[1].content,
        equals('Lord Krishna described the way to realize the Self till Chapter 6.'));
    expect(chapterPage.widgetsMade.length, equals(2));
    expect(chapterPage.widgetsMade[0].sectionType, equals(SectionType.chapterHeading));
    expect(chapterPage.widgetsMade[1].sectionType, equals(SectionType.commentary));
  });
  test('explainer is separated from commentary', () {
    final parsedExplainer = recordParseActions('''
Arjuna asks- Going by the passage of time

_Yuga is a period of time. There are four yugas: `कृत` `[kRta]` or 
`सत्य` `[satya]`
 with 1,728,000 years_
''');
    expect(parsedExplainer.textsMade[1].content, startsWith('Yuga is a period'));
    expect(parsedExplainer.textsMade[1].tag, equals('em'));
    final lastTextMade = parsedExplainer.textsMade.last;
    expect(lastTextMade.tag, equals('em'));
    expect(lastTextMade.content, endsWith('years'));
    expect(parsedExplainer.widgetsMade.length, equals(2));
  });
  test('ignores bullets', () {
    final parsedBullet = recordParseActions('''
- will attain the supreme goal''');
    expect(parsedBullet.textsMade, isEmpty);
  });
  test('treats devanagari in a commentary as commentary itself', () {
    final parsedDevanagariComment = recordParseActions('''
There are many statements in the scriptures

`श्वेताश्वतर उपनिशद्` `[zvetAzvatara upanizad]` , 4-6
 illustrates that the Lord is distinct''');
    expect(parsedDevanagariComment.widgetsMade.last.sectionType, equals(SectionType.commentary));
  });
  test('converts hyperlink in a note to text', () {
    final parsedHyperInNote =
        recordParseActions('''>Achieve [devotion](2-1.md#bhakti) in every activity''');
    expect(parsedHyperInNote.textsMade[1].content, equals('devotion'));
    expect(parsedHyperInNote.widgetsMade.length, equals(1));
  });
  test('marks subheadings in back-to-basics', () {
    final parsedBasics = recordParseActions('''
## आत्म [Atma] - The Self

As the Lord Himself states, it isn't possible to describe the Self.
''');
    expect(parsedBasics.textsMade[0].content, equals('आत्म [Atma] - The Self'));
    expect(parsedBasics.widgetsMade[0].sectionType, equals(SectionType.topicHead));
  });
}
