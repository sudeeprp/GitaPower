import 'package:get/get.dart';
import 'package:dio/dio.dart';

class MDContent extends GetxController {
  final String mdFilename;
  var mdContent = ''.obs;
  MDContent(this.mdFilename);
  @override
  void onInit() async {
    final md = await Dio().get('https://raw.githubusercontent.com/RaPaLearning/gita-begin/main/gita/$mdFilename');
    mdContent.value = md.data.toString();
    super.onInit();
  }
}
