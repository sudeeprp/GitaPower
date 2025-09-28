import 'package:askys/build_ident_widget.dart';
import 'package:askys/choice_selector.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PersonalWidget extends StatelessWidget {
  const PersonalWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final Choices choices = Get.find();
    return SingleChildScrollView(
        child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BuildIdentWidget(),
        Divider(height: 16, indent: 16),
        buildEnumSelector<ReadingTheme>(
          title: 'What\'s your reading mode?',
          values: ReadingTheme.values,
          groupValue: choices.theme,
          displayText: (theme) => theme == ReadingTheme.dark ? 'Dark Theme' : 'Light Theme',
        ),
        SizedBox(height: 16),
        buildEnumSelector<ScriptPreference>(
          title: 'How do you read Sanskrit text?',
          values: ScriptPreference.values,
          groupValue: choices.script,
          displayText: (script) => script == ScriptPreference.devanagari ? 'Devanagari (धर्म, कर्म)' : 'Harvard-Kyoto (dharma, karma)',
        ),
        SizedBox(height: 16),
        buildEnumSelector<HeadPreference>(
          title: 'How do you read Shlokas?',
          values: HeadPreference.values,
          groupValue: choices.headPreference,
          displayText: (headPref) => headPref == HeadPreference.shloka ? 'Original source' : 'Translation',
        ),
      ],
    ));
  }

  Widget buildEnumSelector<T>({
    required String title,
    required List<T> values,
    required Rx<T> groupValue,
    required String Function(T) displayText,
  }) {
    return Obx(() => RadioGroup(
        groupValue: groupValue.value,
        onChanged: (T? newValue) {
          if (newValue != null) {
            groupValue.value = newValue;
          }
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
                padding: EdgeInsets.only(left: 16),
                child: Text(title, style: TextStyle(fontWeight: FontWeight.bold))),
            ...values.map((value) => RadioListTile<T>(
                  title: Text(displayText(value)),
                  value: value,
                )),
            Divider(height: 16, indent: 16),
          ],
        )));
  }
}
