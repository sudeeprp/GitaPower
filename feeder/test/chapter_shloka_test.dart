import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:askys/chapter_shloka_widget.dart';
import 'package:askys/choice_selector.dart';
import 'package:askys/content_source.dart';
import 'package:askys/chaptercontent.dart';

const compiledMDtoNoteIds = '''
[{"Back-to-Basics.md": ["applopener_1", "applnote_12"]}, {"Chapter_1.md": []}, {"1-24_to_1-25.md": ["applnote_13"]},  {"Chapter_2.md": []}, {"2-1_to_2-3.md": []}]
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
  testWidgets('shows chapter name of the selected chapter', (tester) async {
    final choices = Choices();
    Get.put(choices);
    Get.put(ChaptersTOC());
    await tester.pumpWidget(GetMaterialApp(home: chapterShlokaScreen('Chapter_1.md')));
    await tester.pumpAndSettle();
    expect(find.text('Chapter 1'), findsOneWidget);
    expect(find.text('1-24 to 1-25'), findsOneWidget);
    expect(find.textContaining('एवम् उक्तो हृषीकेशो'), findsOneWidget);
    choices.headPreference.value = HeadPreference.meaning;
    await tester.pumpAndSettle();
    expect(find.textContaining('Krishna parked'), findsOneWidget);
  });
  testWidgets('navigates to the introduction', (tester) async {
    Get.put(Choices());
    Get.put(ChaptersTOC());
    await tester.pumpWidget(GetMaterialApp(
      home: chapterShlokaScreen('Chapter_1.md'),
      getPages: [
        GetPage(name: '/shloka', page: () => const Text('shloka reached')),
      ],
    ));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Introduction'));
    expect(Get.currentRoute, '/shloka/Chapter_1.md');
  });
}
