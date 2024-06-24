import 'package:flutter_share/flutter_share.dart';
import 'package:flutter/services.dart';
import 'package:test/history/historyJsonControl.dart';
import 'package:test/mediaPlayerViewDialogForUrls.dart';
import 'dart:convert';
import '../app.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import '../language.dart';
class HistoryGUI extends StatefulWidget{

  HistoryGUI({Key?key}):super(key:key);
  @override
  State<HistoryGUI> createState()=>_HistoryGUI();
}
class _HistoryGUI extends State<HistoryGUI>{
  var loading=true;
  var results={};
  var _=Language.translate;
  Future<void> load() async{
    var data=await getHistory();
      for ( var video in data["history"]){

        results[video["title"].toString()]="https://www.youtube.com/watch?v=" + video["videoId"].toString();
      }
      setState(() {
        loading=false;
      });
  }
  void initState(){
    super.initState();
    load();
  }
  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Text(_("watch history")),
      ),
      body: Center(
        child:
        !loading
        ? ListView.builder(itemBuilder:(context,index){
          var resultsKeys=results.keys.toList();
          return ListTile(title: Text(resultsKeys[index]),
          onLongPress:(){
            showDialog(context: context, builder: (context){
              return AlertDialog(
                title: Text(_("video options")),
                actions: [
                  IconButton(onPressed: (){
                    Clipboard.setData(ClipboardData(text: results[resultsKeys[index]]));
                    Navigator.pop(context);
                  }, icon: Icon(Icons.copy),tooltip: _("copy link"),),
                  IconButton(onPressed: (){
                    FlutterShare.share(title: "share",text: results[resultsKeys[index]]);
                    Navigator.pop(context);
                  }, icon: Icon(Icons.share),tooltip: _("share link"),),
                ],
              );
            });
          } ,
          onTap: (){
          Navigator.push(context, MaterialPageRoute(builder: (context)=>MediaPlayerURLViewer(filePath: results[resultsKeys[index]])));
          },);
        } ) 
      : Text(_("loading ..."))
      ),

    );
  }
}