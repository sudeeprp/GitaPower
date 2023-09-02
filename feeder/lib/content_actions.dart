import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ContentActions extends GetxController {
  var actionsVisible = false.obs;

  void showForAWhile() {
    actionsVisible.value = true;
    const actionHideInSecs = int.fromEnvironment('actionHideInSecs', defaultValue: 4);
    hideAfterAWhile(actionHideInSecs);
  }

  void hideAfterAWhile(int actionHideInSecs) {
    if (actionHideInSecs > 0) {
      Future.delayed(Duration(seconds: actionHideInSecs), () => actionsVisible.value = false);
    }
  }
}

List<Widget> navigationButtons(
    BuildContext context, String thismd, String? nextmd, String? prevmd) {
  final ContentActions contentActions = Get.find(tag: thismd);
  Widget makeNavigator(Alignment alignment, String? targetMdFilename, IconData icon) =>
      Obx(() => Visibility(
          visible: contentActions.actionsVisible.value == true && targetMdFilename != null,
          child: Align(
              alignment: alignment,
              child: FloatingActionButton(
                onPressed: () => Get.offNamed('/shloka/$targetMdFilename'),
                heroTag:
                    'nextBtn${String.fromCharCodes(List.generate(5, (index) => Random().nextInt(33) + 89))}',
                mini: true,
                backgroundColor: Theme.of(context).colorScheme.background.withOpacity(0.5),
                child: Icon(icon),
              ))));
  return [
    makeNavigator(Alignment.centerRight, nextmd, Icons.navigate_next),
    makeNavigator(Alignment.centerLeft, prevmd, Icons.navigate_before),
  ];
}
