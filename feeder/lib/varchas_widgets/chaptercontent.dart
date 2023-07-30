import 'package:askys/chaptercontent.dart';
import 'package:askys/choice_selector.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:askys/shloka_headers.dart' as shlokas;
class ChapterContentTest extends StatelessWidget{

  const ChapterContentTest({super.key, required this.chapter, required this.title});
  final Chapter chapter;
  final String title;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: ListView.builder(itemCount: chapter.shokas.length,itemBuilder: (ctx, index) { 
        // print(chapter.shokas[index]);
        final mdFilename = Chapter.titleToFilename(chapter.shokas[index]);
        final Choices choices = Get.find();
        final codeColor = choices.codeColor.value;
        // print('/shloka/$mdFilename');
      return ListTile(
        
                      title: _formShlokaTitle(chapter.shokas[index], mdFilename,codeColor),
                      onTap: () => Get.toNamed('/shloka/$mdFilename'),
                    );
  })
    );
  }
  Widget _formShlokaTitle(String shlokaTitleText, String mdFilename,Color codeColor) {
    print(shlokaTitleText);
    final titleWidgets = [Text(shlokaTitleText)];
    final headerText = shlokas.headers[mdFilename]?['shloka'];
    if (headerText != null) {
      titleWidgets.add(Text(headerText, style: TextStyle(color: codeColor)));
    }
    return Column(children: [...titleWidgets, const SizedBox(height: 16,)]);
  }
}
