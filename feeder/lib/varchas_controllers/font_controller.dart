import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class FontController extends GetxController {
  final fontSize = 18.0.obs;
  final currentFontTheme = GoogleFonts.roboto().fontFamily.obs;
  final fontFamilies = {
    'Roboto': GoogleFonts.roboto().fontFamily,
    'Open Sans': GoogleFonts.openSans().fontFamily,
    'Montserrat': GoogleFonts.montserrat().fontFamily,
    'Lato': GoogleFonts.lato().fontFamily
  };
  final currentFont = 'Roboto'.obs;
  final fontHeights = {'default': 1.5, 'more': 2.0, 'less': 1.1};
  final currentFontHeight = 1.5.obs;
  void increaseFontSize() {
    fontSize(fontSize.value + 1);
  }

  void decreaseFontSize() {
    fontSize(fontSize.value - 1);
  }

  void updateFontFamily(String fontFamily) {
    currentFontTheme(fontFamilies[fontFamily]);
    currentFont(fontFamily);
  }

  void updateFontHeight(String fontHeight) {
    currentFontHeight(fontHeights[fontHeight]);
  }
}
