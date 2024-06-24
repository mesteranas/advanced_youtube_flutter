import 'favourites/favouritesJsonControl.dart';
import 'playlistViewer.dart';
import 'package:flutter_share/flutter_share.dart';
import 'package:flutter/services.dart';
import 'package:test/mediaPlayerViewDialogForUrls.dart';
import 'dart:convert';
import '../app.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import '../language.dart';
class Channels extends StatefulWidget{
  var q="";
  Channels({Key?key,required this.q}):super(key:key);
  @override
  State<Channels> createState()=>_Channels(q);
}
class _Channels extends State<Channels> with SingleTickerProviderStateMixin {
  var isFavourite=false;
  late TabController tabControler;
  Map<String, dynamic>? channelInfo;
  var videoNextPageId="";
  var playlistNextPageId="";
  var videosResults={};
  var playlistsResults={};
  var _=Language.translate;
  var q="";
  _Channels(this.q);
    Future<void> fetchChannelInfo() async {
    final String url = 'https://www.googleapis.com/youtube/v3/channels?part=snippet,statistics&id=' + q + '&key=' + App.apiKey;
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      setState(() {
        channelInfo = data['items'][0];
      });
      isFavourite=await check(2, channelInfo!['snippet']['title'], q);
    } else {
      throw Exception('Failed to load channel information');
    }
  }

    Future<void> loadPlaylists() async{
    String url="";
    if (playlistNextPageId.isEmpty){
      url='https://www.googleapis.com/youtube/v3/search?part=snippet&channelId=' + q + '&maxResults=50&order=date&type=playlist&key=' + App.apiKey;
    }else{
      url='https://www.googleapis.com/youtube/v3/search?part=snippet&channelId=' + q + '&maxResults=50&order=date&type=playlist&key=' + App.apiKey + '&pageToken=' + videoNextPageId;
    }
    var responce=await http.get(Uri.parse(url));
    if (responce.statusCode==200){
      var data=jsonDecode(responce.body);
      playlistNextPageId=data["nextPageToken"].toString();
      for ( var video in data["items"]){

        playlistsResults[video["snippet"]["title"].toString() + " " + video["snippet"]["publishTime"].toString() + _(" by ") + video["snippet"]["channelTitle"].toString()]=video["id"]["playlistId"].toString();
      }
    }
  setState(() {
    
  });
  }

  Future<void> loadBideos() async{
    String url="";
    if (videoNextPageId.isEmpty){
      url='https://www.googleapis.com/youtube/v3/search?part=snippet&channelId=' + q + '&maxResults=50&order=date&type=video&key=' + App.apiKey;
    }else{
      url='https://www.googleapis.com/youtube/v3/search?part=snippet&channelId=' + q + '&maxResults=50&order=date&type=video&key=' + App.apiKey + '&pageToken=' + videoNextPageId;
    }
    var responce=await http.get(Uri.parse(url));
    if (responce.statusCode==200){
      var data=jsonDecode(responce.body);
      videoNextPageId=data["nextPageToken"].toString();
      for ( var video in data["items"]){

        videosResults[video["snippet"]["title"].toString() + " " + video["snippet"]["publishTime"].toString() + _(" by ") + video["snippet"]["channelTitle"].toString()]="https://www.youtube.com/watch?v=" + video["id"]["videoId"].toString();
      }
    }
  setState(() {
    
  });
  }
  void initState(){
    super.initState();
    tabControler=TabController(length: 3, vsync: this);
    loadBideos();
    loadPlaylists();
    fetchChannelInfo();
  }
  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Text(channelInfo!['snippet']['title']),
        bottom:TabBar(tabs: [
          Tab(text:_("videos") ,),
          Tab(text: _("playlists"),),
          Tab(text: _("about"),)
        ],
        controller: tabControler,) ,
        actions: [
          IconButton(onPressed: (){
            loadBideos();
            loadPlaylists();
          }, icon: Icon(Icons.more),tooltip: _("show more"),),
          IconButton(onPressed: (){
  showDialog(context: context, builder: (BuildContext context){
    return AlertDialog(
      title: Text(_("more options")),
      content: Center(
        child: Column(
          children: [
                    CheckboxListTile(
            value: isFavourite,
            onChanged: (bool? newValue) async{
              setState(() {
                isFavourite = newValue ?? false;
                              });
                if (isFavourite) {
                  await addFavourite(2, channelInfo!['snippet']['title'], q, q);
                } else {
                  await removeFromFavourite(2, channelInfo!['snippet']['title'], q);
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
      body: 
      TabBarView(controller: tabControler,
      children: [
        Center(
        child:
         ListView.builder(itemBuilder:(context,index){
          var resultsKeys=videosResults.keys.toList();
          return ListTile(title: Text(resultsKeys[index]),
          onLongPress:(){
            showDialog(context: context, builder: (context){
              return AlertDialog(
                title: Text(_("video options")),
                actions: [
                  IconButton(onPressed: (){
                    Clipboard.setData(ClipboardData(text: videosResults[resultsKeys[index]]));
                    Navigator.pop(context);
                  }, icon: Icon(Icons.copy),tooltip: _("copy link"),),
                  IconButton(onPressed: (){
                    FlutterShare.share(title: "share",text: videosResults[resultsKeys[index]]);
                    Navigator.pop(context);
                  }, icon: Icon(Icons.share),tooltip: _("share link"),),
                ],
              );
            });
          } ,
          onTap: (){
          Navigator.push(context, MaterialPageRoute(builder: (context)=>MediaPlayerURLViewer(filePath: videosResults[resultsKeys[index]])));
          },);
        } ) 
      
      ),
      Center(
                child:
         ListView.builder(itemBuilder:(context,index){
          var resultsKeys=playlistsResults.keys.toList();
          return ListTile(title: Text(resultsKeys[index]),
          onLongPress:(){
            showDialog(context: context, builder: (context){
              return AlertDialog(
                title: Text(_("options")),
                actions: [
                  IconButton(onPressed: (){
                    Clipboard.setData(ClipboardData(text: "https://www.youtube.com/playlist?list=" + playlistsResults[resultsKeys[index]]));
                    Navigator.pop(context);
                  }, icon: Icon(Icons.copy),tooltip: _("copy link"),),
                  IconButton(onPressed: (){
                    FlutterShare.share(title: "share",text: "https://www.youtube.com/playlist?list=" + playlistsResults[resultsKeys[index]]);
                    Navigator.pop(context);
                  }, icon: Icon(Icons.share),tooltip: _("share link"),),
                ],
              );
            });
          } ,
          onTap: (){
          Navigator.push(context, MaterialPageRoute(builder: (context)=>Playlistviewer(q: playlistsResults[resultsKeys[index]])));
          },);
        } ,itemCount: playlistsResults.keys.toList().length,) 

      ),
      Center(
        child: channelInfo == null
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(title: Text(
                    channelInfo!['snippet']['title'],
                  )),
                  SizedBox(height: 8),
                  ListTile(title:Text( channelInfo!['snippet']['description'])),
                  SizedBox(height: 16),
                  ListTile(title:Text( _('Subscribers: ') + channelInfo!['statistics']['subscriberCount'])),
                  ListTile(title:Text( _('Total Views: ') + channelInfo!['statistics']['viewCount'])),
                  ListTile(title:Text( _('Total Videos: ') + channelInfo!['statistics']['videoCount'])),
                ],
              ),
      ))
      ])
    );
  }
}