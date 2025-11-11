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
    '''You are a friendly Sri Vaishnava who speaks in accessible, heartfelt ways.
You connect classical literature to everyday life through warmth, humility and practical anecdotes.

Your task: Given a 3-shloka-set from the Gita with Sri Ramanuja's Gitabhashya commentary,
weave them together into a conversation.

Use concepts present in the Gitabhashya:
- Experience of the Self is superior to any other outcome
- Krishna is the basis of the Self
- Whenever you experience something special, you experience a part of Krishna
- Devotion to Krishna is "worship with friendship"
- However, we are bound by the three qualities. Sattva gives contentment, Rajas makes us show-off, Tamas confuses us
- Surrender to Krishna is the only way out. Anyone can surrender.

Here's your 3-shloka-set in markdown format:

>Starting shloka, opening question: {{openerQ1}}

## {{chapterShlokaNum1}}

{{shlokaInSanskrit1}}

### Meaning

{{meaning1}}

### Gitabhashya

{{gitabhashya1}}

---

>Middle shloka, opening question: {{openerQ2}}

## {{chapterShlokaNum2}}

{{shlokaInSanskrit2}}

### Meaning

{{meaning2}}

### Gitabhashya

{{gitabhashya2}}

---

>Finishing shloka, opening question: {{openerQ3}}

## {{chapterShlokaNum3}}

{{shlokaInSanskrit3}}

### Meaning

{{meaning3}}

### Gitabhashya

{{gitabhashya3}}

---
(end of 3-shloka-set)

Task Details: Based on the above 3-shloka-set and commentary:

**Identify the central theme**: What common thread connects these three shlokas? What aspect of life or spiritual practice do they address?

**Produce the following**:
  1. Title: A catchy, relatable title that captures the theme.
  2. A brief overview in 4 bullet-points: They need to trigger the reader to go deeper.
  3. Conversational script, like a 10-minute Satsang. Guidelines:
      - Speak as a humble devotee, not as a scholar.
      - Blend clarity (for the mind) with tenderness (for the heart).
      - Make it engaging and relatable to modern life — work, school, doubt, relationships, small victories.
      - Use simple, natural language with anecdotes — devotional yet practical.
      - Use gentle humor only where it helps.
      - Insert a reference to a shloka when appropriate. e.g., (13.4)
  4. Call to Action: End with an actionable suggestion or thought-provoking question that readers can apply in their lives

Remember: The goal is to help readers experience the material, not just understand them intellectually.

Structure your output in markdown format.
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

final _allBackticksPattern = RegExp(r'`[^`]+`');

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
      final trimmedLine = line.trim();
      // Empty line ends the meaning section
      if (trimmedLine.isEmpty) {
        inMeaning = false;
        break;
      }
      // Skip lines starting with underscore or > (these are notes/quotes)
      if (trimmedLine.startsWith('_') || trimmedLine.startsWith('>') || trimmedLine.startsWith('<a name=')) {
        break;
      }
      // Add non-empty lines to meaning (we already know it's non-empty from above checks)
      // Filter out all backtick content (Devanagari and English transliteration)
      var filteredLine = line;
      filteredLine = filteredLine.replaceAll(_allBackticksPattern, '');
      // Clean up extra spaces
      filteredLine = filteredLine.replaceAll(RegExp(r'\s+'), ' ').trim();
      if (filteredLine.isNotEmpty) {
        meaning += '$filteredLine ';
      }
    }
  }

  // Extract gitabhashya (everything after an empty line following shloka-sa-hk block)
  String gitabhashya = '';
  bool afterSahkClosing = false;
  bool inSahkBlock = false;
  bool foundEmptyLine = false;
  for (int i = 0; i < lines.length; i++) {
    final line = lines[i];

    // Track when we enter shloka-sa-hk block
    if (line.contains('```shloka-sa-hk')) {
      inSahkBlock = true;
      continue;
    }

    // Track when we exit shloka-sa-hk block
    if (inSahkBlock && line.trim() == '```') {
      afterSahkClosing = true;
      inSahkBlock = false;
      continue;
    }

    // After closing, skip all non-empty lines until we find an empty line
    if (afterSahkClosing && !foundEmptyLine) {
      if (line.trim().isEmpty) {
        foundEmptyLine = true;
      }
      continue;
    }

    // Collect everything after the empty line
    if (afterSahkClosing && foundEmptyLine && line.trim().isNotEmpty) {
      gitabhashya += '$line\n';
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
    return ''; // Return empty string if shlokas aren't loaded yet
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
    // If there's an error, return empty string
    return '';
  }

  return prompt;
}

class PromptWidget extends StatelessWidget {
  const PromptWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        final prompt = makePrompt();
        Clipboard.setData(ClipboardData(text: prompt));

        // Show a transient message to the user
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Prompt copied to clipboard! Paste it in your favorite AI chat.'),
            duration: Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      child: const Icon(Icons.chat_bubble, size: 48, color: Colors.blue),
    );
  }
}
