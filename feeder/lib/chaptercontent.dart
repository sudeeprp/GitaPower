import 'package:get/get.dart';
import 'dart:convert';
import 'package:dio/dio.dart';

class Chapter {
  Chapter(this.title, this.shokas);
  factory Chapter.fromApplNotesJson(List<Map<String, dynamic>> chapterNotes) {
    return Chapter(
      chapterNotes[0].keys.first.replaceAll('.md', ''),
      chapterNotes
          .sublist(1, chapterNotes.length)
          .map(((e) => e.keys.first.replaceAll('.md', '')))
          .toList(),
    );
  }
  String title;
  List<String> shokas;
}

List<Chapter> notesJsonStrToChapters(String notesJsonStr) {
  final List<dynamic> applNotesJson = jsonDecode(notesJsonStr);
  final applNotes =
      applNotesJson.map(((e) => e as Map<String, dynamic>)).toList();
  List<int> chapterIndexes = [];
  for (var i = 0; i < applNotes.length; i++) {
    if (!applNotes[i].keys.first.startsWith(RegExp(r'[0-9]'))) {
      chapterIndexes.add(i);
    }
  }
  List<Chapter> chapters = [];
  for (var i = 0; i < chapterIndexes.length - 1; i++) {
    chapters.add(Chapter.fromApplNotesJson(
        applNotes.sublist(chapterIndexes[i], chapterIndexes[i + 1])));
  }
  chapters.add(Chapter.fromApplNotesJson(
      applNotes.sublist(chapterIndexes[chapterIndexes.length - 1])));
  return chapters;
}

class ChaptersTOC extends GetxController {
  List<Chapter> chapters = [];
  final chaptersLoaded = false.obs;
  @override
  void onInit() async {
    final mdnoteids = await Dio().get(
        'https://raw.githubusercontent.com/RaPaLearning/gita-begin/main/compile/md_to_note_ids_compiled.json');
    chapters.addAll(notesJsonStrToChapters(mdnoteids.data.toString()));
    chaptersLoaded.value = true;
    super.onInit();
  }
}
