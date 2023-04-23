import 'package:askys/content_source.dart';
import 'package:get/get.dart';

class Note {
  Note(this.noteId, this.noteContent, this.mdFilename);
  String noteId;
  String noteContent;
  String mdFilename;
}

class Opener {
  Opener(this.noteId, this.openerContent, this.mdFilename);
  factory Opener.fromNotesJson(List<Map<String, dynamic>> notesJson) {
    final opener = Opener(notesJson[0]['note_id'], notesJson[0]['text'], notesJson[0]['file']);
    for (var i = 0; i < notesJson.length; i++) {
      opener.notes.add(Note(notesJson[i]['note_id'], notesJson[i]['text'], notesJson[i]['file']));
    }
    return opener;
  }
  String noteId;
  String openerContent;
  String mdFilename;
  List<Note> notes = [];
}

List<Opener> compilationsToOpeners(List<Map<String, String>> notes) {
  List<int> openerIndexes = [];
  for (var i = 0; i < notes.length; i++) {
    if (notes[i]['note_id']!.startsWith('applopener')) {
      openerIndexes.add(i);
    }
  }
  List<Opener> openers = [];
  for (var i = 0; i < openerIndexes.length - 1; i++) {
    final applNoteOpener =
        Opener.fromNotesJson(notes.sublist(openerIndexes[i], openerIndexes[i + 1]));
    openers.add(applNoteOpener);
  }
  openers.add(Opener.fromNotesJson(notes.sublist(openerIndexes[openerIndexes.length - 1])));
  return openers;
}

class NotesTOC extends GetxController {
  List<Opener> openerNotes = [];
  final notesLoaded = false.obs;
  @override
  void onInit() async {
    final GitHubFetcher contentSource = Get.find();
    openerNotes.addAll(compilationsToOpeners(await contentSource.notesCompiled()));
    notesLoaded.value = true;
    super.onInit();
  }
}
