import 'package:askys/choice_selector.dart';
import 'package:flutter/material.dart';

Widget screenify(Widget body, {AppBar? appBar, Widget? choicesRow}) {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  return Scaffold(
    key: scaffoldKey,
    appBar: appBar,
    endDrawer: SafeArea(
        child: Drawer(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [themeSelector(), scriptSelector(), headerSelector()]))),
    body: SafeArea(child: body),
    bottomNavigationBar: choicesRow,
  );
}
