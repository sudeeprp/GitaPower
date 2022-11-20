import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:askys/choice_bindings.dart';
import 'package:askys/home.dart';

void main() =>
    runApp(GetMaterialApp(initialBinding: ChoiceBinding(), home: const Home()));
