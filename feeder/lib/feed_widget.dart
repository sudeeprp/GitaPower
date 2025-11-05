import 'package:askys/content_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
                    margin: const EdgeInsets.fromLTRB(15, 5, 0, 8),
                    decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.grey.shade700.withValues(alpha: 0.8),
                            Colors.grey.shade500.withValues(alpha: 0.95)
                          ],
                          begin: AlignmentDirectional.topStart,
                          end: AlignmentDirectional.bottomEnd,
                        ),
                        borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(10), bottomLeft: Radius.circular(10))),
                    constraints: const BoxConstraints.expand(),
                    child: Center(
                        child: Obx(() => Text(feedContent.openerQs[count - 1].value,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                fontSize: 32, color: Colors.black, fontWeight: FontWeight.bold)))),
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
                                color: Colors.grey.withValues(alpha: 0.5),
                                spreadRadius: 5,
                                blurRadius: 7,
                                offset: const Offset(0, -5))
                          ],
                          color: Theme.of(context).cardColor),
                      child: contentWithOpenerPane(filename, count++),
                    )) as Widget)
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

const templatePrompt =
    '''You are a friendly Sri Vaishnava who applies the Gitabhashya of Sri Ramanuja to everyday life.
I need you to thread through 3 shlokas given below.

Use concepts present in the Gitabhashya in your response:
- Experience of the Self is superior to any other outcome
- Krishna is the basis of the Self
- Whenever you experience something special, you experience a part of Krishna
- Devotion to Krishna is "worship with friendship"
- However, we are bound by the three qualities. Sattva gives contentment, Rajas makes us show-off, Tamas confuses us
- Surrender to Krishna is the only way out. Anyone can surrender.

Here are the 3 shlokas in markdown format:

>Starting shloka, opening question: {openerQ}

## {chaptershlokanum}

{shlokainsanskrit}

### Meaning

{meaning}

### Gitabhashya

{gitabhashya}

Write an article in markdown format, threading through the 3 shlokas above. Structure it as follows:
- Start with a catchy title
- Summarize your thread in a 30-second read
- Narrate your thread of thought in a 3-5 minute read. Mention references along the way (e.g., concepts from other shlokas of the Gita, which link your thoughts together) 
- Conclude with a call to action or a thought-provoking question

Use simple language, keep the tone devotional and practical. Make it engaging and inspiring.
''';

String makePrompt() {
  return templatePrompt;
}

class PromptWidget extends StatelessWidget {
  const PromptWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Clipboard.setData(ClipboardData(text: makePrompt())),
      child: const Icon(Icons.chat_bubble, size: 48, color: Colors.blue),
    );
  }
}
