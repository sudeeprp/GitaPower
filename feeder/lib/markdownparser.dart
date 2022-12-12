import 'package:flutter/cupertino.dart';
import 'package:markdown/markdown.dart' as md;

class MarkdownParser implements md.NodeVisitor {
  String markdown;
  List<RichText> texts = [];
  List<TextSpan> _currentSpanSequence = [];

  MarkdownParser(this.markdown);

  List<RichText> widgets(context) {
    List<String> lines = markdown.split('\n\n');
    md.Document document = md.Document(encodeHtml: false);
    for (md.Node node in document.parseLines(lines)) {
      _currentSpanSequence = [];
      node.accept(this);
      if (_currentSpanSequence.length == 1) {
        texts.add(RichText(text: _currentSpanSequence[0]));
      } else {
        texts.add(RichText(
            text: TextSpan(
                style: DefaultTextStyle.of(context).style,
                children: _currentSpanSequence)));
      }
    }
    return texts;
  }

  @override
  bool visitElementBefore(md.Element element) {
    return true;
  }

  @override
  void visitElementAfter(md.Element element) {}
  @override
  void visitText(md.Text text) {
    _currentSpanSequence.add(TextSpan(text: text.textContent));
  }
}
