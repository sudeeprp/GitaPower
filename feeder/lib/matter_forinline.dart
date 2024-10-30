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
  MatterForInline(this.text, this.sectionType, this.tag, {this.elmclass, this.link, this.presentation});
  String text;
  SectionType sectionType;
  String tag;
  Presentation? presentation;
  String? elmclass;
  String? link;
}

final devanagari = RegExp('^[\u0900-\u097F]+');
bool isDevanOrTranslit(String word) {
  return word.startsWith('[') | devanagari.hasMatch(word);
}

List<MatterForInline> makeMatterForInlines(String text, SectionType sectionType, String tag,
    {String? elmclass, String? link, List<String>? showPatterns}) {
  MatterForInline oneMatterForInline(String text, Presentation presentation) {
    return MatterForInline(text, sectionType, tag,
        elmclass: elmclass, link: link, presentation: presentation);
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
