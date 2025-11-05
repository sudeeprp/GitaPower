import 'package:askys/content_widget.dart';
import 'package:askys/mdcontent.dart';
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

>Starting shloka, opening question: {{openerQ1}}

## {{chapterShlokaNum1}}

{{shlokaInSanskrit1}}

### Meaning

{{meaning1}}

### Gitabhashya

{{gitabhashya1}}

---

>Second shloka, opening question: {{openerQ2}}

## {{chapterShlokaNum2}}

{{shlokaInSanskrit2}}

### Meaning

{{meaning2}}

### Gitabhashya

{{gitabhashya2}}

---

>Third shloka, opening question: {{openerQ3}}

## {{chapterShlokaNum3}}

{{shlokaInSanskrit3}}

### Meaning

{{meaning3}}

### Gitabhashya

{{gitabhashya3}}

Write an article in markdown format, threading through the 3 shlokas above. Structure it as follows:
- Start with a catchy title
- Summarize your thread in a 30-second read
- Narrate your thread of thought in a 3-5 minute read. Mention references along the way (e.g., concepts from other shlokas of the Gita, which link your thoughts together) 
- Conclude with a call to action or a thought-provoking question

Use simple language, keep the tone devotional and practical. Make it engaging and inspiring.
''';

class ShlokaContent {
  final String chapterShlokaNum;
  final String shlokaInSanskrit;
  final String meaning;
  final String gitabhashya;

  ShlokaContent({
    required this.chapterShlokaNum,
    required this.shlokaInSanskrit,
    required this.meaning,
    required this.gitabhashya,
  });
}

final _devanagariInBackticksPattern = RegExp(r'`[\u0900-\u097F\s]+`');

ShlokaContent _extractShlokaContent(String mdContent) {
  final lines = mdContent.split('\n');

  // Extract chapter-shloka number (e.g., "## 2-47")
  String chapterShlokaNum = '';
  for (var line in lines) {
    if (line.startsWith('## ')) {
      chapterShlokaNum = line.substring(3).trim();
      break;
    }
  }

  // Extract Sanskrit shloka from shloka-sa code block
  String shlokaInSanskrit = '';
  bool inShlokaSa = false;
  for (var line in lines) {
    if (line.contains('```shloka-sa') && !line.contains('shloka-sa-hk')) {
      inShlokaSa = true;
      continue;
    }
    if (inShlokaSa && line.trim() == '```') {
      break;
    }
    if (inShlokaSa && line.trim().isNotEmpty) {
      shlokaInSanskrit += '$line\n';
    }
  }

  // Extract meaning (paragraph after shloka-sa-hk block, filter out Sanskrit parts)
  String meaning = '';
  bool afterSahk = false;
  bool inMeaning = false;
  for (int i = 0; i < lines.length; i++) {
    final line = lines[i];

    if (line.contains('```shloka-sa-hk')) {
      afterSahk = true;
      continue;
    }
    if (afterSahk && line.trim() == '```') {
      inMeaning = true;
      continue;
    }
    if (inMeaning) {
      // Skip lines starting with underscore or > (these are notes/quotes)
      if (line.trim().startsWith('_') || line.trim().startsWith('>') || line.trim().startsWith('<a name=')) {
        break;
      }
      // Add non-empty lines to meaning
      if (line.trim().isNotEmpty) {
        // Filter out Devanagari text in backticks but keep English
        var filteredLine = line;
        filteredLine = filteredLine.replaceAll(_devanagariInBackticksPattern, '');
        // Clean up extra spaces
        filteredLine = filteredLine.replaceAll(RegExp(r'\s+'), ' ').trim();
        if (filteredLine.isNotEmpty) {
          meaning += '$filteredLine ';
        }
      }
    }
  }

  // Extract gitabhashya (everything after the meaning, excluding quotes that start with >)
  String gitabhashya = '';
  bool inGitabhashya = false;
  bool foundMeaning = false;
  for (int i = 0; i < lines.length; i++) {
    final line = lines[i];

    // Skip until we're past the shloka-sa-hk block
    if (line.contains('```shloka-sa-hk')) {
      foundMeaning = true;
      continue;
    }

    if (foundMeaning) {
      // Start collecting after we see the first note or the paragraph after meaning
      if (!inGitabhashya &&
          (line.trim().startsWith('_') ||
              line.trim().startsWith('<a name=') ||
              (i > 0 && lines[i - 1].trim().isEmpty && line.trim().isNotEmpty))) {
        inGitabhashya = true;
      }

      if (inGitabhashya) {
        // Skip opener questions (lines starting with >)
        if (line.trim().startsWith('>')) {
          continue;
        }
        // Add the line
        if (line.trim().isNotEmpty) {
          gitabhashya += '$line\n';
        }
      }
    }
  }

  return ShlokaContent(
    chapterShlokaNum: chapterShlokaNum,
    shlokaInSanskrit: shlokaInSanskrit.trim(),
    meaning: meaning.trim(),
    gitabhashya: gitabhashya.trim(),
  );
}

String makePrompt() {
  final FeedContent feedContent = Get.find();

  if (feedContent.threeShlokas.length != 3) {
    return templatePrompt; // Return template as-is if shlokas aren't loaded yet
  }

  String prompt = templatePrompt;

  try {
    for (int i = 0; i < 3; i++) {
      final mdFilename = feedContent.threeShlokas[i];
      final openerQ = feedContent.openerQs[i].value;

      // Try to get existing MDContent controller if it exists
      MDContent? mdContent;
      try {
        mdContent = Get.find<MDContent>(tag: mdFilename);
      } catch (e) {
        // If not found, the content hasn't been loaded yet - skip this shloka
        continue;
      }

      final content = mdContent.mdContent.value;

      if (content.isEmpty) {
        continue; // Skip if content is not available
      }

      final shlokaContent = _extractShlokaContent(content);

      // Replace placeholders for this shloka
      final index = i + 1;
      prompt = prompt.replaceAll('{{openerQ$index}}', openerQ);
      prompt = prompt.replaceAll('{{chapterShlokaNum$index}}', shlokaContent.chapterShlokaNum);
      prompt = prompt.replaceAll('{{shlokaInSanskrit$index}}', shlokaContent.shlokaInSanskrit);
      prompt = prompt.replaceAll('{{meaning$index}}', shlokaContent.meaning);
      prompt = prompt.replaceAll('{{gitabhashya$index}}', shlokaContent.gitabhashya);
    }
  } catch (e) {
    // If there's an error, return the template with placeholders
    return templatePrompt;
  }

  return prompt;
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
