import 'package:askys/varchas_controllers/font_controller.dart';
import 'package:flutter/material.dart';
import 'package:askys/shloka_headers.dart' as shlokas;
import 'package:get/get.dart';

class FormShlokaTitle extends StatefulWidget {
  
  const FormShlokaTitle(
      this.shlokaTitleText, this.mdFilename, this.codeColor, this.currentLang, this.fontSize,
      {super.key});
  final String shlokaTitleText;
  final String mdFilename;
  final Color codeColor;
  final String currentLang;
  final double fontSize;

  @override
  State<FormShlokaTitle> createState() => _FormShlokaTitleState();
}

class _FormShlokaTitleState extends State<FormShlokaTitle> {
  final FontController fontcontroller = Get.put(FontController());
  @override
  Widget build(BuildContext context) {

    String testHeaders = widget.shlokaTitleText.replaceAll(" ", "_");
    testHeaders = "$testHeaders.md";
    final titleWidgets = [];
    final headerText = shlokas.headers[widget.mdFilename]?['shloka'];
    if (headerText != null) {
      titleWidgets.add(
        Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 16, left: 8, right: 8),
          child: Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withOpacity(0.1),
                  offset: const Offset(-6.0, -6.0),
                  blurRadius: 16.0,
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.4),
                  offset: const Offset(6.0, 6.0),
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
                                ? widget.shlokaTitleText.replaceAll("second", "2nd").replaceAll("first", "1st")
                                : "Introduction",
                            style: TextStyle(fontSize: fontcontroller.fontSize.value+5),
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
                      : Obx(() =>  Padding(
                          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                          child: widget.currentLang == "eng" 
                              ? Text(shlokas.headers[testHeaders]!["meaning"]!.replaceAll(". ", ".\n\n").replaceAll("? ", "?").replaceAll("?", "? "),style: TextStyle(fontSize: widget.fontSize,height: fontcontroller.currentFontHeight.value),
                                  )
                              : SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Text(
                                    headerText,
                                    style: TextStyle(
                                        color: widget.codeColor, fontSize: fontcontroller.fontSize.value,height: fontcontroller.currentFontHeight.value),
                                  ),
                              ),
                        ),
              )],
              ),
            ),
          ),
        ),
      );
    }
    return Column(children: [...titleWidgets]);
  }
}

  