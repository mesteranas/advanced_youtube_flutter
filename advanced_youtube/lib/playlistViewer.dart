import 'favourites/favouritesJsonControl.dart';
import 'channel.dart';
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
  var title="";
  var isFavourite=false;
  var channelId="";
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
      channelId=data['items'][0]['snippet']['channelId'];
      title = data['items'][0]['snippet']['title'];
      isFavourite=await check(1, title, channelId);
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
        title: Text(title),
        actions: [
          IconButton(onPressed: (){
            load();
          }, icon: Icon(Icons.more),tooltip: _("show more"),),
IconButton(onPressed: (){
  showDialog(context: context, builder: (BuildContext context){
    return AlertDialog(
      title: Text(_("more options")),
      content: Center(
        child: Column(
          children: [
                      ElevatedButton(onPressed: (){
                        Navigator.pop(context);
            Navigator.push(context, MaterialPageRoute(builder: (context)=>Channels(q: channelId)));
          }, child: Text(_("go to channel"))),
                    CheckboxListTile(
            value: isFavourite,
            onChanged: (bool? newValue) async{
              setState(() {
                isFavourite = newValue ?? false;
                              });
                if (isFavourite) {
                  await addFavourite(1, title, channelId, q);
                } else {
                  await removeFromFavourite(1, title, channelId);
                }
                Navigator.pop(context);
            },
            title: Text(_("favourite")),
          ),

          ],
        ),
      ),
    );
  });
}, icon: Icon(Icons.more),tooltip:_("more options") ,)          
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