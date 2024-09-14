import 'package:askys/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:askys/content_source.dart';

void main() {
  setUp(() {
    final dio = Dio();
    final dioAdapter = DioAdapter(dio: dio);
    dio.httpClientAdapter = dioAdapter;
    dioAdapter.onGet(
        '${GitHubFetcher.compiledPath}/md_to_note_ids_compiled.json', (server) => server.reply(401, {}));
    dioAdapter.onGet('${GitHubFetcher.compiledPath}/notes_compiled.json', (server) => server.reply(401, {}));
    Get.put(GitHubFetcher(dio));
  });
  testWidgets('Shows content even on non-200 result from content-source', (tester) async {
    await tester.pumpWidget(makeMyHome());
    await tester.tap(find.byKey(const Key('begin/notes')));
    await tester.pumpAndSettle();
    expect(Get.currentRoute, '/notes');
  });
}
