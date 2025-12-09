import 'package:flutter/material.dart';
import 'package:get/get.dart';

Widget screenify(Widget body, {AppBar? appBar, Widget? choicesRow}) {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  return Scaffold(
    key: scaffoldKey,
    appBar: appBar,
    body: SafeArea(child: ConstrainedBox(constraints: BoxConstraints(maxWidth: 700), child: body)),
    bottomNavigationBar: choicesRow != null ? _BottomBarWithPadding(child: choicesRow) : null,
  );
}

class _BottomBarWithPadding extends StatelessWidget {
  const _BottomBarWithPadding({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.viewPaddingOf(context).bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: bottomPadding),
      child: child,
    );
  }
}

Widget widgetToHome() {
  return GestureDetector(
    key: Key('choice/home'),
    onTap: () => Get.offAllNamed('/'),
    child: Semantics(label: 'Home', button: true, child: Icon(Icons.home, size: 32)),
  );
}
