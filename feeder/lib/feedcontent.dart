import 'dart:convert';
import 'dart:math';
import 'package:askys/content_source.dart';
import 'package:askys/tell_if_error.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
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

class TourStop {
  TourStop(this.speechFilename, this.link, this.show);
  final String speechFilename;
  final String? link;
  final List<String>? show;
}

enum TourState { idle, loading, playing, paused }

class Tour {
  int stopIndex = 0;
  var state = TourState.idle.obs;
  final tourStops = <TourStop>[].obs;
  dynamic lastException;
  void moveTo(int? index) {
    stopIndex = index ?? 0;
    final mdFilenameWithLink = tourStops[stopIndex].link;
    if (mdFilenameWithLink != null) {
      final mdLaunchPath = '/shloka/$mdFilenameWithLink';
      Get.toNamed(mdLaunchPath);
    }
  }

  void playState(PlayerState playerState) {
    state.value = switch (playerState.processingState) {
      ProcessingState.idle => TourState.idle,
      ProcessingState.loading => TourState.loading,
      ProcessingState.buffering => TourState.loading,
      ProcessingState.ready => playerState.playing ? TourState.playing : TourState.paused,
      ProcessingState.completed => TourState.idle,
    };
    if (state.value == TourState.playing) {
      WakelockPlus.enable();
    } else {
      WakelockPlus.disable();
    }
  }
}

class FeedContent extends GetxController {
  final threeShlokas = <String>[].obs;
  final openerQs = ['', '', ''];
  final openerCovers = [false.obs, false.obs, false.obs];
  String? tourFolder;
  final tour = Tour();
  final AudioPlayer audioPlayer;
  FeedContent.random({AudioPlayer? aPlayer}) : audioPlayer = aPlayer ?? AudioPlayer() {
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

  void setCuratedShlokaMDs(List<String> mdFilenames, {String? playableFolder}) async {
    threeShlokas.value = mdFilenames;
    final GitHubFetcher contentSource = Get.find();
    if (playableFolder != null) {
      tourFolder = playableFolder;
      final playableJsonAsStr = await contentSource.playableMD(playableFolder);
      if (playableJsonAsStr != null) {
        final List<dynamic> playableJson = jsonDecode(playableJsonAsStr);
        tour.tourStops.value = playableJson
            .map((e) => e as Map<String, dynamic>)
            .map((tourStopJson) => TourStop(
                  tourStopJson['speech'] as String,
                  tourStopJson['link'] as String?,
                  tourStopJson['show']?.cast<String>(),
                ))
            .toList();
      }
    }
    await initFeedContent();
  }

  void play() async {
    await tellIfError(() async {
      final uriList = tour.tourStops
          .map((tourStop) =>
              Uri.parse('${GitHubFetcher.playablesUrl}/$tourFolder/${tourStop.speechFilename}'))
          .toList();
      final playlist =
          ConcatenatingAudioSource(children: uriList.map((uri) => AudioSource.uri(uri)).toList());
      audioPlayer.currentIndexStream.listen(tour.moveTo);
      audioPlayer.playerStateStream.listen(tour.playState);
      await audioPlayer.setAudioSource(playlist, initialIndex: 0, initialPosition: Duration.zero);
      await audioPlayer.play();
    });
  }

  void pause() async {
    await audioPlayer.pause();
  }

  void resume() async {
    await audioPlayer.play();
  }
}

class Playable {
  Playable(this.title, this.url, this.tourFolder);
  final String title;
  final String url;
  final String tourFolder;
}

List<Playable> extractPlayablesFromTOC(List<String> lines) {
  final playables = <Playable>[];
  final regex = RegExp(r'\[(.+)\]\((.+)\)');
  const baseUrl = 'https://rapalearning.com';

  for (var line in lines) {
    final match = regex.firstMatch(line);
    if (match != null) {
      final title = match.group(1);
      var url = match.group(2);
      if (title != null && url != null) {
        if (url.startsWith(baseUrl)) {
          url = url.substring(baseUrl.length);
          final tourFolder = url.split('.').last;
          playables.add(Playable(title, url, tourFolder));
        }
      }
    }
  }
  return playables;
}

class PlayablesTOC extends GetxController {
  final playables = <Playable>[].obs;
  @override
  void onInit() async {
    final GitHubFetcher contentSource = Get.find();
    final playablesTocMD = await contentSource.playablesTocMD();
    if (playablesTocMD != null) {
      playables.value = extractPlayablesFromTOC(playablesTocMD.split('\n'));
    }
    super.onInit();
  }
}
