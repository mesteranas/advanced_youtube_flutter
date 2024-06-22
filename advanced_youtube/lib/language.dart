import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
class Language {
  static var languageCode;
  static Map<String,dynamic> labels={};
  static var supportedLanguages={"english":"en","arabic":"ar"};


  static Future<void> runTranslation() async {
    labels={};
    await getCurrentLanguage();
    try {
      var data = await rootBundle.loadString('assets/i18n/$languageCode.json');
      labels= jsonDecode(data);
    } catch (error) {
      print("Error loading language file: $error");
      labels= {};

  }
  }
  static String translate(String text){
    try{
      return labels[text];
    } catch(error){
      return text;
    }
  }
  static Future <String> getCurrentLanguage() async{
    final berfs=await SharedPreferences.getInstance();
    languageCode=berfs.getString("language")??"en";
    return languageCode;
  }

}