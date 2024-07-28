import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

import 'package:dio/dio.dart';
import 'package:get/get.dart';

class GitHubFetcher extends GetxController {
  final Dio dio;
  GitHubFetcher(this.dio);
  static const baseUrl = 'https://raw.githubusercontent.com/RaPaLearning/gita-begin/main';
  static const playablesUrl = 'https://raw.githubusercontent.com/RaPaLearning/askys/main/playables';
  static const compileFolder = 'compile';
  static const mdFolder = 'gita';
  static const compiledPath = '$baseUrl/$compileFolder';
  static const mdPath = '$baseUrl/$mdFolder';
  Future<String> mdString(String mdFilename) async {
    return await _getRawContent(mdFolder, mdFilename);
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

  Future<Map<String, String>> openerQuestions() async {
    final openerQuestionsAsStr = await _compiledAsString('md_opener_questions.json');
    final Map<String, dynamic> mdToQuestionsJson = jsonDecode(openerQuestionsAsStr);
    final mdToQuestions = Map<String, String>.from(mdToQuestionsJson);
    return mdToQuestions;
  }

  Future<String> _compiledAsString(String jsonFilename) async {
    return await _getRawContent(compileFolder, jsonFilename);
  }

  Future<String> _getRawContent(String foldername, String filename) async {
    try {
      final content = await dio.get('$baseUrl/$foldername/$filename');
      return content.data.toString();
    } on DioException {
      return await rootBundle.loadString('gita-begin/$foldername/$filename');
    }
  }

  Future<String> playablesTocMD() async {
    // TODO: retrieve content from github
    return '''
# Playable feeds

[Bring the best in you](https://rapalearning.com/gitapower/feed/8-25.14-1.18-1.bring_the_best_in_you)
''';
  }
}
