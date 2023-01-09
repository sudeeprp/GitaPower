import 'package:get/get.dart';
import 'dart:convert';

class Chapter {
  Chapter(this.title, this.shokas);
  factory Chapter.fromApplNotesJson(List<Map<String, dynamic>> chapterNotes) {
    return Chapter(
      chapterNotes[0].keys.first.replaceAll('.md', ''),
      chapterNotes.sublist(1, chapterNotes.length).map(((e) => e.keys.first.replaceAll('.md', ''))).toList(),
    );
  }
  String title;
  List<String> shokas;
}

List<Chapter> notesJsonStrToChapters(String notesJsonStr) {
  final List<dynamic> applNotesJson = jsonDecode(notesJsonStr);
  final applNotes = applNotesJson.map(((e) => e as Map<String, dynamic>)).toList();
  List<int> chapterIndexes = [];
  for (var i = 0; i < applNotes.length; i++) {
    if (!applNotes[i].keys.first.startsWith(RegExp(r'[0-9]'))) {
      chapterIndexes.add(i);
    }
  }
  List<Chapter> chapters = [];
  for (var i = 0; i < chapterIndexes.length - 1; i++) {
    chapters.add(Chapter.fromApplNotesJson(applNotes.sublist(chapterIndexes[i], chapterIndexes[i+1])));
  }
  chapters.add(Chapter.fromApplNotesJson(applNotes.sublist(chapterIndexes[chapterIndexes.length - 1])));
  return chapters;
}

class ChaptersTOC extends GetxController {

  final chapters = notesJsonStrToChapters('''[
{"Chapter 1.md": []},
{"1-20 to 1-23.md": ["applnote_15"]},
{"1-24 to 1-25.md": []},
{"1-26 to 1-47.md": ["applnote_16"]},
{"Chapter 2.md": []},
{"2-1.md": ["applopener_17"]},
{"2-2.md": ["applnote_18"]}
]''');
  @override
  void onInit() {
    super.onInit();
  }
}
