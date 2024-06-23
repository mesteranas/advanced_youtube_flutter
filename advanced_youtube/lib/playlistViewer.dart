import 'mediaPlayerViewDialogForUrls.dart';
import 'package:flutter_share/flutter_share.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import '../app.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import '../language.dart';
class Playlistviewer extends StatefulWidget{
  var q="";
  Playlistviewer({Key?key,required this.q}):super(key:key);
  @override
  State<Playlistviewer> createState()=>_Playlistviewer(q);
}
class _Playlistviewer extends State<Playlistviewer>{
  var nextPageId="";
  var loading=true;
  var results={};
  var _=Language.translate;
  var q="";
  _Playlistviewer(this.q);
  Future<void> load() async{
    String url="";
    if (nextPageId.isEmpty){
      url='https://www.googleapis.com/youtube/v3/playlistItems?part=snippet&playlistId=' + this.q + '&maxResults=100&key=' + App.apiKey;
    }else{
      url='https://www.googleapis.com/youtube/v3/playlistItems?part=snippet&playlistId=' + this.q + '&maxResults=100&key=' + App.apiKey + '&pageToken=' + nextPageId;
    }
    var responce=await http.get(Uri.parse(url));
    if (responce.statusCode==200){
      var data=jsonDecode(responce.body);
      nextPageId=data["nextPageToken"].toString();
      for ( var video in data["items"]){

        results[video["snippet"]["title"].toString() + _(" by ") + video["snippet"]["channelTitle"].toString()]="https://www.youtube.com/watch?v=" + video["snippet"]["resourceId"]["videoId"].toString();
      }
      setState(() {
        loading=false;
      });
    }

  }
  void initState(){
    super.initState();
    load();
  }
  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Text(_("playlist")),
        actions: [
          IconButton(onPressed: (){
            load();
          }, icon: Icon(Icons.more),tooltip: _("show more"),)
        ],
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