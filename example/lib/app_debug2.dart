import 'package:flutter/material.dart';
import 'dart:math' as Math;

import 'package:flutter/services.dart';

class app_debug2 extends StatefulWidget {
  String fileName;

  app_debug2({Key? key, required this.fileName}) : super(key: key);

  createState() => webgl_debugState();
}

class webgl_debugState extends State<app_debug2> {

  @override
  void initState() {
    super.initState();


    loadFile();
  }

  loadFile() async {
    final data = await rootBundle.load("assets/test.txt");
    print(" load data: ${data} ");
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text(widget.fileName),
        ),
        body: Container(),
        
      ),
    );
  }


}


