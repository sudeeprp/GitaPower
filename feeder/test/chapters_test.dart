import 'package:askys/chapters_widget.dart';
import 'package:askys/choice_selector.dart';
import 'package:askys/content_source.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:askys/chaptercontent.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';

const compiledMDtoNoteIds = '''
[{"Back-to-Basics.md": ["applopener_1", "applnote_12"]}, {"Chapter 1.md": []}, {"1-1.md": ["applnote_13"]}, {"1-12.md": ["applnote_14"]},  {"Chapter_2.md": []}, {"2-1_to_2-3.md": []}]
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
  testWidgets('navigates to a chapter from the toc', (tester) async {
    Get.put(ChaptersTOC());
    Get.put(Choices());

    await tester.pumpWidget(GetMaterialApp(
      home: const ChaptersWidget(),
      getPages: [
        GetPage(name: '/shlokaheaders', page: () => const Text('shloka headers reached')),
      ],
    ));
    await tester.pumpAndSettle();
    final chapterHeadFinder = find.text('Chapter 1');
    await tester.tap(chapterHeadFinder);
    await tester.pumpAndSettle();
    expect(Get.currentRoute, '/shlokaheaders/Chapter_1.md');
    Get.delete<Choices>();
    Get.delete<ChaptersTOC>();
  });
}
