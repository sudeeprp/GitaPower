import 'package:askys/content_widget.dart';
import 'package:flutter/material.dart';

class FeedWidget extends StatelessWidget {
  const FeedWidget(this.mdFilenames, {super.key});
  final List<String> mdFilenames;
  @override
  Widget build(BuildContext context) {
    int count = 1;
    return Column(
        children: mdFilenames
            .map((filename) => Expanded(child: buildContent(filename, key: Key('feed/${count++}'))))
            .toList());
  }
}

FeedWidget buildFeed(List<String> mdFilenames) {
  return FeedWidget(mdFilenames);
}
