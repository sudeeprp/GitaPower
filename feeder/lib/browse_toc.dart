import 'package:askys/chaptercontent.dart';
import 'package:askys/choice_selector.dart';
import 'package:askys/content_source.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

abstract class BrowseItem {
  BrowseItem(this.titleText, this.mdFilename);
  bool isVisible() => true;
  void enterItem();
  void expandItem() {
    enterItem();
  }

  int indentAt() => 0;
  double magFactor();
  double picSize() => magFactor() * 28;
  Key? navWidgetKey() => null;
  Widget leadingPic();
  String titleText;
  String mdFilename;
}

class ChapterEntry extends BrowseItem {
  ChapterEntry(super.titleText, super.mdFilename, this.choices);
  @override
  void enterItem() {
    Get.toNamed('/shlokaheaders/$mdFilename');
    choices.browsingPreference.value = BrowsingPreference.chapters;
  }

  Widget defaultImage(BuildContext context, Object error, StackTrace? stackTrace) {
    return Image.asset('images/sunidhi-krishna.png', width: picSize(), height: picSize());
  }

  @override
  Widget leadingPic() {
    return Image.asset(
      'images/${mdFilename.replaceFirst('.md', '.png')}',
      width: picSize(),
      height: picSize(),
      errorBuilder: defaultImage,
    );
  }

  @override
  double magFactor() => choices.browsingPreference.value == BrowsingPreference.chapters ? 1.2 : 0.75;

  Choices choices;
}

class OpenerEntry extends BrowseItem {
  OpenerEntry(super.titleText, super.mdFilename, this.noteId, this.choices);
  @override
  Key? navWidgetKey() => Key('opener_nav/$mdFilename/$noteId');

  @override
  void enterItem() {
    Get.toNamed('/shloka/$mdFilename/$noteId');
    choices.browsingPreference.value = BrowsingPreference.notes;
  }

  @override
  void expandItem() {
    isOpened.value = !isOpened.value;
    choices.browsingPreference.value = BrowsingPreference.notes;
  }

  @override
  Widget leadingPic() {
    return Image.asset(
      'images/${isOpened.value ? 'one-step.png' : 'bothfeet.png'}',
      width: picSize(),
      height: picSize(),
    );
  }

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
    choices.browsingPreference.value = BrowsingPreference.notes;
  }

  @override
  Widget leadingPic() {
    return Image.asset(
      'images/${noteId.codeUnitAt(noteId.length - 1) % 2 == 0 ? 'left-foot.png' : 'right-foot.png'}',
      width: picSize(),
      height: picSize(),
    );
  }

  @override
  int indentAt() => 1;
  @override
  double magFactor() => 0.8;

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
      return notesCompiled.firstWhere((note) => note['note_id'] == noteId,
              orElse: () => {'text': ''})['text'] ??
          '';
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
        if (browseItem.isVisible()) {
          listTiles.add(ListTile(
            leading: Padding(
              padding: EdgeInsets.only(left: browseItem.indentAt() * 12),
              child: browseItem.leadingPic(),
            ),
            title: Text(browseItem.titleText, textScaler: TextScaler.linear(browseItem.magFactor())),
            trailing: GestureDetector(
                onTap: browseItem.enterItem,
                child: Padding(
                  padding: EdgeInsets.only(right: 24),
                  child: Icon(Icons.arrow_forward_rounded,
                      key: browseItem.navWidgetKey(), size: browseItem.magFactor() * 24),
                )),
            contentPadding: const EdgeInsets.only(left: 6),
            onTap: browseItem.expandItem,
            visualDensity: browseItem.magFactor() < 1 ? VisualDensity(vertical: -4) : VisualDensity.standard,
          ));
        }
      }
      return ListView(
        children: listTiles,
      );
    });
  }
}
