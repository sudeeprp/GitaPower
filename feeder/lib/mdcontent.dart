import 'package:get/get.dart';

class MDContent extends GetxController {
  var mdContent = ''.obs;

  @override
  void onInit() {
    super.onInit();
    mdContent.value = '''
## 2-54

```shloka-sa

अर्जुन उवाच -
स्थितप्रज्ञस्य का भाषा समाधिस्थस्य केशव ।
स्थितधीः किम् प्रभाषेत किमासीत व्रजेत किम् ॥ ५४ ॥

```
```shloka-sa-hk

arjuna uvAca -
sthitaprajJasya kA bhASA samAdhisthasya kezava |
sthitadhIH kim prabhASeta kimAsIta vrajeta kim || 54 ||

```
`अर्जुन उवाच` `[arjuna uvAca]` Arjuna said- `केशव` `[kezava]` ‘O Krishna, `भाषा का` `[bhASA kA]` what words can be used for the description `स्थितप्रज्ञस्य` `[sthitaprajJasya]` of a person who stands firm in wisdom, `समाधिस्थस्य` `[samAdhisthasya]` who has attained control over his mind? `स्थितधीः` `[sthitadhIH]` Being unmoved, `किम् प्रभाषेत` `[kim prabhASeta]` what does he speak? `किम्` `[kim]` How does he `आसीत` `[AsIta]` be? `किम् व्रजेत` `[kim vrajeta]` What does he do?’

To describe someone standing 
[firm in wisdom](sthitaprajna_xlat)
 is to realize the characteristics of that person. What does such a person do, what does he speak, how does he behave?

While describing this person’s special state of being, the Lord explains the qualities of such a person and the way to get there. The Lord describes this state of being next.
''';
  }
}
