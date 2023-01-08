import 'package:get/get.dart';

class Chapter {
  Chapter(this.title, this.shokas);
  String title;
  List<String> shokas;
}

class ChaptersTOC extends GetxController {
  final chapters = [
    Chapter('Chapter 1', ['1-1 to 1-19', '1-20 to 1-35']),
    Chapter('Chapter 2', ['2-1', '2-2 to 2-4']),
  ];
  @override
  void onInit() {
    super.onInit();
  }
}
