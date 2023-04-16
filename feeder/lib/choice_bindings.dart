import 'package:askys/notecontent.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:askys/choice_selector.dart';
import 'package:askys/chaptercontent.dart';
import 'content_source.dart';
import 'feedcontent.dart';

class ChoiceBinding implements Bindings {
  @override
  void dependencies() {
    Get.put(GitHubFetcher(Dio()));
    Get.put(Choices());
    Get.put(ChaptersTOC());
    Get.put(NotesTOC());
    Get.put(FeedContent());
  }
}
