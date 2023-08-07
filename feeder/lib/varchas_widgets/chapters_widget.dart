
import 'package:askys/chaptercontent.dart';
import 'package:askys/varchas_widgets/chaptercontent.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:askys/chapter_headers.dart' as chapters;

class ChaptersWidgetTest extends StatelessWidget{

  const ChaptersWidgetTest({super.key});
  @override
  Widget build(BuildContext context) {
    final ChaptersTOC toc = Get.find();
    return Scaffold(
      appBar: AppBar(title: const Text("Chapters"),),
      body: Obx(() {
        
        if (toc.chaptersLoaded.value) {
      return ListView.builder(itemCount: toc.chapters.length,itemBuilder: (context, index) => ListTile(
        title:  _formChapterTitle(toc.chapters[index].title, Chapter.titleToFilename(toc.chapters[index].title,),index),
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(builder: (context) => ChapterContentTest(chapter: toc.chapters[index], title: toc.chapters[index].title), ));
        },
      ),);}
      else {
          return const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [CircularProgressIndicator()],
          );
        }
      }),
    );
  }
  

  Widget _formChapterTitle(String chapterHeading, String mdFilename, int index) {

    final titleWidgets = [
      // Align(alignment: Alignment.centerLeft, child: Text(chapterHeading)),
      SizedBox(height: 16, width: 32, child: Center(child: Text(index.toString())),),
      const SizedBox(width: 75,),
      Image.asset('images/bothfeet.png', width: 15, height: 15),
      // const Spacer(), 
    ];
    final headerText = chapters.headers[mdFilename];
    if (headerText != null) {
      titleWidgets.add(Expanded(child: Text(headerText, textAlign: TextAlign.right,)));
    }
    return Row(children: titleWidgets);
  }
}


