import 'package:flutter/material.dart';

Widget screenify(Widget body, {AppBar? appBar, Widget? choicesRow}) {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  return Scaffold(
    key: scaffoldKey,
    appBar: appBar,
    body: SafeArea(child: body),
    bottomNavigationBar: choicesRow,
  );
}
