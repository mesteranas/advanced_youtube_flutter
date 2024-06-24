import 'favourites/favouritesJsonControl.dart';
import 'channel.dart';
import 'downloadVideos.dart';
import 'package:http/http.dart' as http;
import 'app.dart';
import 'dart:convert';
import 'viewText.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter/material.dart';

class MediaPlayerURLViewer extends StatefulWidget {
  final String filePath;

  MediaPlayerURLViewer({Key? key, required this.filePath}) : super(key: key);

  @override
  State<MediaPlayerURLViewer> createState() => _MediaPlayerURLViewerState(filePath);
}

class _MediaPlayerURLViewerState extends State<MediaPlayerURLViewer> {
  var isFavourite=false;
  var channelId="";
  var duration="";
  var videoID="";
  var publishDate="";
  var description="";
  var _ = Language.translate;
  final String filePath;
  String title = "";
  bool isFullScreen = false;
  late Future<void> _initializeVideoPlayerFuture;
  VideoPlayerController? _controller;

  _MediaPlayerURLViewerState(this.filePath);
    Future<Map<String, String>> _fetchComments(String videoID) async {
    Map<String, String> comments = {};
    String baseUrl = "https://www.googleapis.com/youtube/v3/commentThreads?part=snippet&videoId=" + videoID + "&key=" + App.apiKey + "&maxResults=100";

    List<dynamic> allComments = [];
    String? nextPageToken;

    while (true) {
      if (nextPageToken != null) {

        baseUrl+="&pageToken=" + nextPageToken??"";
      }

      final uri = Uri.parse(baseUrl);
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final fetchedComments = data["items"] ?? [];
        allComments.addAll(fetchedComments);
        nextPageToken = data["nextPageToken"];
        if (nextPageToken == null) break;
      } else {
        return {};
      }
    }

    for (var comment in allComments) {
      var snippet = comment["snippet"]["topLevelComment"]["snippet"];
      var author = snippet["authorDisplayName"];
      var text = snippet["textDisplay"];
      comments["$text \n by $author"] = text;
    }

