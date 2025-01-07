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

  setUp(() {
    dio = Dio();
    dioAdapter = DioAdapter(dio: dio);
    dio.httpClientAdapter = dioAdapter;
    Get.put(PhraseSearcher(dio));
  });

  group('Search', () {
    testWidgets('should initiate search and display results', (WidgetTester tester) async {
      dioAdapter.onGet(tokenUrl, (server) => server.reply(200, {'token': 'token-for-search'}));
      const searchString = 'flame which does not shake';
      dioAdapter.onGet(
        searchBaseUrl,
        (server) => server.reply(
          200,
          mockResults,
          // delay: const Duration(milliseconds: 100),
          headers: {
            'content-type': ['application/json']
          },
        ),
        // queryParameters: {'query': searchString},
        // headers: {'Authorization': 'Bearer $apiToken'},
      );
      await tester.pumpWidget(GetMaterialApp(home: Scaffold(body: SearchWidget())));
      await tester.enterText(find.byType(TextField), searchString);
      await tester.pump();
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();
      for (final mdfileNoExt in ['6-19', '2-20', '14-23']) {
        expect(find.text(mdfileNoExt), findsOneWidget);
      }
    });

    testWidgets('should handle API error gracefully', (WidgetTester tester) async {
      const searchString = 'test query';
      dioAdapter.onGet(
        '',
        (server) => server.throws(
          500,
          DioException(
            requestOptions: RequestOptions(path: ''),
            response: Response(
              statusCode: 500,
              requestOptions: RequestOptions(path: ''),
            ),
            type: DioExceptionType.badResponse,
          ),
        ),
        queryParameters: {'query': searchString},
      );
      await tester.pumpWidget(GetMaterialApp(home: Scaffold(body: SearchWidget())));
      await tester.enterText(find.byType(TextField), searchString);
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      expect(find.text('An error occurred while searching'), findsOneWidget);
    });

    testWidgets('should handle network timeout', (WidgetTester tester) async {
      const searchString = 'test query';
      dioAdapter.onGet(
        '',
        (server) => server.throws(
          408,
          DioException(
            requestOptions: RequestOptions(path: ''),
            type: DioExceptionType.connectionTimeout,
          ),
          delay: const Duration(seconds: 2),
        ),
        queryParameters: {'query': searchString},
      );
      await tester.pumpWidget(GetMaterialApp(home: Scaffold(body: SearchWidget())));
      await tester.enterText(find.byType(TextField), searchString);
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      expect(find.text('Connection timeout. Please try again.'), findsOneWidget);
    });

    testWidgets('should show loading indicator during API call', (WidgetTester tester) async {
      const searchString = 'test query';
      dioAdapter.onGet(
        '',
        (server) => server.reply(
          200,
          mockResults,
          delay: const Duration(milliseconds: 300), // Add delay to test loading state
        ),
        queryParameters: {'query': searchString},
      );
      await tester.pumpWidget(GetMaterialApp(home: Scaffold(body: SearchWidget())));
      await tester.enterText(find.byType(TextField), searchString);
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.pumpAndSettle();
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text('14-23'), findsOneWidget);
    });
  });
}
