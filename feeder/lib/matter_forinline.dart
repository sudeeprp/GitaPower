enum SectionType {
  chapterHeading,
  topicHead,
  shlokaNumber,
  shlokaSA,
  shlokaSAHK,
  meaning,
  commentary,
  explainer,
  note,
  anchor
}

enum Presentation { normal, emphasis }

class MatterForInline {
  MatterForInline(this.text, this.sectionType, this.tag,
      {this.elmclass, this.link, this.presentation, this.isRelevantToSearch = false});
  String text;
  SectionType sectionType;
  String tag;
  Presentation? presentation;
  String? elmclass;
  String? link;
  bool isRelevantToSearch;
}

final devanagari = RegExp('^[\u0900-\u097F]+');
bool isDevanOrTranslit(String word) {
  return word.startsWith('[') | devanagari.hasMatch(word);
}

List<MatterForInline> makeMatterForInlines(String text, SectionType sectionType, String tag,
    {String? elmclass, String? link, List<String>? showPatterns, String? searchPhrase}) {
  bool checkSearchRelevance(String currentText) {
    if (searchPhrase != null && searchPhrase.isNotEmpty && currentText.isNotEmpty) {
      final searchWords = searchPhrase.toLowerCase().split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toSet();
      final textWords = currentText.toLowerCase().split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toSet();
      if (searchWords.isEmpty) return false;
      int matchCount = 0;
      for (String word in searchWords) {
        if (textWords.contains(word)) {
          matchCount++;
        }
      }
      return matchCount * 2 > searchWords.length; // More than half the words match
    }
    return false;
  }

  MatterForInline oneMatterForInline(String text, Presentation presentation) {
    return MatterForInline(text, sectionType, tag,
        elmclass: elmclass,
        link: link,
        presentation: presentation,
        isRelevantToSearch: checkSearchRelevance(text));
  }

  MatterForInline emphasizeOnExactMatch(List<String> matchWords) {
    var presentation = Presentation.normal;
    if (matchWords.any((p) => text == p)) {
      presentation = Presentation.emphasis;
    }
    return oneMatterForInline(text, presentation);
  }

  if (showPatterns != null) {
    if (isDevanOrTranslit(text)) {
      return [emphasizeOnExactMatch(showPatterns)];
    }
    List<MatterForInline> matterForInlines = [];
    String pattern = showPatterns.map((word) => r'\b' + RegExp.escape(word) + r'\b').join('|');
    RegExp regExp = RegExp(pattern, caseSensitive: false, unicode: true);

    int lastMatchEnd = 0;
    final allMatches = regExp.allMatches(text);
    for (RegExpMatch match in allMatches) {
      if (match.start > lastMatchEnd) {
        // stuff between matches
        matterForInlines
            .add(oneMatterForInline(text.substring(lastMatchEnd, match.start), Presentation.normal));
      }
      matterForInlines.add(oneMatterForInline(match.group(0)!, Presentation.emphasis)); // the match
      lastMatchEnd = match.end;
    }

    if (lastMatchEnd < text.length) {
      // remaining stuff at the end
      matterForInlines.add(oneMatterForInline(text.substring(lastMatchEnd), Presentation.normal));
    }
    return matterForInlines;
  }
  return [oneMatterForInline(text, Presentation.normal)];
}
