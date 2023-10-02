import 'package:askys/notes_widget.dart';
import 'package:askys/varchas_controllers/font_controller.dart';
import 'package:askys/varchas_widgets/chapters_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:askys/choice_selector.dart';
import 'package:askys/choice_bindings.dart';
import 'package:askys/content_widget.dart';
import 'package:askys/begin_widget.dart';
import 'package:askys/feed_widget.dart';

double fontSize = 16;
Widget screenify(Widget body, {AppBar? appBar}) {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  return Scaffold(
      key: scaffoldKey,
      appBar: appBar,
      endDrawer: SafeArea(
          child: Drawer(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
            themeSelector(),
            scriptSelector(),
            headerSelector()
          ]))),
      body: SafeArea(
        child: Stack(children: [
          body,
          Positioned(
              bottom: 0,
              right: 0,
              child: GestureDetector(
                  onTap: () => scaffoldKey.currentState?.openEndDrawer(),
                  child: const Icon(
                      key: Key('home/settingsicon'), Icons.settings))),
        ]),
      ));
}

Widget makeMyHome() {
  final FontController fontController = Get.put(FontController());
  return Obx(() => GetMaterialApp(
          title: 'The Gita',
          initialBinding: ChoiceBinding(),
          theme: ThemeData.light().copyWith(
            colorScheme: ColorScheme(
                brightness: Brightness.light,
                primary: ThemeData.light().colorScheme.primary,
                onPrimary: ThemeData.light().colorScheme.onPrimary,
                secondary: ThemeData.light().colorScheme.secondary,
                onSecondary: const Color(0xFF800000),
                error: ThemeData.light().colorScheme.error,
                onError: ThemeData.light().colorScheme.onError,
                background: ThemeData.light().colorScheme.background,
                onBackground: const Color.fromARGB(255, 130, 0, 134),
                surface: ThemeData.light().colorScheme.surface,
                onSurface: Colors.black,
                onPrimaryContainer: Colors.white,
                onSecondaryContainer: Colors.black),
            textTheme: ThemeData.light().textTheme.apply(
                fontFamily: fontController.currentFontTheme.value,
                bodyColor: Colors.black),
          ),
          darkTheme: ThemeData.dark().copyWith(
            colorScheme: ColorScheme(
                brightness: Brightness.dark,
                primary: ThemeData.dark().colorScheme.primary,
                onPrimary: Colors.white,
                secondary: const Color.fromARGB(255, 154, 92, 0),
                onSecondary: const Color.fromARGB(255, 236, 118, 82),
                error: ThemeData.dark().colorScheme.error,
                onError: ThemeData.dark().colorScheme.onError,
                background: ThemeData.dark().colorScheme.background,
                onBackground: Colors.cyan,
                surface: ThemeData.dark().colorScheme.surface,
                onSurface: const Color.fromARGB(255, 236, 118, 82),
                onPrimaryContainer: const Color.fromARGB(255, 236, 118, 82),
                onSecondaryContainer: Colors.white),
            textTheme: ThemeData.dark().textTheme.apply(
                fontFamily: fontController.currentFontTheme.value,
                bodyColor: Colors.white),
          ),
          home: const Home(),
          getPages: [
            GetPage(name: '/notes', page: () => screenify(const NotesWidget())),
            GetPage(name: '/feed', page: () => screenify(buildFeed())),
            GetPage(
                name: '/chapters',
                page: () =>
                    screenify(const ChaptersWidgetTest(key: Key('toc')))),
            GetPage(
                name: '/shloka/:mdFilename',
                page: () => screenify(
                    buildContentWithNote(Get.parameters['mdFilename']!))),
            GetPage(
                name: '/shloka/:mdFilename/:noteId',
                page: () => screenify(buildContentWithNote(
                    Get.parameters['mdFilename']!,
                    initialAnchor: Get.parameters['noteId']))),
          ]));
}

class Home extends StatelessWidget {
  const Home({Key? key}) : super(key: key);

  @override
  Widget build(context) {
    return screenify(const BeginWidget(),
        appBar: AppBar(
          leading: Image.asset('images/sunidhi-krishna.png'),
          title: const Text("Krishna's Gita"),
          actions: [
            IconButton(
                onPressed: () {
                  Get.changeThemeMode(
                    Get.isDarkMode ? ThemeMode.light : ThemeMode.dark,
                  );
                },
                icon: const Icon(Icons.brightness_6))
          ],
        ));
  }
}
