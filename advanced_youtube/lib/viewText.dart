import 'package:flutter/material.dart';
class ViewText extends StatelessWidget{
  final String title;
  final String content;
  ViewText(this.title,this.content);
  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Text(this.title),),
        body:Center(child: Column(
          children: [
            for (String item in this.content.split("\n"))
              ListTile(title: Text(item),)

          ],
        ),)
    );
  }
}