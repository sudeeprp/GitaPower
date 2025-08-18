import 'package:askys/chaptercontent.dart';
import 'package:askys/choice_selector.dart';
import 'package:askys/content_source.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BrowseItem {
  BrowseItem(this.titleText, this.mdFilename);
  bool isVisible() => true;
  void enterItem() {}
  void expandItem() {
    enterItem();
  }

  int indentAt() => 0;
  double magFactor() => 1.0;

  String leadingPic() => '';
  String titleText;
  String mdFilename;
}

class ChapterEntry extends BrowseItem {
  ChapterEntry(super.titleText, super.mdFilename, this.choices);
  @override
  void enterItem() {
    Get.toNamed('/shlokaheaders/$mdFilename');
  }

  @override
  String leadingPic() => mdFilename.replaceFirst('.md', '.png');

  @override
  double magFactor() => choices.browsingPreference.value == BrowsingPreference.chapters ? 1 : 0.75;

  Choices choices;
}

class OpenerEntry extends BrowseItem {
  OpenerEntry(super.titleText, super.mdFilename, this.noteId, this.choices);
  @override
  void enterItem() {
    Get.toNamed('/shloka/$mdFilename/$noteId');
  }

  @override
  void expandItem() {
    isOpened.value = !isOpened.value;
  }

  @override
  String leadingPic() => isOpened.value ? 'one-step.png' : 'bothfeet.png';

  @override
  double magFactor() => choices.browsingPreference.value == BrowsingPreference.notes ? 1 : 0.75;

  String noteId;
  Choices choices;
  RxBool isOpened = RxBool(false);
}

class NoteEntry extends BrowseItem {
  NoteEntry(super.titleText, super.mdFilename, this.noteId, this.choices, {RxBool? isOpened})
      : isOpened = isOpened ?? RxBool(false);
  @override
  bool isVisible() => isOpened.value;
  @override
  void enterItem() {
    Get.toNamed('/shloka/$mdFilename/$noteId');
  }

  @override
  String leadingPic() {
    return noteId.codeUnitAt(noteId.length - 1) % 2 == 0 ? 'left-foot.png' : 'right-foot.png';
  }

  @override
  int indentAt() => 1;
  @override
  double magFactor() => 0.75;

  String noteId;
  Choices choices;
  RxBool isOpened;
}

class BrowseController extends GetxController {
  var browseItems = <BrowseItem>[].obs;

  List<BrowseItem> browseItemSequence(
    List<Map<String, List<String>>> mdToNoteIds,
    List<Map<String, String>> notesCompiled,
  ) {
    String textOfNote(String noteId) {
      return notesCompiled.firstWhere((note) => note['note_id'] == noteId)['text'] ?? '';
    }

    List<BrowseItem> itemSequence = [];
    OpenerEntry? currentOpener;
    Choices choices = Get.find();
    for (final mdToNoteIdEntry in mdToNoteIds) {
      final mdFilename = mdToNoteIdEntry.keys.first;
      if (!RegExp(r'^\d').hasMatch(mdFilename)) {
        // if not a digit, it has to be a chapter name
        itemSequence.add(ChapterEntry(Chapter.filenameToTitle(mdFilename), mdFilename, choices));
      }
      for (final noteId in mdToNoteIdEntry[mdFilename]!) {
        bool isOpener = noteId.contains('opener');
        if (isOpener) {
          final openerEntry = OpenerEntry(textOfNote(noteId), mdFilename, noteId, choices);
          itemSequence.add(openerEntry);
          currentOpener = openerEntry;
        } else {
          final noteEntry =
              NoteEntry(textOfNote(noteId), mdFilename, noteId, choices, isOpened: currentOpener?.isOpened);
          itemSequence.add(noteEntry);
        }
      }
    }
    return itemSequence;
  }

  @override
  Future<void> onInit() async {
    super.onInit();
    final GitHubFetcher fetcher = Get.find();
    final mdToNoteIds = await fetcher.mdToNoteIds();
    final notesCompiled = await fetcher.notesCompiled();
    browseItems.value = browseItemSequence(mdToNoteIds, notesCompiled);
  }
}

class BrowseToc extends StatelessWidget {
  const BrowseToc({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final controller = Get.find<BrowseController>();
      final List<ListTile> listTiles = [];
      for (final browseItem in controller.browseItems) {
        double picSize = browseItem.magFactor() * 24;
        if (browseItem.isVisible()) {
          listTiles.add(ListTile(
            leading: Padding(
              padding: EdgeInsetsGeometry.only(left: browseItem.indentAt() * 12),
              child: Image.asset('images/${browseItem.leadingPic()}', width: picSize, height: picSize),
            ),
            title: Text(browseItem.titleText, textScaler: TextScaler.linear(browseItem.magFactor())),
            trailing: GestureDetector(
                onTap: browseItem.enterItem,
                child: Padding(
                  padding: EdgeInsets.only(right: 24),
                  child: Icon(Icons.arrow_forward_rounded, size: picSize),
                )),
            contentPadding: const EdgeInsets.only(left: 6),
            onTap: browseItem.expandItem,
          ));
        }
      }
      return ListView(
        children: listTiles,
      );
    });
  }
}
