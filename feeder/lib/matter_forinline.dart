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
  final String text;
  SectionType sectionType;
  String tag;
  Presentation? presentation;
  String? elmclass;
  String? link;
}

List<MatterForInline> makeMatterForInlines(String text, SectionType sectionType, String tag,
    {String? elmclass, String? link, List<String>? showPatterns}) {
  MatterForInline oneMatterForInline(String text, Presentation presentation) {
    return MatterForInline(text, sectionType, tag,
        elmclass: elmclass, link: link, presentation: presentation);
  }

  if (showPatterns != null) {
    List<MatterForInline> matterForInlines = [];
    String pattern = showPatterns.map((word) => RegExp.escape(word)).join('|');
    RegExp regExp = RegExp(pattern, caseSensitive: false);

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
