import 'package:askys/chapters_widget.dart';
import 'package:askys/content_source.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:askys/chaptercontent.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';

const compiledMDtoNoteIds = '''
[{"Back-to-Basics.md": ["applopener_1", "applnote_12"]}, {"Chapter 1.md": []}, {"1-1.md": ["applnote_13"]}, {"1-12.md": ["applnote_14"]}]
''';

void main() {
  Get.testMode = true;
  setUp(() {
    final dio = Dio();
    final dioAdapter = DioAdapter(dio: dio);
    dio.httpClientAdapter = dioAdapter;
    dioAdapter.onGet('${GitHubFetcher.compiledPath}/md_to_note_ids_compiled.json',
        (server) => server.reply(200, compiledMDtoNoteIds));
    Get.put(GitHubFetcher(dio));
  });
  testWidgets('navigates to a shloka from the chapters toc', (WidgetTester tester) async {
    Get.put(ChaptersTOC());

    await tester.pumpWidget(GetMaterialApp(
      home: const ChaptersWidget(),
      getPages: [GetPage(name: '/shloka', page: () => const Text('shloka reached'))],
    ));
    await tester.pumpAndSettle();
    expect(find.byType(ListView), findsOneWidget);

    await tester.tap(find.text('Chapter 1'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('1-1'));
    await tester.pumpAndSettle();
    expect(Get.currentRoute, '/shloka/1-1.md');

    Get.delete<ChaptersTOC>();
  });
  testWidgets('navigates to a chapter from the toc', (tester) async {
    Get.put(ChaptersTOC());

    await tester.pumpWidget(GetMaterialApp(
      home: const ChaptersWidget(),
      getPages: [GetPage(name: '/shloka', page: () => const Text('shloka reached'))],
    ));
    await tester.pumpAndSettle();
    final chapterHeadFinder = find.text('Chapter 1');
    final chapterHeadWidget = tester.firstWidget(chapterHeadFinder);
    await tester.tap(chapterHeadFinder);
    await tester.pumpAndSettle();
    final chapterEntries = tester.widgetList(find.text('Chapter 1'));
    expect(chapterEntries.length, equals(2)); // 2 = one parent + one child
    Widget? chapterEntryWidget; // get the child
    for (final entry in chapterEntries) {
      if (entry != chapterHeadWidget) {
        chapterEntryWidget = entry;
        break;
      }
    }
    expect(chapterEntryWidget, isNotNull);
    await tester.tap(find.byWidget(chapterEntryWidget!));
    await tester.pumpAndSettle();
    expect(Get.currentRoute, '/shloka/Chapter_1.md');
  });
}
