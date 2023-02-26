import 'package:flutter/material.dart';
import 'package:askys/notecontent.dart';
import 'package:get/get.dart';

class NotesWidget extends StatelessWidget {
  const NotesWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final NotesTOC notesToc = Get.find();
    return Obx(() {
      if (notesToc.notesLoaded.value) {
        List<ExpansionTile> openerElements = notesToc.openerNotes
            .map((opener) => ExpansionTile(
                  title: Text(opener.openerContent),
                  controlAffinity: ListTileControlAffinity.leading,
                  children: opener.notes
                      .map((note) => ListTile(
                            title: Text(note.noteContent),
                            onTap: () {
                              Get.toNamed('/anote', arguments: {'mdFilename': note.mdFilename});
                            },
                          ))
                      .toList(),
                ))
            .toList();
        return Scaffold(body: ListView(children: openerElements));
      } else {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [CircularProgressIndicator()],
        );
      }
    });
  }
}
