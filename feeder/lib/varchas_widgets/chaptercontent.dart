import 'package:askys/chaptercontent.dart';
import 'package:askys/choice_selector.dart';
import 'package:askys/varchas_controllers/font_controller.dart';
import 'package:askys/varchas_widgets/form_shloka_title.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


class ChapterContentTest extends StatefulWidget {
  const ChapterContentTest(
      {super.key, required this.chapter, required this.title});
  final Chapter chapter;
  final String title;

  @override
  State<ChapterContentTest> createState() => _ChapterContentTestState();
}

class _ChapterContentTestState extends State<ChapterContentTest> {
  String _currentLang="sanskrit";
  final FontController fontController = Get.put(FontController());
  @override
  void initState() {
    
    super.initState();
  }

  void _setEng() {
      setState(() {
        _currentLang = "eng";
      });
      

  }
  void _setSanskrit(){
      setState(() {
        _currentLang = "sanskrit";
      });
      
  }

  void _fontPicker() {
    showModalBottomSheet(
      useSafeArea: true,
      isScrollControlled: true,
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) {
        // return LayoutBuilder(builder: (context, constraints) {
        return SizedBox(
          height: 200,
          child: ListView(children: [
            Stack(
              children: [
              IconButton(onPressed: (){Navigator.pop(context);}, icon: const Icon(Icons.arrow_back),alignment: Alignment.centerLeft),
              const Center(child: Padding(
                padding: EdgeInsets.only(top:14.0),
                child: Text("Font Family",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 15)),
              )),

            ],),
            SizedBox(height: 35,child: TextButton(onPressed: (){fontController.updateFontFamily('Roboto');Navigator.pop(context);}, child: Text('Roboto',style: TextStyle(color: Theme.of(context).colorScheme.onSurface,),))),
            SizedBox(height: 35,child: TextButton(onPressed: (){fontController.updateFontFamily('Open Sans');Navigator.pop(context);}, child: Text('Open Sans',style: TextStyle(color: Theme.of(context).colorScheme.onSurface,),))),
            SizedBox(height: 35,child: TextButton(onPressed: (){fontController.updateFontFamily('Montserrat');Navigator.pop(context);}, child: Text('Montserrat',style: TextStyle(color: Theme.of(context).colorScheme.onSurface,),))),
            SizedBox(height: 35,child: TextButton(onPressed: (){fontController.updateFontFamily('Lato');Navigator.pop(context);}, child: Text('Lato',style: TextStyle(color: Theme.of(context).colorScheme.onSurface,),))),
          ],),
        );
      },);

  }
  void _formatFont() {
    showModalBottomSheet(
      useSafeArea: true,
      isScrollControlled: true,
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) {

        return SizedBox(
          height: 250,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                const Row(
                  children: [
                    Text("Font size",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 15)),
                    Spacer(),
                    Text("Font family",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 15))
                  ],
                ),
                
                Row(
                  children: [
                    OutlinedButton(onPressed: (){fontController.increaseFontSize();}, child: Image.asset('images/icons8-increase-font-24.png',color: Theme.of(context).colorScheme.onSurface,)),
                    OutlinedButton(onPressed: (){fontController.decreaseFontSize();}, child: Image.asset('images/icons8-decrease-font-24.png',color: Theme.of(context).colorScheme.onSurface,)),
                    Expanded(child: OutlinedButton(onPressed: _fontPicker, child:Text(fontController.currentFont.value,style: TextStyle(color: Theme.of(context).colorScheme.onSurface,),)))
                  ],
                ),
                const Text("Line Spacing",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 15)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    OutlinedButton(onPressed: (){fontController.updateFontHeight('more');}, child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Image.asset('images/line_spacing_more.png',color: Theme.of(context).colorScheme.onSurface,height: 40,),
                    )),
                    OutlinedButton(onPressed: (){fontController.updateFontHeight('default');}, child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Image.asset('images/line_spacing_default.png',color: Theme.of(context).colorScheme.onSurface,height: 40),
                    )),
                    OutlinedButton(onPressed: (){fontController.updateFontHeight('less');}, child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Image.asset('images/line_spacing_less.png',color: Theme.of(context).colorScheme.onSurface,height: 40),
                    )),
                  ],
                ),
                const Text("Language",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 15)),
      
                
                Row(children: [Expanded(child: OutlinedButton(onPressed: _setEng, child: Text("English",style: TextStyle(color: Theme.of(context).colorScheme.onSurface,),))),
                    Expanded(child: OutlinedButton(onPressed: _setSanskrit, child: Text("Sanskrit",style: TextStyle(color: Theme.of(context).colorScheme.onSurface,),))),],)
              ],
            ),
          ),
        );
      },);

  }
  @override
  Widget build(BuildContext context) {
    return 
      Scaffold(
          appBar: AppBar(
            title: Text(widget.title),
            actions: [
              IconButton(onPressed: _formatFont, icon: Image.asset('images/icons8-font-size-24.png',color: Theme.of(context).colorScheme.onPrimary,))
            ],
          ),
          body: ListView.builder(
              itemCount: widget.chapter.shokas.length,
              itemBuilder: (ctx, index) {
                final mdFilename =
                    Chapter.titleToFilename(widget.chapter.shokas[index]);
                final Choices choices = Get.find();
                final codeColor = choices.codeColor.value;
                return Obx(() =>  ListTile(
                  title: FormShlokaTitle(widget.chapter.shokas[index],
                      mdFilename, codeColor,_currentLang,fontController.fontSize.value),
                  onTap: () => Get.toNamed('/shloka/$mdFilename'),
                ));
              }));
   
  }
}
