import 'package:askys/choice_selector.dart';
import 'package:flutter/material.dart';

Widget screenify(Widget body, {AppBar? appBar}) {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  return Scaffold(
      key: scaffoldKey,
      appBar: appBar,
      endDrawer: SafeArea(
          child: Drawer(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [themeSelector(), scriptSelector(), headerSelector()]))),
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
