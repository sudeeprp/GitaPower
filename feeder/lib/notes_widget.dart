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
                  title: _buildOpener(opener.openerContent),
                  controlAffinity: ListTileControlAffinity.leading,
                  children: opener.notes
                      .map((note) => ListTile(
                            title: _buildNote(note),
                            onTap: () => Get.toNamed('/shloka/${note.mdFilename}/${note.noteId}'),
                          ))
                      .toList(),
                ))
            .toList();
        return Scaffold(body: ListView(children: openerElements));
      } else {
        return const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [CircularProgressIndicator()],
        );
      }
    });
  }

  Widget _buildOpener(String openerText) {
    return Row(children: [
      Image.asset('images/bothfeet.png'),
      Expanded(child: Padding(padding: const EdgeInsets.only(left: 8), child: Text(openerText)))
    ]);
  }

  Widget _buildNote(Note note) {
    const rights = ['0', '2', '4', '6', '8'];
    final image = rights.contains(note.noteId[note.noteId.length - 1])
        ? Image.asset('images/right-foot.png')
        : Image.asset('images/left-foot.png');
    return Row(children: [
      image,
      Expanded(
          child: Padding(
              padding: const EdgeInsets.only(left: 8),
              child:
                  Text(toPlainText(note.noteContent), textScaler: const TextScaler.linear(0.9)))),
    ]);
  }
}
