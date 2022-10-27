import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:card_settings/card_settings.dart';

enum Theme {
  dark,
  light,
  classic,
}

class Settings extends GetxController {
  var theme = Theme.classic.obs;
  var count = 0.obs;
  increment() => count++;
}

class PickerModel {
  const PickerModel(this.name, {this.code, this.icon});
  final String name;
  final Object? code;
  final Icon? icon;

  @override
  String toString() => name;
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(context) {
    const pickerItems = <PickerModel>[
                    PickerModel('Earth', code: 'E', icon: Icon(Icons.abc)),
                    PickerModel('Unicorn', code: 'U', icon: Icon(Icons.ac_unit)),
                  ];
    final Settings s = Get.find();
    return Scaffold(body: Form(
        child: CardSettings(
          children: <CardSettingsSection>[
            CardSettingsSection(
              header: CardSettingsHeader(
                label: 'Appearance',
              ),
              children: <CardSettingsWidget>[
                CardSettingsText(
                  label: 'Title',
                  initialValue: 'title',
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Title is required.';
                  },
                  onSaved: (value) => print(value),
                ),
                CardSettingsSelectionPicker<PickerModel>(
                  label: 'Style',
                  initialItem: pickerItems[0],
                  hintText: 'Select One',
                  icon: const Icon(Icons.access_alarm),
                  // autovalidateMode: _autoValidateMode,
                  items: pickerItems,
                  iconizer: (item) => item.icon,
                  validator: (PickerModel? value) {
                    if (value == null || value.toString().isEmpty) {
                      return 'You must pick a style.';
                    }
                    return null;
                  },
                  onSaved: (value) => print(value),
                  onChanged: (value) => print(value),
                )
              ]
            )
          ]
        ),
    ));
  }
}
