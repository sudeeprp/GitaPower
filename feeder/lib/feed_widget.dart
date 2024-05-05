import 'package:askys/content_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'feedcontent.dart';

Widget contentWithOpenerPane(String filename, int count) {
  return Obx(() {
    final FeedContent feedContent = Get.find();
    if (feedContent.openerCovers[count - 1].value) {
      return Stack(
        children: [
          buildContentFeed(filename, key: Key('feed/$count')),
          Dismissible(
              key: Key('overq/$count'),
              onDismissed: (direction) {
                feedContent.openerCovers[count - 1].value = false;
              },
              child: Container(
                color: Colors.purple.withOpacity(0.8),
                constraints: const BoxConstraints.expand(),
                child: const Center(
                    child: Text("Make this glass",
                        textAlign: TextAlign.center, style: TextStyle(fontSize: 32))),
              )),
        ],
      );
    } else {
      return buildContentFeed(filename, key: Key('feed/$count'));
    }
  });
}

class FeedWidget extends StatelessWidget {
  const FeedWidget({super.key});
  @override
  Widget build(BuildContext context) {
    int count = 1;
    final FeedContent feedContent = Get.find();
    return Obx(() {
      if (feedContent.feedPicked.value) {
        return Column(
            children: feedContent.threeShlokas
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
                      child: contentWithOpenerPane(filename, count++),
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

FeedWidget buildFeed() {
  return const FeedWidget();
}
