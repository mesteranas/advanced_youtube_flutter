
import 'package:shared_preferences/shared_preferences.dart';
class Handler{
  static Future <dynamic> get(String type,String key) async{
    final perfs=await SharedPreferences.getInstance();
    var result;
    if (type=="string") {
      result=perfs.getString(key)??"";
    } else if(type=="int"){
      result=perfs.getInt(key)??0;
    } else if(type=="bool"){
      result=perfs.getBool(key)??true;
    } else if(type=="double"){
      result=perfs.getDouble(key)??0.0;
    }
    return result;
  }
  static Future <void> set(String type,String key,dynamic value) async{
    final perfs=await SharedPreferences.getInstance();
    if (type=="string") {
      await perfs.setString(key,value);
    } else if(type=="int"){
      await perfs.setInt(key,value);
    } else if(type=="bool"){
      await perfs.setBool(key,value);
    } else if(type=="double"){
      await perfs.setDouble(key,value);
    }

  }
}