import 'package:dio/dio.dart';
import 'package:get/get.dart';

class GitHubFetcher extends GetxController {
  final Dio dio;
  GitHubFetcher(this.dio);

  static const mdPath = 'https://raw.githubusercontent.com/RaPaLearning/gita-begin/main/gita';
  Future<String> mdString(String mdFilename) async {
    final md = await dio.get('$mdPath/$mdFilename');
    return md.data.toString();
  }

  static const compiledPath =
      'https://raw.githubusercontent.com/RaPaLearning/gita-begin/main/compile';
  Future<String> compiledAsString(String jsonFilename) async {
    final jsonContent = await dio.get('$compiledPath/$jsonFilename');
    return jsonContent.data.toString();
  }
}
