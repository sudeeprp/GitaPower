import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:askys/content_source.dart';
import 'package:askys/notes_widget.dart';

const compiledNotes = '''
[{"note_id": "applopener_1", "text": "Who am I?"}, {"note_id": "applnote_2", "text": "I am not my body, am I?"}, {"note_id": "applnote_3", "text": "I am not just a thought, am I?"}, {"note_id": "applopener_6", "text": "What am I doing?"}, {"note_id": "applnote_7", "text": "Our journey in life is a series of activities. Is it about \u2018doing\u2019 or \u2018making it happen\u2019?"}]
''';

void main() {
  Get.testMode = true;
  setUp(() {
    final dio = Dio();
    final dioAdapter = DioAdapter(dio: dio);
    dio.httpClientAdapter = dioAdapter;
    dioAdapter.onGet('${GitHubFetcher.compiledPath}/notes_compiled.json',
        (server) => server.reply(200, compiledNotes));
    Get.put(GitHubFetcher(dio));
  });
  testWidgets('navigates to a note from the openers toc', (WidgetTester tester) async {
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
    expect(Get.arguments, 'applnote_2');
  });
}
