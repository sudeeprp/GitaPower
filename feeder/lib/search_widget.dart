import 'dart:math';
import 'package:askys/choice_selector.dart';
import 'package:askys/choices_row.dart';
import 'package:askys/feedcontent.dart';
import 'package:askys/screenify.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

const tokenUrl = 'https://askys-token-572467571658.asia-south1.run.app/token/';
const searchBaseUrl = 'https://askys-discover-572467571658.asia-south1.run.app/gita/';

class PhraseSearcher extends GetxController {
  var top3mdFileNoExt = <String>[].obs;
  final isLoading = false.obs;
  final progressMsg = ''.obs;
  final Dio dio;
  final random = Random();
  final phraseInput = TextEditingController();
  PhraseSearcher(this.dio);
  void reset() {
    top3mdFileNoExt.value = [];
    isLoading.value = false;
    progressMsg.value = '';
  }

  String _entry() {
    const digits = '0123456789';
    const allChars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';

    final length = 31 + random.nextInt(34); // 31 to 64
    final first = allChars[random.nextInt(allChars.length)];
    final second = digits[random.nextInt(digits.length)];
    final remainingLength = length - 2;
    final buffer = StringBuffer();
    for (var i = 0; i < remainingLength; i++) {
      buffer.write(allChars[random.nextInt(allChars.length)]);
    }
    return '$first$second${buffer.toString()}';
  }

  Future<String> _tokenForSearch() async {
    const tokenUrl = 'https://askys-token-572467571658.asia-south1.run.app/token/';
    final entryToken = _entry();
    final tokenResponse = await dio.get(
      tokenUrl,
      options: Options(headers: {'Authorization': 'Bearer $entryToken'}),
    );
    return tokenResponse.data['token'] as String;
  }

  Future<void> search(String phrase) async {
    isLoading.value = true;
    try {
      progressMsg.value = 'Accessing';
      final tokenForSearch = await _tokenForSearch();
      final header = <String, dynamic>{'Authorization': 'Bearer $tokenForSearch'};
      progressMsg.value = 'Searching';
      final searchResponse = await dio.get(
        searchBaseUrl,
        queryParameters: {'q': phrase},
        options: Options(headers: header),
      );
      progressMsg.value = '';
      final responseJson = searchResponse.data as Map<String, dynamic>;
      final matches = responseJson['matches'] as List<dynamic>;
      top3mdFileNoExt.value = matches.map((match) => match['filename_no_mdext'] as String).toList();
    } on DioException catch (e) {
      if (e.response != null) {
        final errData = e.response?.data as Map<String, dynamic>;
        progressMsg.value += ' error: ${errData.toString()} (${e.response?.statusCode.toString()})';
      } else {
        progressMsg.value += ' error: ${e.message ?? e.error.toString()}';
      }
    }
    isLoading.value = false;
  }
}

class SearchWidget extends StatelessWidget {
  const SearchWidget({super.key});

  @override
  Widget build(BuildContext context) {
    PhraseSearcher phraseSearcher = Get.find();
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: const InputDecoration(
                    hintText: 'Search',
                    border: OutlineInputBorder(),
                  ),
                  controller: phraseSearcher.phraseInput,
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: () {
                  phraseSearcher.search(phraseSearcher.phraseInput.text);
                },
                child: const Icon(Icons.search, size: 48),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Obx(() {
              if (phraseSearcher.top3mdFileNoExt.length == 3) {
                final mdsInFeed =
                    phraseSearcher.top3mdFileNoExt.map((shlokaFile) => '$shlokaFile.md').toList();
                final FeedContent feedContent = Get.find();
                feedContent.setCuratedShlokaMDs(mdsInFeed);
                WidgetsBinding.instance.addPostFrameCallback((_) => Get.toNamed('/feed'));
                return const SizedBox.shrink();
              } else if (phraseSearcher.isLoading.value) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [CircularProgressIndicator(), Text(phraseSearcher.progressMsg.value)],
                );
              } else {
                return Text(phraseSearcher.progressMsg.value);
              }
            }),
          ),
        ],
      ),
    );
  }
}

Widget searchPage() {
  final PhraseSearcher phraseSearcher = Get.find();
  phraseSearcher.reset();
  return screenify(SearchWidget(),
      appBar: AppBar(title: const Text('Search (beta)')),
      choicesRow: choicesRow([], const [PersonalizeIcon(), SizedBox(width: choiceSpacing)]));
}
