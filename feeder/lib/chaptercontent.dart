import 'package:get/get.dart';
import 'content_source.dart';
import 'shloka_headers.dart' as shlokatoc;

class Chapter {
  Chapter(this.title, this.shokas);
  factory Chapter.fromChapterNotesJson(List<Map<String, dynamic>> chapterNotes) {
    final chapterTitle = filenameToTitle(chapterNotes[0].keys.first);
    final chapterShlokaTitles = chapterNotes
        .sublist(0, chapterNotes.length)
        .map(((e) => filenameToTitle(e.keys.first)))
        .toList();
    chapterShlokaTitles[0] = 'Introduction';
    return Chapter(chapterTitle, chapterShlokaTitles);
  }
  String shlokaTitleToFilename(String shlokaTitle) {
    if (shlokaTitle == 'Introduction') {
      return titleToFilename(title);
    } else {
      return titleToFilename(shlokaTitle);
    }
  }

  static String filenameToTitle(String filename) {
    return filename.replaceAll('.md', '').replaceAll('_', ' ');
  }

  static String filenameToShortTitle(String filename) {
    final title = filenameToTitle(filename);
    return title
        .replaceFirst('Chapter', 'Chap.')
        .replaceAll('first part', '1st')
        .replaceAll('second part', '2nd')
        .replaceAll('and', '&');
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
  final mdSequence = shlokatoc.headers.entries.map((e) => e.key).toList();

  @override
  void onInit() async {
    final GitHubFetcher contentSource = Get.find();
    chapters.addAll(mdNotesToChapters(await contentSource.mdToNoteIds()));
    chaptersLoaded.value = true;
    super.onInit();
  }

  String? nextmd(String mdFilename) {
    int index = mdSequence.indexOf(mdFilename);
    if (index != -1 && index < mdSequence.length - 1) {
      return mdSequence[index + 1];
    }
    return null;
  }

  String? prevmd(String mdFilename) {
    int index = mdSequence.indexOf(mdFilename);
    if (index != -1 && index > 0) {
      return mdSequence[index - 1];
    }
    return null;
  }
}
