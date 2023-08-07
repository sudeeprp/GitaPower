import 'dart:convert';
import 'dart:io';
import 'package:markdown/markdown.dart' as md;

Map<String, List<String>> shlokaHeaderMap = {};
Map<String, List<String>> meaningHeaderMap = {};

enum HeaderSectionType { begin, shlokaSA, shlokaSAHK, meaning, other }

class HeaderMaker implements md.NodeVisitor {
  HeaderMaker(this.mdFilename);
  final String mdFilename;
  HeaderSectionType _prevSectionType = HeaderSectionType.begin;
  HeaderSectionType _presentSectionType = HeaderSectionType.other;

  void parse(String markdownContent) {
    List<String> lines = markdownContent.split('\n');
    md.Document document = md.Document(encodeHtml: false);
    for (md.Node node in document.parseLines(lines)) {
      node.accept(this);
    }
  }

  @override
  void visitElementAfter(md.Element element) {}

  @override
  bool visitElementBefore(md.Element element) {
    if (_isSeparate(element.tag)) {
      _prevSectionType = _presentSectionType;
      _presentSectionType = _detectSectionType(element, _prevSectionType);
    }
    if (_presentSectionType == HeaderSectionType.shlokaSA ||
        _presentSectionType == HeaderSectionType.meaning) {
      return true;
    }
    return false;
  }

  @override
  void visitText(md.Text markdownText) {
    if (_presentSectionType == HeaderSectionType.shlokaSA) {
      shlokaHeaderMap[mdFilename]!.add(markdownText.textContent.trim());
    } else if (_presentSectionType == HeaderSectionType.meaning &&
        _isMeaningSentence(markdownText.textContent)) {
      meaningHeaderMap[mdFilename]!.add(markdownText.textContent);
    }
  }
}

bool _startsWithDevanagari(String? content) {
  if (content == null) {
    return false;
  } else {
    return RegExp('^[\u0900-\u097F]+').hasMatch(content);
  }
}

bool _isMeaningSentence(String text) {
  return !_startsWithDevanagari(text) && !text.startsWith('[');
}

HeaderSectionType _detectSectionType(md.Element element, HeaderSectionType prevSectionType) {
  final classToSectionType = {
    'language-shloka-sa': HeaderSectionType.shlokaSA,
    'language-shloka-sa-hk': HeaderSectionType.shlokaSAHK
  };
  final tagToSectionType = {
    'pre': (element) => classToSectionType[element.children[0].attributes['class']],
    'p': (element) =>
        _startsWithDevanagari(element.textContent) && prevSectionType != HeaderSectionType.other
            ? HeaderSectionType.meaning
            : HeaderSectionType.other,
  };
  final tagConverter = tagToSectionType[element.tag];
  if (tagConverter != null) {
    return tagConverter(element)!;
  }
  return HeaderSectionType.other;
}

bool _isSeparate(elementTag) {
  const widgetSeparators = ['h1', 'h2', 'p', 'pre', 'blockquote'];
  return widgetSeparators.contains(elementTag);
}

void fillHeaderMap() {
  final mdsStr =
      File('./source-clone-for-gen/compile/md_to_note_ids_compiled.json').readAsStringSync();
  final List<dynamic> mdSequence = jsonDecode(mdsStr);
  for (Map<String, dynamic> md in mdSequence) {
    final mdFilename = md.keys.first;
    // ignore: avoid_print
    print('processing $mdFilename');
    shlokaHeaderMap[mdFilename] = [];
    meaningHeaderMap[mdFilename] = [];
    HeaderMaker(mdFilename)
        .parse(File('./source-clone-for-gen/gita/$mdFilename').readAsStringSync());
  }
}

String concatShlokas(List<String> headers) {
  return headers.join('\n');
}

String concatMeanings(List<String> meanings) {
  return meanings.join(' ').replaceAll(RegExp((r'\s+')), ' ').trim();
}

String shlokaHeaders(String mdFilename) {
  print(meaningHeaderMap[mdFilename]!);
  return "{'shloka': '''${concatShlokas(shlokaHeaderMap[mdFilename]!)}''', 'meaning': '''${concatMeanings(meaningHeaderMap[mdFilename]!)}'''}";
}

void writeConstants() {
  final constsFile = File('./consts.dart');
  constsFile.writeAsStringSync('const headers = {');
  for (var mdFilename in shlokaHeaderMap.keys) {
    constsFile.writeAsStringSync("'$mdFilename': ${shlokaHeaders(mdFilename)},\n",
        mode: FileMode.append);
  }
  constsFile.writeAsStringSync('};', mode: FileMode.append);
}

void main() {
  fillHeaderMap();
  writeConstants();
}
