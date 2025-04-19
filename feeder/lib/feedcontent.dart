import 'dart:convert';
import 'dart:math';
import 'package:askys/content_source.dart';
import 'package:askys/mdcontent.dart';
import 'package:askys/tell_if_error.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'shloka_headers.dart' as shlokas;
import 'package:keep_screen_on/keep_screen_on.dart';

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
  final shlokaRefIntStrings = shlokaRefPart.split('-');
  return ShlokaRef(int.parse(shlokaRefIntStrings[0]), int.parse(shlokaRefIntStrings[1]));
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
    return (aRef.chapterNumber * 1000 + aRef.shlokaNumber) - (bRef.chapterNumber * 1000 + bRef.shlokaNumber);
  });
  return randomFeed;
}

class TourStop {
  TourStop(this.speechFilename, this.line, this.link, this.show) : globalKey = GlobalKey();
  final String speechFilename;
  final String line;
  final String? link;
  final List<String>? show;
  final GlobalKey globalKey;
}

enum TourState { idle, loading, playing, paused }

void setupWordShow(String? mdFilenamePlaying, List<String>? show) {
  if (show != null) {
    final showWords = Get.find<ShowWords>();
    showWords.words.value = show;
    showWords.mdFilenamePlaying = mdFilenamePlaying;
  }
}

class Tour {
  RxInt stopIndex = 0.obs;
  var state = TourState.idle.obs;
  String? playable;
  final tourStops = <TourStop>[].obs;
  dynamic lastException;

  void moveTo(int? serialNumber) {
    final nonNullSerial = serialNumber ?? 0;
    stopIndex.value = (nonNullSerial - 1).clamp(0, tourStops.length - 1);
    final mdFilenameWithLink = tourStops[stopIndex.value].link;
    if (mdFilenameWithLink != null) {
      setupWordShow(mdFilenameWithLink, tourStops[stopIndex.value].show);
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
    if (!kIsWeb) {
      // keep_screen_on is not supported for the web
      if (state.value == TourState.playing) {
        KeepScreenOn.turnOn();
      } else {
        KeepScreenOn.turnOff();
      }
    }
  }
}

class FeedContent extends GetxController {
  final threeShlokas = <String>[].obs;
  final openerQs = [''.obs, ''.obs, ''.obs];
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
      openerQs[i].value = mdToOpeners[threeShlokas[i]] ?? '';
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
        tour.playable = tourFolder;
        tour.tourStops.value = playableJson
            .map((e) => e as Map<String, dynamic>)
            .map((tourStopJson) => TourStop(
                  tourStopJson['speech'] as String,
                  tourStopJson['line'] as String,
                  tourStopJson['link'] as String?,
                  tourStopJson['show']?.cast<String>(),
                ))
            .toList();
      }
    }
    await initFeedContent();
  }

  void resetToRandom() async {
    threeShlokas.value = createRandomFeed(allShlokaMDs());
    tourFolder = null;
    tour.stopIndex.value = 0;
    tour.state.value = TourState.idle;
    tour.playable = null;
    tour.tourStops.value = [];
    await initFeedContent();
  }

  void play() async {
    await callAndTellIfError(() async {
      final uriList = tour.tourStops
          .map(
              (tourStop) => Uri.parse('${GitHubFetcher.playablesUrl}/$tourFolder/${tourStop.speechFilename}'))
          .toList();
      audioPlayer.currentIndexStream.listen(tour.moveTo);
      audioPlayer.playerStateStream.listen(tour.playState);
      await audioPlayer.setAudioSources(
        [AudioSource.asset('audio/background.m4a')] + uriList.map((uri) => AudioSource.uri(uri)).toList(),
        preload: true,
        initialIndex: 0,
        initialPosition: Duration.zero,
      );
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
