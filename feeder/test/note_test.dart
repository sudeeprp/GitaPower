import 'package:askys/notecontent.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:askys/content_source.dart';
import 'package:askys/notes_widget.dart';

const compiledNotesJsonStr = '''
[{"note_id": "applopener_1", "text": "Who am I?", "file": "Back-to-Basics.md"}, {"note_id": "applnote_2", "text": "I am not my body, am I?", "file": "Back-to-Basics.md"}]
''';

void main() {
  Get.testMode = true;
  setUp(() {
    final dio = Dio();
    final dioAdapter = DioAdapter(dio: dio);
    dio.httpClientAdapter = dioAdapter;
    dioAdapter.onGet('${GitHubFetcher.compiledPath}/notes_compiled.json',
        (server) => server.reply(200, compiledNotesJsonStr));
    Get.put(GitHubFetcher(dio));
  });
  testWidgets('navigates to a note from the openers toc', (WidgetTester tester) async {
    Get.put(NotesTOC());
    await tester.pumpWidget(GetMaterialApp(
      home: const NotesWidget(),
      getPages: [GetPage(name: '/note', page: () => const Text('note reached'))],
    ));
    await tester.pumpAndSettle();
    expect(find.byType(ListView), findsOneWidget);

    await tester.tap(find.text('Who am I?'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('I am not my body, am I?'));
    await tester.pumpAndSettle();
    expect(Get.currentRoute, '/note');
    expect(Get.arguments['mdFilename'], 'Back-to-Basics.md');
  });
}