    return comments;
  }


  @override
  void initState() {
    super.initState();
    loadMedia();
  }

  Future<void> loadMedia() async {
    var yt = YoutubeExplode();
    var video = await yt.videos.get(filePath);
    title=video.title;
    channelId=video.channelId.toString();
    description=video.description;
    duration=video.duration?.inMinutes.toString()??"";
    publishDate=video.publishDate.toString();
    videoID=video.id.value;
    isFavourite=await check(0, title, channelId);

    var manifest = await yt.videos.streamsClient.getManifest(video.id);
    var stream = manifest.muxed.withHighestBitrate();

    _controller = VideoPlayerController.network(stream.url.toString());
    _initializeVideoPlayerFuture = _controller!.initialize();
    _controller!.setLooping(true);
    _controller!.addListener(() {
      setState(() {});
    });
    _controller!.play();
    setState(() {});
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _rewind() {
    final newPosition = _controller!.value.position - Duration(seconds: 10);
    _controller!.seekTo(newPosition < Duration.zero ? Duration.zero : newPosition);
  }

  void _fastForward() {
    final newPosition = _controller!.value.position + Duration(seconds: 10);
    if (newPosition < _controller!.value.duration) {
      _controller!.seekTo(newPosition);
    } else {
      _controller!.seekTo(_controller!.value.duration);
    }
  }

  void _toggleFullScreen() {
    setState(() {
      isFullScreen = !isFullScreen;
    });
    if (isFullScreen) {

    } else {
      
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(
            icon: Icon(isFullScreen ? Icons.fullscreen_exit : Icons.fullscreen),
            onPressed: _toggleFullScreen,
            tooltip: _("toggle full screen"),
          ),
        ],
      ),
      body: Center(
        child: _controller != null
            ? FutureBuilder(
                future: _initializeVideoPlayerFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    return GestureDetector(
                      onVerticalDragUpdate:(DragUpdateDetails details){
                        if (details.delta.dy<0){
                          _fastForward();
                        } else if (details.delta.dy>0){
                          _rewind();
                        }


                      } ,
                      onDoubleTap: () {
                                setState(() {
                                  _controller!.value.isPlaying
                                      ? _controller!.pause()
                                      : _controller!.play();
                                });
                        
                      },
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          AspectRatio(
                            aspectRatio: _controller!.value.aspectRatio,
                            child: VideoPlayer(_controller!),
                          ),
                          if (!isFullScreen) ...[
                            IconButton(
                              icon: Icon(Icons.replay_10),
                              tooltip: 'Rewind 10 seconds',
                              onPressed: _rewind,
                            ),
                            IconButton(
                              icon: Icon(
                                  _controller!.value.isPlaying ? Icons.pause : Icons.play_arrow),
                              tooltip: _controller!.value.isPlaying ? 'Pause' : 'Play',
                              onPressed: () {
                                setState(() {
                                  _controller!.value.isPlaying
                                      ? _controller!.pause()
                                      : _controller!.play();
                                });
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.forward_10),
                              tooltip: 'Fast forward 10 seconds',
                              onPressed: _fastForward,
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Slider(
                                  value: _controller!.value.volume,
                                  onChanged: (newValue) {
                                    setState(() {
                                      _controller?.setVolume(newValue);
                                    });
                                  },
                                  min: 0.0,
                                  max: 1.0,
                                  divisions: 10,
                                  label: 'Volume ${(_controller!.value.volume * 100).round()}',
                                ),
                                Slider(
                                  value: _controller!.value.playbackSpeed,
                                  onChanged: (newValue) {
                                    setState(() {
                                      _controller?.setPlaybackSpeed(newValue);
                                    });
                                  },
                                  min: 0.1,
                                  max: 2.0,
                                  divisions: 10,
                                  label: 'Speed ${_controller!.value.playbackSpeed.toStringAsFixed(1)}x',
                                  
                                ),
                                Slider(
                                  value: _controller!.value.position.inSeconds.toDouble(),
                                  onChanged: (newValue) {
                                    setState(() {
                                      var position = Duration(seconds: newValue.toInt());
                                      _controller!.seekTo(position);
                                    });
                                  },
                                  min: 0.0,
                                  max: _controller!.value.duration.inSeconds.toDouble(),
                                  divisions: _controller!.value.duration.inSeconds,
                                ),
                                IconButton(onPressed: (){
                                  showDialog(context: context, builder: (context){
                                    return AlertDialog(
                                      title: Text(_("options")),
                                      actions: [
                                        IconButton(onPressed: (){
                                          _controller!.pause();
                                          Navigator.pop(context);
                                          Navigator.push(context, MaterialPageRoute(builder: (context)=>ViewText(_("video description"), description)));
                                        }, icon: Icon(Icons.description),tooltip: _("description"),),
                                            IconButton(
                                              onPressed: () {
                                                showDialog(
                                                  context: context,
                                                  barrierDismissible: false,
                                                  builder: (BuildContext context) {
                                                    return FutureBuilder<Map<String, String>>(
                                                      future: _fetchComments(videoID),
                                                      builder: (context, snapshot) {
                                                        if (snapshot.connectionState ==
                                                            ConnectionState.waiting) {
                                                          return Center(
                                                            child: CircularProgressIndicator(),
                                                          );
                                                          
                                                        } else if (snapshot.hasError) {
                                                          return AlertDialog(
                                                            title: Text(_("Error")),
                                                            content: Text(
                                                                _("Failed to load comments")),
                                                            actions: [
                                                              TextButton(
                                                                onPressed: () {
                                                                  Navigator.of(context).pop();
                                                                },
                                                                child: Text(_("Close")),
                                                              ),
                                                            ],
                                                          );
                                                        } else if (snapshot.hasData) {
                                                          final comments = snapshot.data!;
                                                          return AlertDialog(
                                                            title: Text(_("comments")),
                                                            content: SingleChildScrollView(
                                                              child: Text(comments.keys
                                                                  .toList()
                                                                  .join("\n")),
                                                            ),
                                                            actions: [
                                                              TextButton(
                                                                onPressed: () {
                                                                  Navigator.of(context).pop();
                                                                },
                                                                child: Text(_("Close")),
                                                              ),
                                                            ],
                                                          );
                                                        } else {
                                                          return AlertDialog(
                                                            title: Text(_("Error")),
                                                            content: Text(_("No comments found")),
                                                            actions: [
                                                              TextButton(
                                                                onPressed: () {
                                                                  Navigator.of(context).pop();
                                                                },
                                                                child: Text(_("Close")),
                                                              ),
                                                            ],
                                                          );
                                                        }
                                                      },
                                                    );
                                                  },
                                                );
                                              },
                                              icon: Icon(Icons.comment),
                                              tooltip: _("comments"),),
                                              IconButton(icon: Icon(Icons.download),tooltip: _("download video"),onPressed:() async{
                                                    var yt = YoutubeExplode();
        var video = await yt.videos.get(this.filePath);
        var manifest = await yt.videos.streamsClient.getManifest(video.id);
        var streams={};
        for(var stream in manifest.streams){
          streams[stream.qualityLabel + stream.codec.type]={"url":stream.url,"type":stream.codec.type,"title":title};
        }
        Navigator.pop(context);
        Navigator.push(context, MaterialPageRoute(builder: (context)=>ShowAllQualitiesToDownload(streams)));
                                              } ,),
          ElevatedButton(onPressed: (){
            Navigator.push(context, MaterialPageRoute(builder: (context)=>Channels(q: channelId)));
          }, child: Text(_("go to channel"))),

                                      ],
                                      content:Center(
                                        child:Column(
                                          children: [
                                            ListTile(title: Text(_("duration ") + duration + _(" minuts")),),
                                            ListTile(title: Text(_("published on ") + publishDate),),
                                                                CheckboxListTile(
            value: isFavourite,
            onChanged: (bool? newValue) async{
              setState(() {
                isFavourite = newValue ?? false;
                              });
                if (isFavourite) {
                  await addFavourite(0, title, channelId, videoID);
                } else {
                  await removeFromFavourite(0, title, channelId);
                }
                Navigator.pop(context);
            },
            title: Text(_("favourite")),
          ),


                                          ],
                                        ) ,
                                      ) ,
                                    );
                                  });
                                }, icon: Icon(Icons.more),tooltip: _("more"),),
                              ],
                            ),
                          ],
                        ],
                      ),
                    );
                  } else {
                    return CircularProgressIndicator();
                  }
                },
              )
            : Text('Loading video...'),
      ),
    );
  }
}
