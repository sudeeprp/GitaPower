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
    dioAdapter.onGet(
        'https://raw.githubusercontent.com/RaPaLearning/gita-begin/main/compile/md_to_note_ids_compiled.json',
        (server) => server.reply(200, compiledMDtoNoteIds));
    Get.put(GitHubFetcher(dio));
  });
  testWidgets('navigates to a shloka from the chapters toc',
      (WidgetTester tester) async {
    final mockToc = ChaptersTOC();
    mockToc.chaptersLoaded.value = false;
    Get.put(mockToc);

    await tester.pumpWidget(GetMaterialApp(
      home: const ChaptersWidget(),
      getPages: [
        GetPage(name: '/shloka', page: () => const Text('shloka reached'))
      ],
    ));
    await tester.pumpAndSettle();
    expect(find.byType(ListView), findsOneWidget);

    await tester.tap(find.text('Chapter 1'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('1-1'));
    await tester.pumpAndSettle();
    expect(Get.currentRoute, '/shloka');
    expect(Get.arguments, '1-1.md');
  });

  // testWidgets('Shows list of chapters after loading',
  //     (WidgetTester tester) async {
  //   final mockToc = ChaptersTOC();
  //   mockToc.chaptersLoaded.value = true;
  //   Get.put(mockToc);

  //   await tester.pumpWidget(const GetMaterialApp(home: ChaptersWidget()));

  //   expect(find.byType(ListView), findsOneWidget);
  //   expect(find.byType(ExpansionTile), findsNWidgets(mockToc.chapters.length));
  // });
  // testWidgets('tapping a shloka navigates to the shloka',
  //     (WidgetTester tester) async {
  //   final mockToc = ChaptersTOC();
  //   mockToc.chaptersLoaded.value = true;
  //   Get.put(mockToc);

  //   await tester.pumpWidget(const GetMaterialApp(home: ChaptersWidget()));

  //   await tester.tap(find.byType(ListTile).at(0));
  //   await tester.pump();

  //   expect(Get.currentRoute, '/shloka');
  //   expect(Get.arguments, '${mockToc.chapters[0].shokas[0]}.md');
  // });
}
