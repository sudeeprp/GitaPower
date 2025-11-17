import 'package:askys/content_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'feedcontent.dart';

Widget contentWithOpenerPane(String filename, int count) {
  final FeedContent feedContent = Get.find();
  void hideOpener() {
    feedContent.openerCovers[count - 1].value = false;
  }

  return Obx(() {
    if (feedContent.openerCovers[count - 1].value) {
      return Stack(
        children: [
          buildContentFeed(filename, key: Key('feed/$count')),
          Dismissible(
              key: Key('opener/$count'),
              onDismissed: (direction) => hideOpener(),
              child: GestureDetector(
                  onTap: hideOpener,
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.blue.shade50.withValues(alpha: 0.95),
                            Colors.purple.shade50.withValues(alpha: 0.95)
                          ],
                          begin: AlignmentDirectional.topStart,
                          end: AlignmentDirectional.bottomEnd,
                        ),
                        borderRadius: BorderRadius.circular(16)),
                    constraints: const BoxConstraints.expand(),
                    child: Center(
                        child: Obx(() => Text(feedContent.openerQs[count - 1].value,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 22,
                                color: Colors.indigo.shade900,
                                fontWeight: FontWeight.w500,
                                height: 1.4)))),
                  ))),
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
    final FeedContent feedContent = Get.find();
    return Obx(() {
      if (feedContent.threeShlokas.length == 3) {
        int count = 1;
        return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            children: feedContent.threeShlokas
                .map((filename) => Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black.withValues(alpha: 0.08),
                                spreadRadius: 0,
                                blurRadius: 12,
                                offset: const Offset(0, 4))
                          ],
                          color: Theme.of(context).cardColor),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: contentWithOpenerPane(filename, count++),
                      ),
                    ))
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
