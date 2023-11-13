import 'package:askys/chapter_shloka_widget.dart';
import 'package:askys/notes_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:askys/choice_bindings.dart';
import 'package:askys/content_widget.dart';
import 'package:askys/begin_widget.dart';
import 'package:askys/chapters_widget.dart';
import 'package:askys/feed_widget.dart';
import 'package:askys/screenify.dart';

Widget makeMyHome() {
  return GetMaterialApp(
      title: 'The Gita',
      initialBinding: ChoiceBinding(),
      theme: ThemeData(brightness: Brightness.light),
      darkTheme: ThemeData(brightness: Brightness.dark),
      home: const Home(),
      getPages: [
        GetPage(name: '/notes', page: () => screenify(const NotesWidget())),
        GetPage(name: '/feed', page: () => screenify(buildFeed())),
        GetPage(name: '/chapters', page: () => screenify(const ChaptersWidget(key: Key('toc')))),
        GetPage(
            name: '/shlokaheaders/:chapter',
            page: () => chapterShlokaScreen(Get.parameters['chapter']!)),
        GetPage(
            name: '/shloka/:mdFilename',
            page: () => screenify(buildContentWithNote(Get.parameters['mdFilename']!))),
        GetPage(
            name: '/shloka/:mdFilename/:noteId',
            page: () => screenify(buildContentWithNote(Get.parameters['mdFilename']!,
                initialAnchor: Get.parameters['noteId']))),
      ]);
}

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(context) {
    return screenify(const BeginWidget(),
        appBar: AppBar(
            leading: Image.asset('images/sunidhi-krishna.png'),
            title: const Text("Krishna's Gita")));
  }
}
