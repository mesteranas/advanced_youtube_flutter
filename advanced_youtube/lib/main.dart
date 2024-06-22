import 'results/videosResults.dart';
import 'settings.dart';
import 'package:flutter/widgets.dart';

import 'language.dart';
import 'package:http/http.dart' as http;
import 'viewText.dart';
import 'app.dart';
import 'contectUs.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

void main() async{
  await WidgetsFlutterBinding.ensureInitialized();
  await Language.runTranslation();
  runApp(test());
}
class test extends StatefulWidget{
  const test({Key?key}):super(key:key);
  @override
  State<test> createState()=>_test();
}
class _test extends State<test>{
  var _=Language.translate;
  int selectedValueForSearch=0;
  TextEditingController search=TextEditingController();
  _test();

  void onSearchChanged(var value){
    setState(() {
      selectedValueForSearch=value??0;
    });
  }
  @override
  Widget build(BuildContext context){
    return MaterialApp(
      locale: Locale(Language.languageCode),
      title: App.name,
      themeMode: ThemeMode.system,
      home:Builder(builder:(context) 
    =>Scaffold(
      appBar:AppBar(
        title: const Text(App.name),), 
        drawer: Drawer(
          child:ListView(children: [
          DrawerHeader(child: Text(_("navigation menu"))),
          ListTile(title:Text(_("settings")) ,onTap:() async{
            await Navigator.push(context, MaterialPageRoute(builder: (context) =>SettingsDialog(this._) ));
            setState(() {
              
            });
          } ,),
          ListTile(title: Text(_("contect us")),onTap: (){
            Navigator.push(context, MaterialPageRoute(builder: (context)=>ContectUsDialog(this._)));
          },),
          ListTile(title: Text(_("donate")),onTap: (){
            launch("https://www.paypal.me/AMohammed231");
          },),
  ListTile(title: Text(_("visite project on github")),onTap: (){
    launch("https://github.com/mesteranas/"+App.appName);
  },),
  ListTile(title: Text(_("license")),onTap: ()async{
    String result;
    try{
    http.Response r=await http.get(Uri.parse("https://raw.githubusercontent.com/mesteranas/" + App.appName + "/main/LICENSE"));
    if ((r.statusCode==200)) {
      result=r.body;
    }else{
      result=_("error");
    }
    }catch(error){
      result=_("error");
    }
    Navigator.push(context, MaterialPageRoute(builder: (context)=>ViewText(_("license"), result)));
  },),
  ListTile(title: Text(_("about")),onTap: (){
    showDialog(context: context, builder: (BuildContext context){
      return AlertDialog(title: Text(_("about")+" "+App.name),content:Center(child:Column(children: [
        ListTile(title: Text(_("version: ") + App.version.toString())),
        ListTile(title:Text(_("developer:")+" mesteranas")),
        ListTile(title:Text(_("description:") + App.description))
      ],) ,));
    });
  },)
        ],) ,),
        body:Container(alignment: Alignment.center
        ,child: Column(children: [
          IconButton(onPressed: (){
            var searchValues={_("video"):0,_("playlist"):1,_("channel"):2};
            showDialog(context: context, builder: (context){
              return AlertDialog(
                title: Text(_("search")),
                content:Center(
                  child: Column(
                    children: [
                      Column(children: [
                      for (var item in searchValues.keys.toList())
                      RadioListTile(value: searchValues[item], groupValue: selectedValueForSearch, onChanged: onSearchChanged,title: Text(item),)
                      ],),
                      TextFormField(controller: search,decoration: InputDecoration(labelText: _("search")),textInputAction: TextInputAction.search)
                    ],
                  ),
                ) ,
                actions: [
                  IconButton(onPressed: (){
                    Navigator.pop(context);
                    if (selectedValueForSearch==0){
                      Navigator.push(context, MaterialPageRoute(builder: (context)=>videosSearchResults(q: search.text)));
                    }
                  }, icon: Icon(Icons.search),tooltip: _("search"),)
                ],
              );
            });
          }, icon: Icon(Icons.search),tooltip: _("search"),),
    ])),)));
  }
}
