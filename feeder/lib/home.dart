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
        GetPage(name: '/feed', page: () => buildContent('2-55.md')),
        GetPage(name: '/chapters', page: () => const ChaptersWidget(key: Key('toc'))),
        GetPage(
            name: '/shloka/:mdFilename',
            page: () => Scaffold(body: buildContent(Get.parameters['mdFilename']!))),
        GetPage(
            name: '/shloka/:mdFilename/:noteId',
            page: () => Scaffold(
                body: buildContent(Get.parameters['mdFilename']!,
                    initialAnchor: Get.parameters['noteId']))),
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
