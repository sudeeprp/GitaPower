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

Map<String, String?> mapMdsToTheirNotes(
    List<Map<String, List<String>>> mdToNoteIds, List<Map<String, String>> notesCompiled) {
  Map<String, String?> mdsToInitialNote = {};
  String? lastNote;
  for (int i = 0; i < mdToNoteIds.length; i++) {
    final mdFilename = mdToNoteIds[i].keys.first;
    mdsToInitialNote[mdFilename] = lastNote;
    final noteIdsInMD = mdToNoteIds[i][mdFilename];
    if (noteIdsInMD != null && noteIdsInMD.isNotEmpty) {
      String lastNoteId = noteIdsInMD.last;
      final noteEntry = notesCompiled.where((note) => note['note_id'] == lastNoteId);
      if (noteEntry.isNotEmpty) {
        lastNote = noteEntry.first['text'];
      }
    }
  }
  return mdsToInitialNote;
}

class ContentNotes extends GetxController {
  Map<String, String?> mdsToInitialNote = {};
  List<String> mdSequence = [];
  @override
  void onInit() async {
    final GitHubFetcher contentSource = Get.find();
    final notesCompiled = await contentSource.notesCompiled();
    final mdToNoteIds = await contentSource.mdToNoteIds();
    mdsToInitialNote = mapMdsToTheirNotes(mdToNoteIds, notesCompiled);
    mdSequence = mdsToInitialNote.keys.toList();
    super.onInit();
  }

  String? noteForMD(String mdFilename) {
    return mdsToInitialNote[mdFilename];
  }

  String? nextmd(String mdFilename) {
    int index = mdSequence.indexOf(mdFilename);
    if (index != -1 && index < mdSequence.length - 1) {
      return mdSequence[index + 1];
    }
    return null;
  }

  String? prevmd(String mdFilename) {
    int index = mdSequence.indexOf(mdFilename);
    if (index != -1 && index > 0) {
      return mdSequence[index - 1];
    }
    return null;
  }
}

String toPlainText(String noteContent) {
  final mdlinkWithTextCapture = RegExp(r'\[([^\[]+)\](\([^\)]+\))');
  return noteContent.replaceAllMapped(mdlinkWithTextCapture, (match) => match.group(1)!);
}
