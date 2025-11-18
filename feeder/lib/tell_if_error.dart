import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:get/get.dart';

Future<void> callAndTellIfError(Future<void> Function() func,
    {Duration durationToShow = const Duration(seconds: 3)}) async {
  void showError(String message) {
    ScaffoldMessenger.of(Get.context!)
        .showSnackBar(SnackBar(content: Text(message), duration: durationToShow));
  }

  try {
    return await func();
  } on PlayerException catch (e) {
    showError(e.message ?? 'Error in playing');
  } on PlayerInterruptedException catch (e) {
    showError(e.message ?? 'Interruption');
  } catch (e) {
    showError('Something went wrong');
  }
}
