import 'package:askys/search_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart' hide Response;
import 'package:http_mock_adapter/http_mock_adapter.dart';

void main() {
  late Dio dio;
  late DioAdapter dioAdapter;
  late SearchWidget searchWidget;

  const apiToken = 'your-api-token';

  setUp(() {
    dio = Dio(BaseOptions(
      baseUrl: searchBaseUrl,
      headers: {'Authorization': 'Bearer $apiToken'},
    ));
    dioAdapter = DioAdapter(dio: dio);
    dio.httpClientAdapter = dioAdapter;
    searchWidget = SearchWidget();
  });

  group('SearchWidget', () {
    testWidgets('should initiate search', (WidgetTester tester) async {
      const searchString = 'test query';
      const mockResults = ['result1', 'result2', 'result3'];
      dioAdapter.onGet(
        '',
        (server) => server.reply(
          200,
          mockResults,
          // delay: const Duration(milliseconds: 100),
          headers: {
            'content-type': ['application/json']
          },
        ),
        queryParameters: {'query': searchString},
        headers: {'Authorization': 'Bearer $apiToken'},
      );
      await tester.pumpWidget(GetMaterialApp(home: searchWidget));
      await tester.enterText(find.byType(TextField), searchString);
      await tester.pump();
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      for (final result in mockResults) {
        expect(find.text(result), findsOneWidget);
      }
    });

    testWidgets('should display search results from API response', (WidgetTester tester) async {
      const searchString = 'test query';
      const mockResults = ['Result 1', 'Result 2', 'Result 3'];
      dioAdapter.onGet(
        '',
        (server) => server.reply(
          200,
          mockResults,
          delay: const Duration(milliseconds: 100),
        ),
        queryParameters: {'query': searchString},
      );
      await tester.pumpWidget(GetMaterialApp(home: searchWidget));
      await tester.enterText(find.byType(TextField), searchString);
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      for (final result in mockResults) {
        expect(find.text(result), findsOneWidget);
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
      await tester.pumpWidget(GetMaterialApp(home: searchWidget));
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
      await tester.pumpWidget(GetMaterialApp(home: searchWidget));
      await tester.enterText(find.byType(TextField), searchString);
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      expect(find.text('Connection timeout. Please try again.'), findsOneWidget);
    });

    testWidgets('should show loading indicator during API call', (WidgetTester tester) async {
      const searchString = 'test query';
      const mockResults = ['Result 1', 'Result 2', 'Result 3'];
      dioAdapter.onGet(
        '',
        (server) => server.reply(
          200,
          mockResults,
          delay: const Duration(milliseconds: 500), // Add delay to test loading state
        ),
        queryParameters: {'query': searchString},
      );
      await tester.pumpWidget(GetMaterialApp(home: searchWidget));
      await tester.enterText(find.byType(TextField), searchString);
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.pumpAndSettle();
      expect(find.byType(CircularProgressIndicator), findsNothing);
      for (final result in mockResults) {
        expect(find.text(result), findsOneWidget);
      }
    });
  });
}
