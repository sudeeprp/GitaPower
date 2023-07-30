import 'package:askys/notes_widget.dart';
import 'package:askys/varchas_widgets/chapters_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:askys/choice_selector.dart';
import 'package:askys/choice_bindings.dart';
import 'package:askys/content_widget.dart';
import 'package:askys/begin_widget.dart';
import 'package:askys/feed_widget.dart';

Widget screenify(Widget body, {AppBar? appBar}) {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  return Scaffold(
      key: scaffoldKey,
      appBar: appBar,
      endDrawer: const SafeArea(
          child: Drawer(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [ThemeSelector(), ScriptSelector()]))),
      body: SafeArea(
        child: Stack(children: [
          body,
          Positioned(
              bottom: 0,
              right: 0,
              child: GestureDetector(
                  onTap: () => scaffoldKey.currentState?.openEndDrawer(),
                  child: const Icon(key: Key('home/settingsicon'), Icons.settings))),
        ]),
      ));
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
        GetPage(name: '/chapters', page: () => screenify(const ChaptersWidgetTest(key: Key('toc')))),
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
  const Home({Key? key}) : super(key: key);

  @override
  Widget build(context) {
    return screenify(const BeginWidget(),
        appBar: AppBar(
            leading: Image.asset('images/sunidhi-krishna.png'),
            title: const Text("Krishna's Gita")));
  }
}
