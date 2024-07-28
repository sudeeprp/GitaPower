import 'dart:math';
import 'package:askys/content_source.dart';
import 'package:get/get.dart';
import 'shloka_headers.dart' as shlokas;

List<String> allShlokaMDs() {
  return shlokas.headers.keys.where((filename) => filename.startsWith(RegExp(r'[0-9]'))).toList();
}

class ShlokaRef {
  ShlokaRef(this.chapterNumber, this.shlokaNumber);
  final int chapterNumber;
  final int shlokaNumber;
}

ShlokaRef mdFilenameToShlokaNumber(String mdFilename) {
  final shlokaRefPart = mdFilename.split('.')[0].split('_')[0];
  final shlokaRefIntstrs = shlokaRefPart.split('-');
  return ShlokaRef(int.parse(shlokaRefIntstrs[0]), int.parse(shlokaRefIntstrs[1]));
}

List<String> createRandomFeed(List<String> shlokaMDs) {
  List<String> randomFeed = [];
  final rnd = Random();
  for (var i = 0; i < 3; i++) {
    final rndIndex = rnd.nextInt(shlokaMDs.length);
    randomFeed.add(shlokaMDs.removeAt(rndIndex));
  }
  randomFeed.sort((a, b) {
    final aRef = mdFilenameToShlokaNumber(a);
    final bRef = mdFilenameToShlokaNumber(b);
    return (aRef.chapterNumber * 1000 + aRef.shlokaNumber) -
        (bRef.chapterNumber * 1000 + bRef.shlokaNumber);
  });
  return randomFeed;
}

class FeedContent extends GetxController {
  final threeShlokas = <String>[].obs;
  final openerQs = ['', '', ''];
  final openerCovers = [false.obs, false.obs, false.obs];
  FeedContent.random() {
    threeShlokas.value = createRandomFeed(allShlokaMDs());
  }
  @override
  void onInit() async {
    await initFeedContent();
    super.onInit();
  }

  Future<void> initFeedContent() async {
    final GitHubFetcher fetcher = Get.find();
    final mdToOpeners = await fetcher.openerQuestions();
    for (int i = 0; i < threeShlokas.length; i++) {
      openerQs[i] = mdToOpeners[threeShlokas[i]] ?? '';
      openerCovers[i].value = true;
    }
  }

  void toggleOpenerCovers() {
    var toState = false;
    if (openerCovers.any((coverVisible) => coverVisible.value == false)) {
      toState = true;
    }
    for (int i = 0; i < openerCovers.length; i++) {
      openerCovers[i].value = toState;
    }
  }

  void setCuratedShlokaMDs(List<String> list) async {
    threeShlokas.value = list;
    await initFeedContent();
  }
}

class Playable {
  Playable(this.title, this.url);
  final String title;
  final String url;
}

class PlayablesTOC extends GetxController {
  final playables = <Playable>[].obs;
  @override
  void onInit() async {
    // TODO: parse the playables TOC
    // final GitHubFetcher contentSource = Get.find();
    // final playablesTocMD = await contentSource.playablesTocMD();
    super.onInit();
  }
}
