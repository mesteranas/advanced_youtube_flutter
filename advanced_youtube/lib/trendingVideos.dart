import 'package:flutter_share/flutter_share.dart';
import 'package:flutter/services.dart';
import 'package:test/mediaPlayerViewDialogForUrls.dart';
import 'dart:convert';
import '../app.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import '../language.dart';
class TrendingVideos extends StatefulWidget{
  TrendingVideos({Key?key}):super(key:key);
  @override
  State<TrendingVideos> createState()=>_TrendingVideos();
}
class _TrendingVideos extends State<TrendingVideos>{
  var nextPageId="";
  var loading=true;
  var results={};
  var _=Language.translate;
  Future<void> load() async {
    String url = "";
    if (nextPageId.isEmpty) {
      url =
          'https://www.googleapis.com/youtube/v3/videos?part=snippet,contentDetails,statistics&chart=mostPopular&type=video&maxResults=50&key=${App.apiKey}';
    } else {
      url =
          'https://www.googleapis.com/youtube/v3/videos?part=snippet,contentDetails,statistics&chart=mostPopular&type=video&maxResults=50&key=${App.apiKey}&pageToken=$nextPageId';
    }

    var response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      nextPageId = data["nextPageToken"] ?? "";
      for (var video in data["items"]) {
        results[
            "${video["snippet"]["title"]} ${video["snippet"]["publishTime"]}${_(' by ')}${video["snippet"]["channelTitle"]}"] =
            "https://www.youtube.com/watch?v=${video["id"]}";
      }
      setState(() {
        loading = false;
      });
    } else {

      setState(() {
        loading = false;
      });
    }
  }  void initState(){
    super.initState();
    load();
  }
  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Text(_("trending videos")),
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