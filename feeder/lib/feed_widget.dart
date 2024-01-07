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
        return Column(
            children: feedContent.threeShlokaMDs
                .map((filename) => Expanded(
                        child: Container(
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
                    )))
                .toList());
      } else {
        return const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [CircularProgressIndicator()],
        );
      }
    });
  }
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
