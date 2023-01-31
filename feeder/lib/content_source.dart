import 'package:dio/dio.dart';
import 'package:get/get.dart';

class GitHubFetcher extends GetxController {
  final Dio dio;
  GitHubFetcher(this.dio);
  Future<String> mdString(String mdFilename) async {
    final md = await dio.get(
        'https://raw.githubusercontent.com/RaPaLearning/gita-begin/main/gita/$mdFilename');
    return md.data.toString();
  }

  Future<String> compiledAsString(String jsonFilename) async {
    final jsonContent = await dio.get(
        'https://raw.githubusercontent.com/RaPaLearning/gita-begin/main/compile/$jsonFilename');
    return jsonContent.data.toString();
  }
}
