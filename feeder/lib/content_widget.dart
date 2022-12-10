import 'package:askys/mdcontent.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:markdown/markdown.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';

Widget mdToWidgets(String markdown) {
  final contentInHtml = markdownToHtml(markdown);
  return HtmlWidget(
    contentInHtml,
    customStylesBuilder: (element) {
      if (element.localName == 'code') {
        return {'color': 'maroon'};
      }
      return null;
    },
  );
}

class ContentWidget extends StatelessWidget {
  const ContentWidget({Key? key}) : super(key: key);

  @override
  Widget build(context) {
    MDContent md = Get.find();
    return Center(child: Obx(() => mdToWidgets(md.mdContent.value)));
  }
}
