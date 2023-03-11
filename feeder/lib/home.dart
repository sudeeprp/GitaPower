import 'package:askys/notes_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:askys/choice_selector.dart';
import 'package:askys/choice_bindings.dart';
import 'package:askys/content_widget.dart';
import 'package:askys/begin_widget.dart';
import 'package:askys/chapters_widget.dart';

Widget makeMyHome() {
  return GetMaterialApp(
      title: 'The Gita',
      initialBinding: ChoiceBinding(),
      theme: ThemeData(brightness: Brightness.light),
      darkTheme: ThemeData(brightness: Brightness.dark),
      home: const Home(),
      getPages: [
        GetPage(name: '/notes', page: () => const Scaffold(body: NotesWidget())),
        GetPage(name: '/feed', page: () => ContentWidget('2-55.md', null)),
        GetPage(name: '/chapters', page: () => const ChaptersWidget(key: Key('toc'))),
        GetPage(name: '/shloka', page: () => Scaffold(body: ContentWidget(Get.arguments, null))),
        GetPage(
            name: '/anote',
            page: () => Scaffold(
                body: ContentWidget(Get.arguments['mdFilename'], Get.arguments['noteId']))),
      ]);
}

class Home extends StatelessWidget {
  const Home({Key? key}) : super(key: key);

  @override
  Widget build(context) {
    return Scaffold(
      appBar: AppBar(
        leading: const Icon(Icons.account_circle_rounded),
        title: const Text("Under implementation"),
        actions: [
          GestureDetector(
              onTap: () => Get.to(() => const ChoiceSelector()),
              child: const Icon(Icons.settings, key: Key('home/settingsicon')))
        ],
      ),
      body: const BeginWidget(),
    );
  }
}
