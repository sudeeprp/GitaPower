import 'dart:math';
import 'package:askys/choice_selector.dart';
import 'package:askys/choices_row.dart';
import 'package:askys/content_widget.dart';
import 'package:askys/matter_forinline.dart';
import 'package:askys/prompt_widget.dart';
import 'package:askys/screenify.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:askys/feedcontent.dart';

const searchBaseUrl = 'https://askys-discover-572467571658.asia-south1.run.app/gita/';

class SearchedPara {
  String mdFileNoExt;
  String content;
  SearchedPara({this.mdFileNoExt = '', this.content = ''});
}

class PhraseSearcher extends GetxController {
  final results = <SearchedPara>[].obs;
  final isLoading = false.obs;
  final progressMsg = ''.obs;
  final Dio dio;
  final random = Random();
  final phraseInput = TextEditingController();
  PhraseSearcher(this.dio);

  Future<void> research(String phrase) async {
    reset();
    await search(phrase);
  }

  void reset() {
    results.value = [];
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

  Future<void> search(String phrase) async {
    isLoading.value = true;
    try {
      progressMsg.value = 'Searching';
      final tokenForSearch = _entry();
      final header = <String, dynamic>{'Authorization': 'Bearer $tokenForSearch'};
      final searchResponse = await dio.get(
        searchBaseUrl,
        queryParameters: {'q': phrase},
        options: Options(headers: header),
      );
      progressMsg.value = '';
      final responseJson = searchResponse.data as Map<String, dynamic>;
      final matches = responseJson['matches'] as List<dynamic>;
      results.value = matches
          .map((match) => SearchedPara(
                mdFileNoExt: match['filename_no_mdext'] as String,
                content: match['match_text'] as String,
              ))
          .toList();
      final FeedContent feedContent = Get.find();
      feedContent.setCuratedShlokaMDs(results.map((e) => '${e.mdFileNoExt}.md').toList());
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

  String? textSearchedInFile(String mdFilename) {
    final matchingResult = results.firstWhereOrNull((result) => '${result.mdFileNoExt}.md' == mdFilename);
    return matchingResult?.content;
  }
}

class SearchWidget extends StatelessWidget {
  const SearchWidget({super.key});

  @override
  Widget build(BuildContext context) {
    PhraseSearcher phraseSearcher = Get.find();
    void unfocusAndSubmit(String phrase) {
      FocusScope.of(context).unfocus();
      phraseSearcher.research(phrase);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  autofocus: true,
                  textInputAction: TextInputAction.search,
                  decoration: const InputDecoration(
                    hintText: 'Search',
                    border: OutlineInputBorder(),
                  ),
                  controller: phraseSearcher.phraseInput,
                  onSubmitted: unfocusAndSubmit,
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: () => unfocusAndSubmit(phraseSearcher.phraseInput.text),
                child: const Icon(Icons.search, size: 32),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Obx(() {
              if (phraseSearcher.results.isNotEmpty) {
                return SearchResultsWidget(phraseSearcher.phraseInput.text, phraseSearcher.results);
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

class SearchResultsWidget extends StatelessWidget {
  final RxList<SearchedPara> results;
  final String searchString;
  const SearchResultsWidget(this.searchString, this.results, {super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final result = results[index];
        final foundFilename = '${result.mdFileNoExt}.md';
        return Card(
          child: ListTile(
            title: Text(result.mdFileNoExt),
            subtitle: buildContentFeed(foundFilename,
                foundText: result.content, isSectionVisible: isFoundInSearch), // Text(result.content),
            onTap: () => Get.toNamed('/shloka/$foundFilename'),
          ),
        );
      },
    );
  }

  bool isFoundInSearch(SectionType sectionType) {
    return sectionType == SectionType.shlokaSA ||
        sectionType == SectionType.shlokaSAHK ||
        sectionType == SectionType.meaning;
  }
}

class SearchPrompter extends StatelessWidget {
  const SearchPrompter({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final PhraseSearcher phraseSearcher = Get.find();
      if (phraseSearcher.results.length >= 3) {
        return PromptWidget();
      } else if (phraseSearcher.results.isNotEmpty) {
        return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Text('${phraseSearcher.results.length} found'));
      } else {
        return SizedBox(width: 0, height: 0);
      }
    });
  }
}

Widget searchScreen() {
  final PhraseSearcher phraseSearcher = Get.find();
  phraseSearcher.reset();
  return screenify(
    SearchWidget(),
    appBar: AppBar(
      title: const Text('Search'),
      actions: [SearchPrompter()],
    ),
    choicesRow: choicesRow([SizedBox(width: choiceSpacing), widgetToHome()],
        const [PersonalizeIcon(), SizedBox(width: choiceSpacing)]),
  );
}
