import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:askys/settings_screen.dart';
import 'package:askys/choice_selector.dart';
import 'package:askys/choice_bindings.dart';

void main() => runApp(GetMaterialApp(initialBinding: ChoiceBinding(), home: const Home()));

class Home extends StatelessWidget {
  const Home({Key? key}) : super(key: key);

  @override
  Widget build(context) {

    final Settings s = Get.find();

    return Scaffold(
      // Use Obx(()=> to update Text() whenever count is changed.
      appBar: AppBar(
        leading: const Icon(Icons.account_circle_rounded),
        title: Obx(() => Text("Clicks: ${s.count}")),
        actions: [GestureDetector(
          onTap: () => Get.to(() => const SettingsScreen()),
          child: const Icon(Icons.settings)
        )],
      ),

      body: Center(child: ElevatedButton(
              child: const Text("Go to Choices"), onPressed: () => Get.to(() => ChoiceSelector()))),
      floatingActionButton:
          FloatingActionButton(onPressed: s.increment, child: const Icon(Icons.add)));
  }
}
