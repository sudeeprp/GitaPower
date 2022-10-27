import 'package:get/get.dart';
import 'package:askys/settings_screen.dart';
import 'package:askys/choice_selector.dart';

class ChoiceBinding implements Bindings {
  @override
  void dependencies() {
    print('-- dependencies');
    Get.put(Settings());
    Get.put(Choices());
  }
}
