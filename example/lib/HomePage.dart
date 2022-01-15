import 'filesJson.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  Function chooseExample;

  HomePage({Key? key, required this.chooseExample}) : super(key: key);

  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Example app'),
        ),
        body: Builder(
          builder: (BuildContext context) {
            return ListView.builder(
                itemBuilder: (BuildContext context, int index) {
                  return _buildItem(context, index);
                },
                itemCount: filesJson.length);
          },
        ),
      ),
    );
  }

  String getName(String file) {
    var name = file.split('_');
    name.removeAt(0);
    return name.join(' / ');
  }

  Widget _buildItem(BuildContext context, int index) {
    var fileName = filesJson[index];

    var assetFile = "assets/screenshots/${fileName}.jpg";
    var name = getName(fileName);

    return TextButton(
        onPressed: () {
          widget.chooseExample(fileName);
        },
        child: Container(
            child: Column(
          children: [
            Container(
              constraints: BoxConstraints(minHeight: 50),
              child: Image.asset(assetFile),
            ),
            Container(
              child: Text(name),
            )
          ],
        )));
  }
}
