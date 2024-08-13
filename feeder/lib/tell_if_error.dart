import 'package:just_audio/just_audio.dart';
import 'package:get/get.dart';

Future<void> tellIfError(Future<void> Function() func,
    {Duration durationToShow = const Duration(seconds: 3)}) async {
  try {
    return await func();
  } on PlayerException catch (e) {
    Get.snackbar('Oops', e.message ?? 'Error in playing', duration: durationToShow);
  } on PlayerInterruptedException catch (e) {
    Get.snackbar('Oops', e.message ?? 'Interruption', duration: durationToShow);
  } catch (e) {
    Get.snackbar('Oops', 'Something went wrong', duration: durationToShow);
  }
}
