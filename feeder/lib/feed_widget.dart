import 'package:askys/chaptercontent.dart';
import 'package:askys/choice_selector.dart';
import 'package:askys/choices_row.dart';
import 'package:askys/content_widget.dart';
import 'package:askys/matter_forinline.dart';
import 'package:askys/mdcontent.dart';
import 'package:askys/screenify.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'feedcontent.dart';

bool isSectionInFeed(SectionType sectionType) {
  return sectionType == SectionType.shlokaSA ||
      sectionType == SectionType.shlokaSAHK ||
      sectionType == SectionType.meaning;
}

Widget openerLine(BuildContext context,
    {required String chapterNumber, required String openerQ, required String shortTitle}) {
  return Row(
    children: [
      Padding(
          padding: EdgeInsets.symmetric(horizontal: 4),
          child: Image.asset(
            'images/Chapter_$chapterNumber.png',
            width: 28,
            height: 28,
          )),
      Expanded(
        flex: 4,
        child: Text(openerQ,
            style: styleFor(context, 'note')?.copyWith(fontStyle: FontStyle.italic),
            softWrap: true,
            maxLines: 2),
      ),
      Expanded(
        flex: 1,
        child: Padding(
            padding: EdgeInsets.only(right: 4),
            child: Text(
              shortTitle,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.right,
            )),
      )
    ],
  );
}

class ShlokaInsideFeed extends StatelessWidget {
  ShlokaInsideFeed({required this.filename, required this.count, super.key});
  final FeedContent feedContent = Get.find();
  final String filename;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return InkWell(
          child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        elevation: 8,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(children: [
            // Decorative saffron vertical bar
            Container(
                width: 12,
                height: 48,
                decoration:
                    BoxDecoration(color: const Color(0xFFEE9A4D), borderRadius: BorderRadius.circular(6))),
            const SizedBox(width: 4),
            Expanded(
                child: Column(
              children: [
                openerLine(context,
                    chapterNumber: Chapter.filenameToChapterNumber(filename),
                    openerQ: feedContent.openerQs[count - 1].value,
                    shortTitle: Chapter.filenameToShortTitle(filename)),
                buildContentFeed(filename, isSectionVisible: isSectionInFeed, key: Key('feed/$count')),
              ],
            )),
          ]),
        ),
      ));
    });
  }
}

class FeedWidget extends StatelessWidget {
  const FeedWidget({super.key});
  @override
  Widget build(BuildContext context) {
    final FeedContent feedContent = Get.find();
    return Obx(() {
      if (feedContent.threeShlokas.length == 3) {
        int count = 1;
        return SingleChildScrollView(
            child: Column(
                children: feedContent.threeShlokas
                    .map((filename) => ShlokaInsideFeed(filename: filename, count: count++) as Widget)
                    .toList()));
      } else {
        return const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [CircularProgressIndicator()],
        );
      }
    });
  }
}

Widget feedScreen() {
  return screenify(FeedWidget(),
      appBar: AppBar(title: Text("Explore"), actions: [const PromptWidget()]),
      choicesRow: choicesRow([SizedBox(width: choiceSpacing), widgetToHome()],
          [PersonalizeIcon(), SizedBox(width: choiceSpacing)]));
}

const templatePrompt = '''You are a friendly Sri Vaishnava who speaks in accessible, heartfelt ways.
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
  2. Brief overview in 4 bullet-points: They need to trigger the reader to go deeper.
  3. Conversational script, lasting less than 10-minutes. Guidelines:
      - Speak as a humble devotee, not as a scholar.
      - Blend clarity (for the mind) with tenderness (for the heart).
      - Make it engaging and relatable to modern life — work, school, doubt, relationships, small victories.
      - Use simple, natural language with anecdotes — devotional yet practical.
      - Use gentle humor only where it helps.
      - Insert a reference to a shloka when appropriate. e.g., (13-4)
  4. Call to Action: End with an actionable suggestion or thought-provoking question that readers can apply in their lives

Keep your tone friendly, never judgmental, never moralizing. Give readers the dignity of choice, while avoiding procrastination.

Remember: The goal is to help readers experience the material, not just understand it intellectually.
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

ShlokaContent _extractShlokaContent(String mdContent) {
  final allBackticksPattern = RegExp(r'`[^`]+`');
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
      filteredLine = filteredLine.replaceAll(allBackticksPattern, '');
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

  for (int i = 0; i < 3; i++) {
    final mdFilename = feedContent.threeShlokas[i];
    final openerQ = feedContent.openerQs[i].value;

    final mdContent = Get.find<MDContent>(tag: mdFilename);
    final content = mdContent.mdContent.value;

    final shlokaContent = _extractShlokaContent(content);

    final index = i + 1;
    prompt = prompt.replaceAll('{{openerQ$index}}', openerQ);
    prompt = prompt.replaceAll('{{chapterShlokaNum$index}}', shlokaContent.chapterShlokaNum);
    prompt = prompt.replaceAll('{{shlokaInSanskrit$index}}', shlokaContent.shlokaInSanskrit);
    prompt = prompt.replaceAll('{{meaning$index}}', shlokaContent.meaning);
    prompt = prompt.replaceAll('{{gitabhashya$index}}', shlokaContent.gitabhashya);
  }
  return prompt;
}

class PromptWidget extends StatelessWidget {
  const PromptWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.symmetric(horizontal: 4),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 4,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            backgroundColor: const Color(0xFFEE9A4D),
            foregroundColor: const Color(0xFF2D1810),
          ),
          onPressed: () {
            final prompt = makePrompt();
            Clipboard.setData(ClipboardData(text: prompt));

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Prompt copied to clipboard! Paste it in your favorite AI chat.'),
                duration: Duration(seconds: 3),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
          child: Row(children: [
            Image.asset('images/shloka_visible_light.png', height: 24, width: 24),
            const SizedBox(width: 8),
            Text('Copy a prompt to reflect',
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
          ]),
        ));
  }
}
