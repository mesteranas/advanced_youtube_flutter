import 'package:path_provider/path_provider.dart' as path_bro;
import 'dart:convert';
import 'dart:io';

Future<Map<String, dynamic>> getHistory() async {
  Directory systemDIR = await path_bro.getApplicationDocumentsDirectory();
  File file = File("${systemDIR.path}/history.json");

  if (await file.exists()) {
    final data = await file.readAsString();
    Map<String,dynamic> dartData = jsonDecode(data);
    return dartData;
  } else {
    return {"history":[]};
  }
}

Future<void> saveHistory(var object) async {
  Directory systemDIR = await path_bro.getApplicationDocumentsDirectory();
  File file = File("${systemDIR.path}/history.json");
  String data = jsonEncode(object);
  await file.writeAsString(data);
}
Future<int> getPosition(String title,String videoID) async{
var data=await getHistory();
for (var video in data["history"]){
  if (video["title"]==title&&video["videoId"]==videoID){
    return video["position"];
  } else{
    continue;
  }

}
data["history"].add({"title":title,"videoId":videoID,"position":0});
await saveHistory(data);
return 0;
}
Future<void> savePosition(String title,String videoID,int position) async{
var data=await getHistory();
for (var video in data["history"]){
  if (video["title"]==title&&video["videoId"]==videoID){
    video["position"]=position;
    break;
  } else{
    continue;
  }

}
await saveHistory(data);

}
