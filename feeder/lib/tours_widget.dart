import 'package:askys/feedcontent.dart';
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
                .map((playable) => ListTile(title: Text(playable.title)))
                .toList())));
  }
}
