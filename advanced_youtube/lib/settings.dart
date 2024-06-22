import 'dart:async';

import 'package:flutter/material.dart';
import 'settings_handler.dart';
import 'language.dart';
class SettingsDialog extends StatefulWidget{
  var translate;
  SettingsDialog(this.translate);
  @override
  State<SettingsDialog> createState()=>_Settings(translate);

}
class _Settings extends State<SettingsDialog>{
  var _;
  String currentLanguage="en";
  _Settings(this._);
  void initState() {
    super.initState();
    loadSettings();
  }
  Future <void> loadSettings() async{
    String LanguageCode=await Language.getCurrentLanguage();
    setState(() {
      currentLanguage=LanguageCode;
    });
  }
  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(title: Text(this._("settings")),),
      body: Center(
        child: Column(
          children: [
            Text(this._("general settings")),
            ListTile(title: Text(this._("language")),),
            DropdownButton(value: currentLanguage
            ,hint: Text(this._("language") )
            ,icon: Icon(Icons.language)
            ,items: 
            Language.supportedLanguages.entries.map((entery){
              return DropdownMenuItem<String>(child: Text(entery.key),value: entery.value,);
            } ).toList()
            , onChanged: (value) async{
    await Handler.set("string","language",value);
    Language.runTranslation();
    setState(() {
      currentLanguage=value??"en";
    });
  },
  )
          ],
        ),
      ),
    );
  }
}