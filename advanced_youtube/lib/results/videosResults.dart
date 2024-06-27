import 'package:flutter_share/flutter_share.dart';
import 'package:flutter/services.dart';
import 'package:test/mediaPlayerViewDialogForUrls.dart';
import 'dart:convert';
import '../app.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import '../language.dart';
class videosSearchResults extends StatefulWidget{
  var q="";
  videosSearchResults({Key?key,required this.q}):super(key:key);
  @override
  State<videosSearchResults> createState()=>_videosSearchResults(q);
}
class _videosSearchResults extends State<videosSearchResults>{
  var thumbnails=[];
  var nextPageId="";
  var loading=true;
  var results={};
  var _=Language.translate;
  var q="";
  _videosSearchResults(this.q);
  Future<void> load() async{
    String url="";
    if (nextPageId.isEmpty){
      url='https://www.googleapis.com/youtube/v3/search?part=snippet&q=' + this.q + '&type=video&maxResults=100&key=' + App.apiKey;
    }else{
      url='https://www.googleapis.com/youtube/v3/search?part=snippet&q=' + this.q + '&type=video&maxResults=100&key=' + App.apiKey + '&pageToken=' + nextPageId;
    }
    var responce=await http.get(Uri.parse(url));
    if (responce.statusCode==200){
      var data=jsonDecode(responce.body);
      nextPageId=data["nextPageToken"].toString();
      for ( var video in data["items"]){
        thumbnails.add(video['snippet']['thumbnails']['default']['url']);
        results[video["snippet"]["title"].toString() + " " + video["snippet"]["publishTime"].toString() + _(" by ") + video["snippet"]["channelTitle"].toString()]="https://www.youtube.com/watch?v=" + video["id"]["videoId"].toString();
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
        title: Text(_("search results")),
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
          return ListTile(contentPadding: EdgeInsets.all(8),
              leading: Image.network(
                thumbnails[index],
                width: 100, // Set the width of the thumbnail
                height: 100, // Set the height of the thumbnail
                fit: BoxFit.cover,
              ),
              title: Text(
                resultsKeys[index],
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
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
        } ,itemCount: results.keys.toList().length,) 
      : Text(_("loading ..."))
      ),

    );
  }
}