import 'package:askys/content_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'feedcontent.dart';

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
                .map((filename) =>
                    Expanded(child: buildContent(filename, key: Key('feed/${count++}'))))
                .toList());
      } else {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [CircularProgressIndicator()],
        );
      }
    });
  }
}

FeedWidget buildFeed() {
  return const FeedWidget();
}
