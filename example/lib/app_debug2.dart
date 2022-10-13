// ignore: avoid_web_libraries_in_flutter
import 'dart:html';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

class AppDebug2 extends StatefulWidget {
  final String fileName;

  const AppDebug2({Key? key, required this.fileName}) : super(key: key);

  @override
  State<AppDebug2> createState() => AppDebug2State();
}

class AppDebug2State extends State<AppDebug2> {
  CanvasElement? element;
  dynamic gl;
  String divId = DateTime.now().microsecondsSinceEpoch.toString();

  @override
  void initState() {
    super.initState();

    init();
  }

  init() {
    // ignore: undefined_prefixed_name
    ui.platformViewRegistry.registerViewFactory(divId, (int viewId) {
      element = CanvasElement(width: 300, height: 300)..id = 'canvas-id';

      print(" set element ");
      print(" set gl ");

      gl = element!.getContext("webgl2", {"alpha": true, "antialias": true});
      return element!;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text(widget.fileName),
        ),
        body: HtmlElementView(viewType: divId),
        floatingActionButton: FloatingActionButton(
          child: const Text("render"),
          onPressed: () {
            render();
          },
        ),
      ),
    );
  }

  render() {
    print(" render gl: $gl ");

    var ext = gl.getExtension("EXT_texture_filter_anisotropic");

    print(" _ext: $ext ");
    print(" _ext: ${ext.TEXTURE_MAX_ANISOTROPY_EXT} ");
  }
}
