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
              key: Key('overq/$count'),
              onDismissed: (direction) => hideOpener(),
              child: GestureDetector(
                  onTap: hideOpener,
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(15, 5, 0, 8),
                    decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.grey.shade700.withOpacity(0.8),
                            Colors.grey.shade500.withOpacity(0.95)
                          ],
                          begin: AlignmentDirectional.topStart,
                          end: AlignmentDirectional.bottomEnd,
                        ),
                        borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(10), bottomLeft: Radius.circular(10))),
                    constraints: const BoxConstraints.expand(),
                    child: Center(
                        child: Text(feedContent.openerQs[count - 1],
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                fontSize: 32, color: Colors.black, fontWeight: FontWeight.bold))),
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
