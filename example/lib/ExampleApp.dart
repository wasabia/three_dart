import 'package:example/filesJson.dart';
import 'package:example/tagsJson.dart';
import 'package:example/webgl_camera_array.dart';
import 'package:flutter/material.dart';


class ExampleApp extends StatefulWidget {
  ExampleApp({Key? key}) : super(key: key);

  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<ExampleApp> {


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
              itemCount: filesJson.length
            );
          },
        ),
      ),
    );
  }


  String getName( String file ) {

    var name = file.split( '_' );
    name.removeAt(0);
    return name.join( ' / ' );

  }

  Widget _buildItem(BuildContext context, int index) {

    var fileName = filesJson[index];

    var assetFile = "assets/screenshots/${fileName}.jpg";
    var name = getName(fileName);

    return TextButton(
      onPressed: () {
        _goto(context, fileName);
      }, 
      child: Container(
        child: Column(
          children: [
            Image.asset(assetFile),
            Container(
              child: Text(name),
            )
          ],
        )
      )
    );
  }

  _goto(BuildContext context, String fileName) {

    Widget page;

    if(fileName == "webgl_camera_array") {
      page = Webgl_camera_array(fileName: fileName);
    } else {
      throw("_goto fileName ${fileName} is not support yet ");
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (BuildContext context) {
          return page;
        }
      )
    );
  }

}
