import 'dart:convert';
import 'dart:io';
import 'package:markdown/markdown.dart' as md;

Map<String, List<String>> shlokaHeaderMap = {};

class HeaderMaker implements md.NodeVisitor {
  HeaderMaker(this.mdFilename);
  final String mdFilename;

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
    elmclass(element) => element.children[0].attributes['class'];
    if (element.tag == 'pre' && elmclass(element) == 'language-shloka-sa') {
      return true;
    } else if (element.tag == 'code') {
      return true;
    }
    return false;
  }

  @override
  void visitText(md.Text markdownText) {
    shlokaHeaderMap[mdFilename]!.add(markdownText.textContent.trim());
  }
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
    HeaderMaker(mdFilename)
        .parse(File('./source-clone-for-gen/gita/$mdFilename').readAsStringSync());
  }
}

String concatShlokas(List<String> headers) {
  return headers.join('\n');
}

void writeConstants() {
  final constsFile = File('./consts.dart');
  constsFile.writeAsStringSync('const headers = {');
  for (var mdFilename in shlokaHeaderMap.keys) {
    constsFile.writeAsStringSync(
        "'$mdFilename': '''${concatShlokas(shlokaHeaderMap[mdFilename]!)}''', ",
        mode: FileMode.append);
  }
  constsFile.writeAsStringSync('};', mode: FileMode.append);
}

void main() {
  fillHeaderMap();
  writeConstants();
}
