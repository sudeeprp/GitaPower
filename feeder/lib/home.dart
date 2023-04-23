import 'package:askys/notes_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:askys/choice_selector.dart';
import 'package:askys/choice_bindings.dart';
import 'package:askys/content_widget.dart';
import 'package:askys/begin_widget.dart';
import 'package:askys/chapters_widget.dart';
import 'package:askys/feed_widget.dart';

Widget screenify(Widget body) {
  return Scaffold(body: SafeArea(child: body));
}

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
            name: '/shloka/:mdFilename',
            page: () => screenify(buildContent(Get.parameters['mdFilename']!))),
        GetPage(
            name: '/shloka/:mdFilename/:noteId',
            page: () => screenify(buildContent(Get.parameters['mdFilename']!,
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
