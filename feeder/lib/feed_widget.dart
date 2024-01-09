import 'package:askys/choice_selector.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'feedcontent.dart';
import 'feed_shloka.dart';

class FeedWidget extends StatelessWidget {
  const FeedWidget({super.key});
  @override
  Widget build(BuildContext context) {
    int count = 1;
    final FeedContent feedContent = Get.find();
    return Obx(() {
      if (feedContent.feedPicked.value) {
        final shlokaContainers = feedContent.threeShlokaMDs
                .map((filename) =>Container(
                      decoration: BoxDecoration(
                          border: const Border(bottom: BorderSide(color: Colors.black)),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                spreadRadius: 5,
                                blurRadius: 7,
                                offset: const Offset(0, -5))
                          ],
                          color: Theme.of(context).cardColor),
                      child: FeedShloka(filename, key: Key('feed/${count++}')),
                    )).toList();
        final parentWidth = MediaQuery.of(context).size.width;
        final parentHeight = MediaQuery.of(context).size.height;
        final padding = parentWidth * 0.07;
        return Stack(
            children: [
              Padding(padding: EdgeInsets.only(right: padding), child: shlokaContainers[0]),
              Padding(padding: EdgeInsets.only(left: padding, top: parentHeight * 0.3), child: shlokaContainers[1]),
              Padding(padding: EdgeInsets.only(right: padding, top: parentHeight * 0.6), child: shlokaContainers[2]),
            ],
        );
      } else {
        return const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [CircularProgressIndicator()],
        );
      }
    });
  }
}

Widget shlokaMeaningSwitcher() {
  return Row(
    mainAxisAlignment: MainAxisAlignment.end,
    children: [
      GestureDetector(
        child: const Icon(Icons.refresh),
      ),
      GestureDetector(
        onTap: () {
          final Choices choice = Get.find();
          if (choice.headPreference.value == HeadPreference.shloka) {
            choice.headPreference.value = HeadPreference.meaning;
          } else {
            choice.headPreference.value = HeadPreference.shloka;
          }
        },
        child: Image.asset('images/translate.png', width: 60, height: 60),
      ),
    ],
  );
}

Scaffold feedScreen() {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  return Scaffold(
      key: scaffoldKey,
      // appBar: AppBar(bottom: PreferredSize(preferredSize: const Size.fromHeight(80.0), child: shlokaMeaningSwitcher())),
      body: const SafeArea(child: FeedWidget()),
      bottomNavigationBar: shlokaMeaningSwitcher(),
  );
}
