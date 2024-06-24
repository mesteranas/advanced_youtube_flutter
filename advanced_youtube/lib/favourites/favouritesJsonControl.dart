import 'package:path_provider/path_provider.dart' as path_bro;
import 'dart:convert';
import 'dart:io';

Future<Map<String, dynamic>> getFavourites() async {
  Directory systemDIR = await path_bro.getApplicationDocumentsDirectory();
  File file = File("${systemDIR.path}/favourites.json");

  if (await file.exists()) {
    final data = await file.readAsString();
    Map<String,dynamic> dartData = jsonDecode(data);
    return dartData;
  } else {
    return {"videos":[],"playlists":[],"channels":[]};
  }
}

Future<void> saveFavourites(Map<String, dynamic > object) async {
  Directory systemDIR = await path_bro.getApplicationDocumentsDirectory();
  File file = File("${systemDIR.path}/favourites.json");
  String data = jsonEncode(object);
  await file.writeAsString(data);
}
Future<dynamic> check(int type,String title,String channelID) async{
var types={0:"videos",1:"playlists",2:"channels"};
var data=await getFavourites();
var currentType=types[type];
for (var video in data[currentType]){
  if (video["title"]==title&&video["channelId"]==channelID){
    return true;
  } else{
    continue;
  }

}
return false;
}
Future<void> addFavourite(int type,String title,String channelID,String id) async{
 var types={0:"videos",1:"playlists",2:"channels"};
var data=await getFavourites();
 data[types[type]].add({"title":title,"channelId":channelID,"id":id});
 await saveFavourites(data);
}
Future<void> removeFromFavourite(int type,String title,String channelID) async{
  var types={0:"videos",1:"playlists",2:"channels"};
var data=await getFavourites();
var currentType=types[type];
for (var video in data[currentType]){
  if (video["title"]==title&&video["channelId"]==channelID){
    data[currentType].remove(video);
    await saveFavourites(data);
    break;
  } else{
    continue;
  }

}

}