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
    final words = text.split(RegExp(r'\s+'));
    List<String> normalWords = [];
    for (final word in words) {
      if (showPatterns.any((pattern) => word.contains(pattern))) {
        if (normalWords.isNotEmpty) {
          matterForInlines.add(oneMatterForInline(normalWords.join(' '), Presentation.normal));
          normalWords.clear();
        }
        matterForInlines.add(oneMatterForInline(word, Presentation.emphasis));
      } else {
        normalWords.add(word);
      }
    }
    if (normalWords.isNotEmpty) {
      matterForInlines.add(oneMatterForInline(normalWords.join(' '), Presentation.normal));
    }
    return matterForInlines;
  }
  return [oneMatterForInline(text, Presentation.normal)];
}
