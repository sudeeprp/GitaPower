import 'package:askys/content_source.dart';
import 'package:askys/feedcontent.dart';
import 'package:askys/moving_subtitles.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'feed_test.mocks.dart';

void main() {
  setUp(() {
    final mockPlayer = MockAudioPlayer();
    final dio = Dio();
    final dioAdapter = DioAdapter(dio: dio);
    dioAdapter.onGet(
        '${GitHubFetcher.playablesUrl}/bring_the_best_in_you/playable.json',
        (server) => server.reply(
            200,
            '[{"line": "l1", "link": "1-1", "speech": "s1.mp3", "show": ["k11", "k12"]}, '
            '{"line": "l2", "speech": "s2.mp3"}, '
            '{"line": "l3", "speech": "s3.mp3", "link": "1-3"}]'));
    dio.httpClientAdapter = dioAdapter;
    Get.put(GitHubFetcher(dio));

    final feedContent = FeedContent.random(aPlayer: mockPlayer);
    feedContent.tour.tourStops.value = [
      TourStop('s1.mp3', 'l1', null, null),
      TourStop('s2.mp3', 'l2', '2-34.md', null),
      TourStop('s3.mp3', 'l3', 'Chapter_7.md/bhakti_a_defn', ['sho1', 'sho2']),
    ];
    feedContent.tour.playable = 'bring_the_best_in_you';
    Get.put(feedContent);
  });
  testWidgets('shows the narrative as text', (tester) async {
    final FeedContent feedContent = Get.find();
    feedContent.tour.state.value = TourState.playing;

    await tester.pumpWidget(const GetMaterialApp(home: Scaffold(body: MovingSubtitles())));
    await tester.pumpAndSettle();
    expect(find.text('l1', findRichText: true), findsOneWidget);
  });
  testWidgets('syncs the subtitle with the play position', (tester) async {
    final FeedContent feedContent = Get.find();
    feedContent.tour.updatePlayPosition(const Duration(seconds: 2));
    // TODO: Test the scroll position of the moving subtitle
  });
}
