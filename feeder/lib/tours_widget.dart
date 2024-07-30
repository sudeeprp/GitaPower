import 'package:askys/feedcontent.dart';
import 'package:askys/home.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ToursWidget extends StatelessWidget {
  const ToursWidget({super.key});

  @override
  Widget build(BuildContext context) {
    PlayablesTOC playablesTOC = Get.find();
    return Obx(() => Scaffold(
        body: ListView(
            children: playablesTOC.playables
                .map((playable) => ListTile(
                      leading: const Icon(Icons.play_arrow, size: 48),
                      title: Text(playable.title),
                      onTap: () => navigateApplink(Uri.parse(playable.url)),
                    ))
                .toList())));
  }
}
