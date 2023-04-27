import 'dart:math';

import 'package:get/get.dart';

import 'content_source.dart';

Future<List<String>> allShlokaMDs() async {
  final GitHubFetcher contentSource = Get.find();
  final mdToNotes = await contentSource.mdToNoteIds();
  final mdFilenames = mdToNotes.map((e) => e.keys.first);
  return mdFilenames.where((filename) => filename.startsWith(RegExp(r'[0-9]'))).toList();
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
  List<String> threeShlokas = [];
  final feedPicked = false.obs;
  @override
  void onInit() async {
    threeShlokas = createRandomFeed(await allShlokaMDs());
    feedPicked.value = true;
    super.onInit();
  }
}
