import 'package:just_audio/just_audio.dart';
import 'package:get/get.dart';

Future<void> tellIfError(Future<void> Function() func) async {
  try {
    return func();
  } on PlayerException catch (e) {
    Get.snackbar('Oops', e.message ?? 'Error in playing');
  } on PlayerInterruptedException catch (e) {
    Get.snackbar('Oops', e.message ?? 'Interruption');
  } catch (e) {
    Get.snackbar('Oops', 'Something went wrong');
  }
}
