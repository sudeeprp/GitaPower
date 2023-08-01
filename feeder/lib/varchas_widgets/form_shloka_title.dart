import 'package:flutter/material.dart';
import 'package:askys/shloka_headers.dart' as shlokas;

class FormShlokaTitle extends StatelessWidget {
  const FormShlokaTitle(
      this.shlokaTitleText, this.mdFilename, this.codeColor, this.currentLang,
      {super.key});
  final String shlokaTitleText;
  final String mdFilename;
  final Color codeColor;
  final String currentLang;
   @override
  Widget build(BuildContext context) {
    
   
  
    //print(shlokaTitleText);
    String testHeaders = shlokaTitleText.replaceAll(" ", "_");
    testHeaders = "$testHeaders.md";
    // print(shlokas.headers[testHeaders]?["meaning"]);

    final titleWidgets = [];
    // titleWidgets.add(Padding(
    //   padding: const EdgeInsets.symmetric(vertical: 40),
    //   child: Text(shlokaTitleText,style: const TextStyle(fontSize: 20),),
    // ));
    final headerText = shlokas.headers[mdFilename]?['shloka'];

    if (headerText != null) {
      // Text currentText = widget.currentLang == "eng"
      //                         ? Text(shlokas.headers[testHeaders]!["meaning"]!)
      //                         : Text(
      //                             headerText,
      //                             style:
      //                                 TextStyle(color: widget.codeColor, fontSize: 20),
      //                           );
      // Text currentText = Text(
      //   headerText,
      //   style: TextStyle(color: codeColor, fontSize: 20),
      // );
    //   if(currentLang == "eng"){
    
    //     currentText = Text(shlokas.headers[testHeaders]!["meaning"]!);
    
    // }
    // else{
      
    //     currentText = Text(
    //     headerText,
    //     style: TextStyle(color: codeColor, fontSize: 20),
    //   );
     
    // }
    
      titleWidgets.add(
        Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 16, left: 8, right: 8),
          child: Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withOpacity(0.1),
                  offset: Offset(-6.0, -6.0),
                  blurRadius: 16.0,
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.4),
                  offset: Offset(6.0, 6.0),
                  blurRadius: 16.0,
                ),
              ],
            ),
            child: Card(
              color: Theme.of(context).colorScheme.background,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 14.0),
                          child: Text(
                            headerText != ""
                                ? shlokaTitleText
                                : "Introduction",
                            style: const TextStyle(fontSize: 24),
                          ),
                        ),
                        const Spacer(),
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 20,
                          color: Theme.of(context).colorScheme.onBackground,
                        ),
                      ],
                    ),
                  ),
                  headerText == ""
                      ? const SizedBox(
                          height: 16,
                        )
                      : Padding(
                          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                          child: currentLang == "eng"
                              ? Text(shlokas.headers[testHeaders]!["meaning"]!)
                              : Text(
                                  headerText,
                                  style: TextStyle(
                                      color: codeColor, fontSize: 20),
                                ),
                          // child: currentText,
                        ),
                ],
              ),
            ),
          ),
        ),
      );
    }
    return Column(children: [...titleWidgets]);
  }
 
}

