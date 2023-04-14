import 'package:askys/choice_selector.dart';
import 'package:askys/content_source.dart';
import 'package:askys/feed_widget.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';

void main() {
  setUp(() {
    Get.put(Choices());
    final dio = Dio();
    final dioAdapter = DioAdapter(dio: dio);
    dio.httpClientAdapter = dioAdapter;
    dioAdapter.onGet('${GitHubFetcher.mdPath}/2-4.md', (svr) => svr.reply(200, '`भजताम्`'));
    dioAdapter.onGet('${GitHubFetcher.mdPath}/10-10.md', (svr) => svr.reply(200, '`भजताम्`'));
    dioAdapter.onGet('${GitHubFetcher.mdPath}/18-4.md', (svr) => svr.reply(200, '`भजताम्`'));
    Get.put(GitHubFetcher(dio));
  });
  testWidgets('shows three sources', (tester) async {
    await tester.pumpWidget(
        GetMaterialApp(home: Scaffold(body: buildFeed(['2-4.md', '10-10.md', '18-4.md']))));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('feed/1')), findsOneWidget);
    expect(find.byKey(const Key('feed/2')), findsOneWidget);
    expect(find.byKey(const Key('feed/3')), findsOneWidget);
  });
}
