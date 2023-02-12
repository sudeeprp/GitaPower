import 'package:get/get.dart';
import 'package:askys/content_source.dart';

class MDContent extends GetxController {
  final String mdFilename;
  var mdContent = ''.obs;
  MDContent(this.mdFilename);
  @override
  void onInit() async {
    final GitHubFetcher contentSource = Get.find();
    mdContent.value = await contentSource.mdString(mdFilename);
    super.onInit();
  }
}
