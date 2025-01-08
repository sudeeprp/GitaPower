import 'package:askys/content_source.dart';
import 'package:askys/feedcontent.dart';
import 'package:askys/search_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart' hide Response;
import 'package:http_mock_adapter/http_mock_adapter.dart';

void main() {
  late Dio dio;
  late DioAdapter dioAdapter;
  const mockResults = {
    'matches': [
      {
        'commentary_chunks': 'commentary1',
        'filename_no_mdext': '6-19',
        'match_id': '6-19-0',
        'match_score': 0.8120879
      },
      {
        'commentary_chunks': 'commentary2',
        'filename_no_mdext': '2-20',
        'match_id': '2-20-1',
        'match_score': 0.7891093
      },
      {
        'commentary_chunks': 'commentary3',
        'filename_no_mdext': '14-23',
        'match_id': '14-23-0',
        'match_score': 0.78039294
      }
    ],
    'to_search': 'flame which does not shake',
    'version': 'v0.3'
  };

  void resetPhraseSearcher() {
    final PhraseSearcher phraseSearcher = Get.find();
    phraseSearcher.reset();
  }

  void setupAskysDiscoverMock(String phrase, {Duration? delay}) {
    dioAdapter.onGet(tokenUrl, (server) => server.reply(200, {'token': 'token-for-search'}));
    dioAdapter.onGet(
      searchBaseUrl,
      (server) => server.reply(200, mockResults, delay: delay, headers: {
        'content-type': ['application/json']
      }),
      queryParameters: {'q': phrase},
    );
  }

  group('Search', () {
    setUp(() {
      dio = Dio();
      dioAdapter = DioAdapter(dio: dio);
      dio.httpClientAdapter = dioAdapter;
      Get.put(GitHubFetcher(Dio()));
      Get.put(PhraseSearcher(dio));
    });
    tearDown(() {
      Get.delete<PhraseSearcher>();
      Get.delete<GitHubFetcher>();
    });
    testWidgets('should initiate search and display results', (tester) async {
      resetPhraseSearcher();
      const searchString = 'flame which does not shake';
      setupAskysDiscoverMock(searchString);
      Get.put(FeedContent.random());
      await tester.pumpWidget(GetMaterialApp(
        home: Scaffold(body: SearchWidget()),
        getPages: [GetPage(name: '/feed', page: () => const Text('feed'))],
      ));
      await tester.enterText(find.byType(TextField), searchString);
      await tester.pump();
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();
      FeedContent feedContent = Get.find();
      expect(feedContent.threeShlokas[0], equals('6-19.md'));
      expect(feedContent.threeShlokas[1], equals('2-20.md'));
      expect(feedContent.threeShlokas[2], equals('14-23.md'));
      await tester.pumpAndSettle();
      expect(Get.currentRoute, '/feed');
    });

    testWidgets('should handle API unreachable', (tester) async {
      Get.put(FeedContent.random());
      const searchString = 'test query';
      await tester.pumpWidget(GetMaterialApp(home: Scaffold(body: SearchWidget())));
      await tester.enterText(find.byType(TextField), searchString);
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();
      expect(find.textContaining('error'), findsOneWidget);
    });

    testWidgets('should handle error status response from API', (tester) async {
      dioAdapter.onGet(tokenUrl, (server) => server.reply(401, {'error': 'invalid token'}));
      const searchString = 'test query';
      await tester.pumpWidget(GetMaterialApp(home: Scaffold(body: SearchWidget())));
      await tester.enterText(find.byType(TextField), searchString);
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();
      expect(find.textContaining('error'), findsOneWidget);
    });
    testWidgets('should show loading indicator during API call', (tester) async {
      const searchString = 'test query';
      setupAskysDiscoverMock(searchString);
      await tester.pumpWidget(GetMaterialApp(
        home: Scaffold(body: SearchWidget()),
        getPages: [GetPage(name: '/feed', page: () => const Text('feed'))],
      ));
      await tester.enterText(find.byType(TextField), searchString);
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.pumpAndSettle();
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });
  });
}
