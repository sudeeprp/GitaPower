import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:askys/choice_selector.dart';

class Home extends StatelessWidget {
  const Home({Key? key}) : super(key: key);

  @override
  Widget build(context) {
    return Scaffold(
      appBar: AppBar(
        leading: const Icon(Icons.account_circle_rounded),
        title: const Text("Under implementation"),
        actions: [
          GestureDetector(
              onTap: () => Get.to(() => const ChoiceSelector()),
              child: const Icon(Icons.settings))
        ],
      ),
      body: Center(
          child: ElevatedButton(
              child: const Text("Go to Choices"),
              onPressed: () => Get.to(() => const ChoiceSelector()))),
    );
  }
}
