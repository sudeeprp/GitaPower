import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:get/get.dart';

class GitHubFetcher extends GetxController {
  final Dio dio;
  GitHubFetcher(this.dio);

  static const mdPath = 'https://raw.githubusercontent.com/RaPaLearning/gita-begin/main/gita';
  Future<String> mdString(String mdFilename) async {
    final md = await dio.get('$mdPath/$mdFilename');
    return md.data.toString();
  }

  Future<List<Map<String, List<String>>>> mdToNoteIds() async {
    final mdToNotesStr = await _compiledAsString('md_to_note_ids_compiled.json');
    final List<dynamic> chapterNotesJson = jsonDecode(mdToNotesStr);
    final chapterNotes = chapterNotesJson
        .map(((e) => (e as Map<String, dynamic>).map((key, value) =>
            MapEntry(key, (value as List<dynamic>).map((e) => e as String).toList()))))
        .toList();
    return chapterNotes;
  }

  Future<List<Map<String, String>>> notesCompiled() async {
    final notesCompiledAsStr = await _compiledAsString('notes_compiled.json');
    final List<dynamic> notesCompiledAsJson = jsonDecode(notesCompiledAsStr);
    final notes = notesCompiledAsJson
        .map(((e) =>
            (e as Map<String, dynamic>).map((key, value) => MapEntry(key, value as String))))
        .toList();
    return notes;
  }

  static const compiledPath =
      'https://raw.githubusercontent.com/RaPaLearning/gita-begin/main/compile';
  Future<String> _compiledAsString(String jsonFilename) async {
    final jsonContent = await dio.get('$compiledPath/$jsonFilename');
    return jsonContent.data.toString();
  }
}
