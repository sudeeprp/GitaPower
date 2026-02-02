import 'package:askys/chaptercontent.dart';
import 'package:askys/choice_selector.dart';
import 'package:askys/content_actions.dart';
import 'package:askys/content_source.dart';
import 'package:askys/feedcontent.dart';
import 'package:askys/mdcontent.dart';
import 'package:askys/notecontent.dart';
import 'package:askys/prompt_widget.dart';
import 'package:askys/search_screen.dart';
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
        'match_text': 'commentary1',
        'filename_no_mdext': '6-19',
        'match_id': '6-19-0',
        'match_score': 0.8120879
      },
      {
        'match_text': 'commentary2',
        'filename_no_mdext': '2-20',
        'match_id': '2-20-1',
        'match_score': 0.7891093
      },
      {
        'match_text': 'commentary3',
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
    testWidgets('should initiate search and display the top results', (tester) async {
      resetPhraseSearcher();
      Get.put(ChaptersTOC());
      Get.put(ContentActions());
      Get.put(Choices());
      Get.put(ShowWords());
      Get.put(ContentNotes());
      Get.put(FeedContent.random());
      const searchString = 'flame which does not shake';
      setupAskysDiscoverMock(searchString);
      await tester.pumpWidget(GetMaterialApp(
        home: Scaffold(body: SearchWidget()),
        getPages: [
          GetPage(name: '/shloka/6-19.md', page: () => const Text('opened')),
        ],
      ));
      await tester.enterText(find.byType(TextField), searchString);
      await tester.pump();
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();
      final mockedTopMatches = ['6-19', '2-20', '14-23'];
      for (var filename in mockedTopMatches) {
        expect(find.textContaining(filename), findsOneWidget);
      }
      // Tap on first result to navigate
      await tester.tap(find.textContaining('6-19'));
      await tester.pumpAndSettle();
      expect(Get.currentRoute, '/shloka/6-19.md');
    });

    testWidgets('should handle API unreachable', (tester) async {
      const searchString = 'test query';
      await tester.pumpWidget(GetMaterialApp(home: Scaffold(body: SearchWidget())));
      await tester.enterText(find.byType(TextField), searchString);
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();
      expect(find.textContaining('error'), findsOneWidget);
    });

    testWidgets('should handle error status response from API', (tester) async {
      dioAdapter.onGet(searchBaseUrl, (server) => server.reply(401, {'error': 'invalid token'}));
      const searchString = 'test query';
      await tester.pumpWidget(GetMaterialApp(home: Scaffold(body: SearchWidget())));
      await tester.enterText(find.byType(TextField), searchString);
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();
      expect(find.textContaining('error'), findsOneWidget);
    });
    testWidgets('should show loading indicator during API call', (tester) async {
      const searchString = 'test query';
      Get.put(FeedContent.random());
      setupAskysDiscoverMock(searchString);
      await tester.pumpWidget(GetMaterialApp(home: Scaffold(body: SearchWidget())));
      await tester.enterText(find.byType(TextField), searchString);
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.pumpAndSettle();
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });
    test('should return matching content when file exists in results', () {
      final PhraseSearcher phraseSearcher = Get.find();
      phraseSearcher.results.addAll([
        SearchedPara(mdFileNoExt: '6-19', content: 'commentary1'),
        SearchedPara(mdFileNoExt: '2-20', content: 'commentary2'),
        SearchedPara(mdFileNoExt: '14-23', content: 'commentary3'),
      ]);
      final foundText = phraseSearcher.textSearchedInFile('6-19.md');
      expect(foundText, 'commentary1');
    });
    test('should return null when file does not exist in results', () {
      final PhraseSearcher phraseSearcher = Get.find();
      phraseSearcher.results.addAll([
        SearchedPara(mdFileNoExt: '6-19', content: 'commentary1'),
        SearchedPara(mdFileNoExt: '2-20', content: 'commentary2'),
      ]);
      final foundText = phraseSearcher.textSearchedInFile('3-15.md');
      expect(foundText, isNull);
    });
    test('should return null when results list is empty', () {
      final PhraseSearcher phraseSearcher = Get.find();
      final foundText = phraseSearcher.textSearchedInFile('6-19.md');
      expect(foundText, isNull);
    });
  });
  group('SearchPrompter', () {
    setUp(() {
      Get.put(PhraseSearcher(dio));
    });
    tearDown(() {
      Get.delete<PhraseSearcher>();
    });

    testWidgets('should not show prompt button when no search results', (tester) async {
      resetPhraseSearcher();
      await tester.pumpWidget(GetMaterialApp(
        home: Scaffold(body: SearchPrompter()),
      ));
      expect(find.byType(PromptWidget), findsNothing);
    });
    testWidgets('should show prompt button when 3 search results are present', (tester) async {
      resetPhraseSearcher();
      final PhraseSearcher phraseSearcher = Get.find();
      phraseSearcher.results.addAll([
        SearchedPara(mdFileNoExt: '1-1', content: 'test content 1'),
        SearchedPara(mdFileNoExt: '2-2', content: 'test content 2'),
        SearchedPara(mdFileNoExt: '3-3', content: 'test content 3'),
      ]);
      await tester.pumpWidget(GetMaterialApp(
        home: Scaffold(body: SearchPrompter()),
      ));
      expect(find.byType(PromptWidget), findsOneWidget);
    });
    testWidgets('should show search count when less than 3 results are present', (tester) async {
      resetPhraseSearcher();
      final PhraseSearcher phraseSearcher = Get.find();
      phraseSearcher.results.addAll([
        SearchedPara(mdFileNoExt: '1-1', content: 'test content 1'),
        SearchedPara(mdFileNoExt: '2-2', content: 'test content 2'),
      ]);
      await tester.pumpWidget(GetMaterialApp(
        home: Scaffold(body: SearchPrompter()),
      ));
      expect(find.text('2 found'), findsOneWidget);
    });
  });
}
