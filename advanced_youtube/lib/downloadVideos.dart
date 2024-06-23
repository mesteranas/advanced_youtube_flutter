import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'language.dart';
import 'package:http/http.dart' as http;
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:flutter/material.dart';
class ShowAllQualitiesToDownload extends StatelessWidget{
  var _=Language.translate;
  var qualities={};
  ShowAllQualitiesToDownload(this.qualities);
  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Text(_("select a quality to download")),
      ),
      body: Center(
        child: ListView.builder(itemBuilder: (context,index){
          var QKeys=qualities.keys.toList();
          return ListTile(title: Text(QKeys[index]),
          onTap: () async{
            var path=await FilePicker.platform.getDirectoryPath();
            if(path!=""){
              Map<String, dynamic> infos=qualities[QKeys[index]];
              infos["path"]=path??"";
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (context)=>DownloadVideo(infos: infos)));
            }
          },);
        
        },
        itemCount: qualities.keys.toList().length,),
      ),
    );
  }
}
class DownloadVideo extends StatefulWidget {
  final Map<String, dynamic> infos;
  
  DownloadVideo({Key? key, required this.infos}) : super(key: key);
  
  @override
  State<DownloadVideo> createState() => _DownloadVideoState();
}

class _DownloadVideoState extends State<DownloadVideo> {
  var _ = Language.translate;
  bool error = false;
  double progress = 0.0;
  bool downloaded = false;

  @override
  void initState() {
    super.initState();
    startDownloading();
  }

  Future<void> startDownloading() async {
    try {
      var res = await http.Client().send(http.Request("GET", widget.infos["url"]));
      var contentLength = res.contentLength ?? 0;
      var path = widget.infos["path"] + "/" + widget.infos["title"] + (widget.infos["type"] == "video" ? ".mp4" : ".mp3");
      var file = File(path);
      List<int> bytes = [];
      int downloadedBytes = 0;

      res.stream.listen((newBytes) {
        bytes.addAll(newBytes);
        downloadedBytes += newBytes.length;
        setState(() {
          progress = downloadedBytes / contentLength;
        });
      }).onDone(() async {
        await file.writeAsBytes(bytes);
        setState(() {
          downloaded = true;
        });
      });
    } catch (e) {
      print(e);
      setState(() {
        error = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_("downloading")),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (!downloaded && !error)
              LinearProgressIndicator(
                value: progress,
              )
            else if (error)
              Text(_("an error detected"))
            else
              Text(_("downloaded")),
            SizedBox(height: 20),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(_("close")),
            ),
          ],
        ),
      ),
    );
  }
}

class Language {
  static String translate(String key) {
    // Dummy translation function
    return key;
  }
}
