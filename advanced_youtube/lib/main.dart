import 'package:test/favourites/favouritesGUI.dart';
import 'package:test/trendingVideos.dart';

import 'results/channelsResults .dart';
import 'mediaPlayerViewDialogForUrls.dart';
import 'playlistViewer.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

import 'app.dart';
import 'contectUs.dart';
import 'language.dart';
import 'results/playlistsResults.dart';
import 'results/videosResults.dart';
import 'settings.dart';
import 'viewText.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Language.runTranslation();
  runApp(Test());
}

class Test extends StatefulWidget {
  const Test({Key? key}) : super(key: key);

  @override
  State<Test> createState() => _TestState();
}

class _TestState extends State<Test> {
  var _ = Language.translate;
  int selectedValueForSearch = 0;
  int selectedValueForOpen = 0;
  TextEditingController search = TextEditingController();
  TextEditingController  open= TextEditingController();
  void onOpenChanged(int value) {
    setState(() {
      selectedValueForOpen = value ?? 0;
    });
  }

  void onSearchChanged(int value) {
    setState(() {
      selectedValueForSearch = value ?? 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      locale: Locale(Language.languageCode),
      title: App.name,
      themeMode: ThemeMode.system,
      home: Builder(builder: (context) => Scaffold(
        appBar: AppBar(
          title: const Text(App.name),
        ),
        drawer: Drawer(
          child: ListView(
            children: [
              DrawerHeader(child: Text(_("navigation menu"))),
              ListTile(
                title: Text(_("settings")),
                onTap: () async {
                  await Navigator.push(context, MaterialPageRoute(builder: (context) => SettingsDialog(_)));
                  setState(() {});
                },
              ),
              ListTile(
                title: Text(_("contact us")),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => ContectUsDialog(_)));
                },
              ),
              ListTile(
                title: Text(_("donate")),
                onTap: () {
                  launch("https://www.paypal.me/AMohammed231");
                },
              ),
              ListTile(
                title: Text(_("visit project on github")),
                onTap: () {
                  launch("https://github.com/mesteranas/" + App.appName);
                },
              ),
              ListTile(
                title: Text(_("license")),
                onTap: () async {
                  String result;
                  try {
                    http.Response r = await http.get(Uri.parse("https://raw.githubusercontent.com/mesteranas/" + App.appName + "/main/LICENSE"));
                    if (r.statusCode == 200) {
                      result = r.body;
                    } else {
                      result = _("error");
                    }
                  } catch (error) {
                    result = _("error");
                  }
                  Navigator.push(context, MaterialPageRoute(builder: (context) => ViewText(_("license"), result)));
                },
              ),
              ListTile(
                title: Text(_("about")),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text(_("about") + " " + App.name),
                        content: Center(
                          child: Column(
                            children: [
                              ListTile(title: Text(_("version: ") + App.version.toString())),
                              ListTile(title: Text(_("developer:") + " mesteranas")),
                              ListTile(title: Text(_("description:") + App.description)),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
        body: Container(
          alignment: Alignment.center,
          child: Column(
            children: [
              IconButton(
                onPressed: () {
                  var searchValues = {_("video"): 0, _("playlist"): 1, _("channel"): 2};
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text(_("search")),
                        content: Center(
                          child: Column(
                            children: [
                              Column(
                                children: [
                                  for (var item in searchValues.keys.toList())
                                    RadioListTile(
                                      value: searchValues[item],
                                      groupValue: selectedValueForSearch,
                                      onChanged: (value) => onSearchChanged(value as int),
                                      title: Text(item),
                                    ),
                                ],
                              ),
                              TextFormField(
                                controller: search,
                                decoration: InputDecoration(labelText: _("search")),
                                textInputAction: TextInputAction.search,
                              ),
                            ],
                          ),
                        ),
                        actions: [
                          IconButton(
                            onPressed: () {
                              Navigator.pop(context);
                              if (selectedValueForSearch == 0) {
                                Navigator.push(context, MaterialPageRoute(builder: (context) => videosSearchResults(q: search.text)));
                              } else if (selectedValueForSearch == 1) {
                                Navigator.push(context, MaterialPageRoute(builder: (context) => playlistsSearchResults(q: search.text)));
                              } else{
                                Navigator.push(context, MaterialPageRoute(builder: (context) => ChannelsSearchResults(q: search.text)));
                              }
                            },
                            icon: Icon(Icons.search),
                            tooltip: _("search"),
                          ),
                        ],
                      );
                    },
                  );
                },
                icon: Icon(Icons.search),
                tooltip: _("search"),
              ),
              IconButton(
                onPressed: () {
                  var searchValues = {_("video"): 0, _("playlist"): 1};
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text(_("open")),
                        content: Center(
                          child: Column(
                            children: [
                              Column(
                                children: [
                                  for (var item in searchValues.keys.toList())
                                    RadioListTile(
                                      value: searchValues[item],
                                      groupValue: selectedValueForOpen,
                                      onChanged: (value) => onOpenChanged(value as int),
                                      title: Text(item),
                                    ),
                                ],
                              ),
                              TextFormField(
                                controller: open,
                                decoration: InputDecoration(labelText: _("URL")),
                                textInputAction: TextInputAction.go,
                              ),
                            ],
                          ),
                        ),
                        actions: [
                          IconButton(
                            onPressed: () {
                              Navigator.pop(context);
                              if (selectedValueForOpen == 0) {
                                Navigator.push(context, MaterialPageRoute(builder: (context) => MediaPlayerURLViewer(filePath: open.text)));
                              } else if (selectedValueForOpen == 1) {
                                Navigator.push(context, MaterialPageRoute(builder: (context) => Playlistviewer(q: open.text.split("playlist?list=")[1])));
                              }
                            },
                            icon: Icon(Icons.search),
                            tooltip: _("open"),
                          ),
                        ],
                      );
                    },
                  );
                },
                icon: Icon(Icons.search),
                tooltip: _("open"),
              ),
              IconButton(onPressed: (){
                Navigator.push(context, MaterialPageRoute(builder: (context)=>Favourites()));
              }, icon: Icon(Icons.favorite_outline),tooltip: _("favourites"),),
              ElevatedButton(onPressed: (){
                Navigator.push(context, MaterialPageRoute(builder: (context)=>TrendingVideos()));
              }, child: Text(_("trending videos"))),
            ],
          ),
        ),
      )),
    );
  }
}
