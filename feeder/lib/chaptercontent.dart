import 'package:get/get.dart';
import 'content_source.dart';

class Chapter {
  Chapter(this.title, this.shokas);
  factory Chapter.fromChapterNotesJson(List<Map<String, dynamic>> chapterNotes) {
    return Chapter(
      filenameToTitle(chapterNotes[0].keys.first),
      chapterNotes
          .sublist(0, chapterNotes.length)
          .map(((e) => filenameToTitle(e.keys.first)))
          .toList(),
    );
  }
  static String filenameToTitle(String filename) {
    return filename.replaceAll('.md', '').replaceAll('_', ' ');
  }

  static String titleToFilename(String title) {
    return '${title.replaceAll(' ', '_')}.md';
  }

  String title;
  List<String> shokas;
}

List<Chapter> mdNotesToChapters(List<Map<String, List<String>>> mdToNotes) {
  List<int> chapterIndexes = [];
  for (var i = 0; i < mdToNotes.length; i++) {
    if (!mdToNotes[i].keys.first.startsWith(RegExp(r'[0-9]'))) {
      chapterIndexes.add(i);
    }
  }
  List<Chapter> chapters = [];
  for (var i = 0; i < chapterIndexes.length - 1; i++) {
    chapters.add(
        Chapter.fromChapterNotesJson(mdToNotes.sublist(chapterIndexes[i], chapterIndexes[i + 1])));
  }
  chapters.add(
      Chapter.fromChapterNotesJson(mdToNotes.sublist(chapterIndexes[chapterIndexes.length - 1])));
  return chapters;
}

class ChaptersTOC extends GetxController {
  List<Chapter> chapters = [];
  final chaptersLoaded = false.obs;
  @override
  void onInit() async {
    final GitHubFetcher contentSource = Get.find();
    chapters.addAll(mdNotesToChapters(await contentSource.mdToNoteIds()));
    chaptersLoaded.value = true;
    super.onInit();
  }
}
