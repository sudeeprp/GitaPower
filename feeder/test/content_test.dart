import 'package:askys/choice_selector.dart';
import 'package:askys/content_source.dart';
import 'package:flutter/material.dart';
import 'package:askys/content_widget.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';

List<TextSpan> oneTextMaker(String content, String tag, String? elmclass, String? link) =>
    [TextSpan(text: content)];
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
  TextMade(this.content, this.tag, this.elmclass, this.link);
  String? content;
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
  List<TextSpan> inlineMaker(String content, String tag, String? elmclass, String? link) {
    parseRecords.textsMade.add(TextMade(content, tag, elmclass, link));
    return [];
  }

  List<Widget> widgetMaker(List<TextSpan> spans, SectionType sectionType) {
    parseRecords.widgetsMade.add(WidgetMade(spans, sectionType));
    return [];
  }

  WidgetMaker(widgetMaker, inlineMaker).parse(mdContent);
  return parseRecords;
}

void main() {
  setUp(() {
    final dio = Dio();
    final dioAdapter = DioAdapter(dio: dio);
    dio.httpClientAdapter = dioAdapter;
    dioAdapter.onGet('${GitHubFetcher.mdPath}/10-10.md',
        (server) => server.reply(200, '`भजताम्` `[bhajatAm]` who worship Me'));
    dioAdapter.onGet('${GitHubFetcher.mdPath}/10-11-shloka.md', (server) => server.reply(200, '''
```shloka-sa
तेषाम् एव अनुकम्पार्थम्
```
```shloka-sa-hk
teSAm eva anukampArtham
```'''));
    dioAdapter.onGet('${GitHubFetcher.mdPath}/10-12-anote.md', (server) => server.reply(200, '''
Arjuna says to Krishna - how do we think of You?

<a name='applnote_156'></a>
>The Lord's qualities cannot be understood
'''));
    Get.put(GitHubFetcher(dio));
  });
  testWidgets('Renders a plain-text line', (WidgetTester tester) async {
    final widgetWithOneMD =
        WidgetMaker(simpleTextRichMaker, oneTextMaker).parse('work without being driven');
    expect(widgetWithOneMD.length, equals(1));
    await tester.pumpWidget(GetMaterialApp(home: Column(children: widgetWithOneMD)));
    expect(find.text('work without being driven'), findsOneWidget);
  });
  testWidgets('Renders content with meanings as per script preference', (tester) async {
    Get.put(Choices());
    Get.find<Choices>().script.value = ScriptPreference.devanagari;
    await tester.pumpWidget(GetMaterialApp(home: Scaffold(body: ContentWidget('10-10.md', null))));
    await tester.pumpAndSettle();
    expect(find.textContaining('who worship Me', findRichText: true), findsOneWidget);
    expect(find.textContaining('भजताम्', findRichText: true), findsOneWidget);
    expect(find.textContaining('[bhajatAm]', findRichText: true), findsNothing);
    Get.find<Choices>().script.value = ScriptPreference.sahk;
    await tester.pumpAndSettle();
    expect(find.textContaining('[bhajatAm]', findRichText: true), findsOneWidget);
    expect(find.textContaining('भजताम्', findRichText: true), findsNothing);
    Get.delete<Choices>();
  });
  testWidgets('Renders shloka as per script preference', (tester) async {
    Get.put(Choices());
    Get.find<Choices>().script.value = ScriptPreference.sahk;
    await tester
        .pumpWidget(GetMaterialApp(home: Scaffold(body: ContentWidget('10-11-shloka.md', null))));
    await tester.pumpAndSettle();
    expect(find.textContaining('तेषाम्', findRichText: true), findsNothing);
    expect(find.textContaining('teSAm', findRichText: true), findsOneWidget);
    Get.delete<Choices>();
  });
  testWidgets('Renders notes in a distinct background and hides the anchor', (tester) async {
    Get.put(Choices());
    await tester
        .pumpWidget(GetMaterialApp(home: Scaffold(body: ContentWidget('10-12-anote.md', null))));
    await tester.pumpAndSettle();
    final noteWidgetContainer = tester.widget(find.ancestor(
        of: find.textContaining('cannot be understood', findRichText: true),
        matching: find.byType(Container))) as Container;
    final backgroundOpacity = (noteWidgetContainer.decoration as BoxDecoration).color?.opacity;
    expect(backgroundOpacity, isNot(0));
    expect(find.textContaining('applnote_156'), findsNothing);
    expect(find.byKey(const Key('applnote_156')), findsOneWidget);
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
  });
}
