import 'package:flutter/material.dart';

Widget screenify(Widget body, {AppBar? appBar, Widget? choicesRow}) {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  return Scaffold(
    key: scaffoldKey,
    appBar: appBar,
    body: SafeArea(child: ConstrainedBox(constraints: BoxConstraints(maxWidth: 700), child: body)),
    bottomNavigationBar: choicesRow,
  );
}
