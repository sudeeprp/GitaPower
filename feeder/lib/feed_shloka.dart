import 'package:askys/chapter_shloka_widget.dart';
import 'package:askys/chaptercontent.dart';
import 'package:askys/choice_selector.dart';
import 'package:askys/header_note_widget.dart';
import 'package:askys/notecontent.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FeedShloka extends StatelessWidget {
  const FeedShloka(this.mdFilename, {super.key});
  final String mdFilename;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final ContentNotes contentNotes = Get.find();
      if (contentNotes.notesLoaded.value) {
        final Choices choices = Get.find();
        final headPreference = choices.headPreference.value;
        return SingleChildScrollView(
            child: GestureDetector(
              onTap: () => Get.toNamed('/shloka/$mdFilename'),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  HeaderNote(contentNotes.noteForMD(mdFilename), Chapter.filenameToShortTitle(mdFilename)),
                  formShlokaTitle(mdFilename, headPreference, context) ?? const Text('Not found'),
                ]),
            )
          );
      } else {
        return const Text('loading');
      }
    });
  }
}
