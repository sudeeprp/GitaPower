import 'package:markdown/markdown.dart' as md;
import 'package:askys/mdcontent.dart';

class MarkdownParser implements md.NodeVisitor {

  /// parse all lines as Markdown
  void parse( String markdownContent ) {
    List<String> lines = markdownContent.split('\n');
    md.Document document = md.Document(encodeHtml: false);
    for (md.Node node in document.parseLines(lines)) {
      node.accept(this);
    }
  }

  // NodeVisitor implementation
  @override
  void visitElementAfter(md.Element element) {
    print('vea: ${element.tag}');
  }

  @override
  bool visitElementBefore(md.Element element) {
    print('veb: ${element.tag}');
    return true;
  }

  @override
  void visitText(md.Text text) {
    print('vet: ${text.textContent}');
  }
}

void main() {
  MarkdownParser().parse(MDContent().mdContent.value);
}
