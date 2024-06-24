import 'package:test/channel.dart';
import 'favouritesJsonControl.dart';
import '../playlistViewer.dart';
import 'package:flutter_share/flutter_share.dart';
import 'package:flutter/services.dart';
import 'package:test/mediaPlayerViewDialogForUrls.dart';
import 'dart:convert';
import '../app.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import '../language.dart';
class Favourites extends StatefulWidget{
  Favourites({Key?key}):super(key:key);
  @override
  State<Favourites> createState()=>_Favourites();
}
class _Favourites extends State<Favourites> with SingleTickerProviderStateMixin {
  late TabController tabControler;
  var channelResults=[];
  var videosResults=[];
  var playlistsResults=[];
  var _=Language.translate;
  Future<void> load() async{
    var  data=await getFavourites();
    videosResults=data["videos"];
    playlistsResults=data["playlists"];
    channelResults=data["channels"];
  setState(() {
    
  });
  }
  void initState(){
    super.initState();
    tabControler=TabController(length: 3, vsync: this);
    load();
  }
  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Text(_("favourites")),
        bottom:TabBar(tabs: [
          Tab(text:_("videos") ,),
          Tab(text: _("playlists"),),
          Tab(text: _("channels"),)
        ],
        controller: tabControler,) ,

      ),
      body: 
      TabBarView(controller: tabControler,
      children: [
        Center(
        child:
         ListView.builder(itemBuilder:(context,index){
          return ListTile(title: Text(videosResults[index]["title"]),
          onLongPress:(){
            showDialog(context: context, builder: (context){
              return AlertDialog(
                title: Text(_("video options")),
                actions: [
                  IconButton(onPressed: (){
                    Clipboard.setData(ClipboardData(text: "https://www.youtube.com/watch?v=" + videosResults[index]["id"]));
                    Navigator.pop(context);
                  }, icon: Icon(Icons.copy),tooltip: _("copy link"),),
                  IconButton(onPressed: (){
                    FlutterShare.share(title: "share",text: "https://www.youtube.com/watch?v=" + videosResults[index]["id"]);
                    Navigator.pop(context);
                  }, icon: Icon(Icons.share),tooltip: _("share link"),),
                  IconButton(onPressed: () async{
                    var results=videosResults[index];
                    await removeFromFavourite(0, results["title"], results["channelId"]);
                    Navigator.pop(context);
                    load();
                    setState(() {
                      
                    });
                  }, icon: Icon(Icons.delete),tooltip: _("delete"),)
                ],
              );
            });
          } ,
          onTap: (){
          Navigator.push(context, MaterialPageRoute(builder: (context)=>MediaPlayerURLViewer(filePath: "https://www.youtube.com/watch?v=" + videosResults[index]["id"])));
          },);
        } ) 
      
      ),
      Center(
                child:
         ListView.builder(itemBuilder:(context,index){
          return ListTile(title: Text(playlistsResults[index]["title"]),
          onLongPress:(){
            showDialog(context: context, builder: (context){
              return AlertDialog(
                title: Text(_("options")),
                actions: [
                  IconButton(onPressed: (){
                    Clipboard.setData(ClipboardData(text: "https://www.youtube.com/playlist?list=" + playlistsResults[index]["id"]));
                    Navigator.pop(context);
                  }, icon: Icon(Icons.copy),tooltip: _("copy link"),),
                  IconButton(onPressed: (){
                    FlutterShare.share(title: "share",text: "https://www.youtube.com/playlist?list=" + playlistsResults[index]["id"]);
                    Navigator.pop(context);
                  }, icon: Icon(Icons.share),tooltip: _("share link"),),
                                    IconButton(onPressed: () async{
                    var results=playlistsResults[index];
                    await removeFromFavourite(1, results["title"], results["channelId"]);
                    load();
                    Navigator.pop(context);
                    setState(() {
                      
                    });
                  }, icon: Icon(Icons.delete),tooltip: _("delete"),)

                ],
              );
            });
          } ,
          onTap: (){
          Navigator.push(context, MaterialPageRoute(builder: (context)=>Playlistviewer(q: playlistsResults[index]["id"])));
          },);
        } ,itemCount: playlistsResults.length,) 

      ),
      Center(
                        child:
         ListView.builder(itemBuilder:(context,index){
          return ListTile(title: Text(channelResults[index]["title"]),
          onLongPress:() async{
            await showDialog(context: context, builder: (context){
              return AlertDialog(
                title: Text(_("options")),
                actions: [
                  IconButton(onPressed: (){
                    Clipboard.setData(ClipboardData(text: "https://www.youtube.com/channel/" + channelResults[index]["id"]));
                    Navigator.pop(context);
                  }, icon: Icon(Icons.copy),tooltip: _("copy link"),),
                  IconButton(onPressed: (){
                    FlutterShare.share(title: "share",text: "https://www.youtube.com/channel/" + channelResults[index]["id"]);
                    Navigator.pop(context);
                  }, icon: Icon(Icons.share),tooltip: _("share link"),),
                                    IconButton(onPressed: () async{
                    var results=channelResults[index];
                    await removeFromFavourite(2, results["title"], results["channelId"]);
                    Navigator.pop(context);
                    load();
                    setState(() {
                      
                    });
                  }, icon: Icon(Icons.delete),tooltip: _("delete"),)

                ],
              );
            });
            setState(() {
              
            });
          } ,
          onTap: (){
          Navigator.push(context, MaterialPageRoute(builder: (context)=>Channels(q: channelResults[index]["id"])));
          },);
        } ,itemCount: channelResults.length,) 

      ),


      ])
    );
  }
}