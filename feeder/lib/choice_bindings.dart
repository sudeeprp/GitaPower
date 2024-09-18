import 'package:askys/mdcontent.dart';
import 'package:askys/notecontent.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:askys/choice_selector.dart';
import 'package:askys/chaptercontent.dart';
import 'content_source.dart';
import 'feedcontent.dart';
import 'content_actions.dart';

class ChoiceBinding implements Bindings {
  @override
  void dependencies() {
    const waitTimeout = Duration(seconds: 2);
    Get.put(GitHubFetcher(Dio(BaseOptions(connectTimeout: waitTimeout, receiveTimeout: waitTimeout))));
    Get.put(Choices());
    Get.put(ChaptersTOC());
    Get.put(NotesTOC());
    Get.put(ContentNotes());
    Get.put(FeedContent.random());
    Get.put(ContentActions());
    Get.put(ShowWords());
    Get.lazyPut(() => PlayablesTOC(), fenix: true);
  }
}
