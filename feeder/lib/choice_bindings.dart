import 'package:get/get.dart';
import 'package:askys/choice_selector.dart';

class ChoiceBinding implements Bindings {
  @override
  void dependencies() {
    Get.put(Choices());
  }
}
