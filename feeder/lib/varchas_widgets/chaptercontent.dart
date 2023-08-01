import 'package:askys/chaptercontent.dart';
import 'package:askys/choice_selector.dart';
import 'package:askys/varchas_widgets/form_shloka_title.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:askys/shloka_headers.dart' as shlokas;

class ChapterContentTest extends StatefulWidget {
  const ChapterContentTest(
      {super.key, required this.chapter, required this.title});
  final Chapter chapter;
  final String title;

  @override
  State<ChapterContentTest> createState() => _ChapterContentTestState();
}

class _ChapterContentTestState extends State<ChapterContentTest> {
  String _currentLang = "sanskrit";
  
  void _setLang() {
    if (_currentLang == "sanskrit") {
      setState(() {
        _currentLang = "eng";
      });
      
    } else {
      setState(() {
        _currentLang = "sanskrit";
      });
      
    }
    print(_currentLang);
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: IconButton(
                onPressed: _setLang,
                icon: const Icon(
                  Icons.abc,
                  size: 40,
                ),
              ),
            ),
          ],
        ),
        body: ListView.builder(
            itemCount: widget.chapter.shokas.length,
            itemBuilder: (ctx, index) {
              // print(chapter.shokas[index]);
              final mdFilename =
                  Chapter.titleToFilename(widget.chapter.shokas[index]);
              final Choices choices = Get.find();
              final codeColor = choices.codeColor.value;
              // print('/shloka/$mdFilename');
              //print(chapter.shokas);
              // if (chapter.shokas[index].split(' ')[0] == "Chapter" ){
              //   return const Text("Display chapter overview here");
              // }
              return ListTile(
                title: FormShlokaTitle(widget.chapter.shokas[index],
                    mdFilename, codeColor,_currentLang),
                onTap: () => Get.toNamed('/shloka/$mdFilename'),
              );
            }));
  }

  // Widget _formShlokaTitle(String shlokaTitleText, String mdFilename,
  //   Color codeColor, BuildContext context) {
  //   //print(shlokaTitleText);
  //   String testHeaders = shlokaTitleText.replaceAll(" ", "_");
  //   testHeaders = testHeaders + ".md";
  //   // print(shlokas.headers[testHeaders]?["meaning"]);

  //   final titleWidgets = [];
  //   // titleWidgets.add(Padding(
  //   //   padding: const EdgeInsets.symmetric(vertical: 40),
  //   //   child: Text(shlokaTitleText,style: const TextStyle(fontSize: 20),),
  //   // ));
  //   final headerText = shlokas.headers[mdFilename]?['shloka'];
  //   if (headerText != null) {
  //     titleWidgets.add(
  //       Padding(
  //         padding: const EdgeInsets.only(top: 8, bottom: 16, left: 8, right: 8),
  //         child: Container(
  //           decoration: BoxDecoration(
  //             boxShadow: [
  //               BoxShadow(
  //                 color: Colors.white.withOpacity(0.1),
  //                 offset: Offset(-6.0, -6.0),
  //                 blurRadius: 16.0,
  //               ),
  //               BoxShadow(
  //                 color: Colors.black.withOpacity(0.4),
  //                 offset: Offset(6.0, 6.0),
  //                 blurRadius: 16.0,
  //               ),
  //             ],
  //           ),
  //           child: Card(
  //             color: Theme.of(context).colorScheme.background,
  //             shape: RoundedRectangleBorder(
  //                 borderRadius: BorderRadius.circular(16)),
  //             child: Column(
  //               children: [
  //                 Padding(
  //                   padding: const EdgeInsets.all(8.0),
  //                   child: Row(
  //                     mainAxisAlignment: MainAxisAlignment.end,
  //                     children: [
  //                       Padding(
  //                         padding: const EdgeInsets.only(left: 14.0),
  //                         child: Text(
  //                           headerText != "" ? shlokaTitleText : "Introduction",
  //                           style: const TextStyle(fontSize: 24),
  //                         ),
  //                       ),
  //                       const Spacer(),
  //                       Icon(
  //                         Icons.arrow_forward_ios_rounded,
  //                         size: 20,
  //                         color: Theme.of(context).colorScheme.onBackground,
  //                       ),
  //                     ],
  //                   ),
  //                 ),
  //                 headerText == ""
  //                     ? const SizedBox(
  //                         height: 16,
  //                       )
  //                     : Padding(
  //                         padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
  //                         child: _currentLang == "eng"
  //                             ? Text(shlokas.headers[testHeaders]!["meaning"]!)
  //                             : Text(
  //                                 headerText,
  //                                 style:
  //                                     TextStyle(color: codeColor, fontSize: 20),
  //                               ),
  //                       ),
  //               ],
  //             ),
  //           ),
  //         ),
  //       ),
  //     );
  //   }
  //   return Column(children: [...titleWidgets]);
  // }
}
