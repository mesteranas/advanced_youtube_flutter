import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
class ContectUsDialog extends StatelessWidget{
  var _;
  ContectUsDialog(this._);
  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(title:Text(this._("contect us")) ,),
      body:Container(alignment: Alignment.center,
      child: Column(children: [Expanded(child: 
        ListView(
          children: [
            ListTile(title: Text("telegram") ,onTap:(){
              launch("https://t.me/mesteranasm");
            } ,),
            ListTile(title:Text("github") ,onTap:(){
              launch("https://github.com/mesteranas");
            } ,),
            ListTile(title: Text("x"),onTap: (){
              launch("https://x.com/mesteranasm");
            },),
            ListTile(title: Text("telegram channel"),onTap:(){
              launch("https://t.me/tprogrammers");
            } ,),
            ListTile(title: Text("email"),onTap:(){
              launch("mailto:anasformohammed@gmail.com");
            } ,)
          ],
        ))
      ],),),
    );
  }
}