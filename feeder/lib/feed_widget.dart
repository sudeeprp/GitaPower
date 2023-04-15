import 'dart:convert';
import 'package:askys/content_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'content_source.dart';

class FeedWidget extends StatelessWidget {
  const FeedWidget(this.mdFilenames, {super.key});
  final List<String> mdFilenames;
  @override
  Widget build(BuildContext context) {
    int count = 1;
    return Column(
        children: mdFilenames
            .map((filename) => Expanded(child: buildContent(filename, key: Key('feed/${count++}'))))
            .toList());
  }
}

FeedWidget buildFeed(List<String> mdFilenames) {
  return FeedWidget(mdFilenames);
}

Future<List<String>> allShlokaMDs() async {
  final GitHubFetcher contentSource = Get.find();
  final mdToNoteIdsStr = await contentSource.compiledAsString('md_to_note_ids_compiled.json');
  final List<dynamic> mdToNoteIdsJson = jsonDecode(mdToNoteIdsStr);
  final mdFilenames = mdToNoteIdsJson.map(((e) {
    final mdToNote = e as Map<String, dynamic>;
    return mdToNote.keys.first;
  }));
  return mdFilenames.where((filename)=> filename.startsWith(RegExp(r'[0-9]'))).toList();
}

List<String> threeShlokas() {
  return [];
}
