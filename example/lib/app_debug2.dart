import 'dart:html';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

class app_debug2 extends StatefulWidget {
  String fileName;

  app_debug2({Key? key, required this.fileName}) : super(key: key);

  createState() => webgl_debugState();
}

class webgl_debugState extends State<app_debug2> {
  CanvasElement? element;
  dynamic gl;
  String divId = DateTime.now().microsecondsSinceEpoch.toString();

  @override
  void initState() {
    super.initState();

    init();
  }

  init() {
    ui.platformViewRegistry.registerViewFactory(divId, (int viewId) {
      this.element = CanvasElement(width: 300, height: 300)..id = 'canvas-id';

      print(" set element ");
      print(" set gl ");

      this.gl = this
          .element!
          .getContext("webgl2", {"alpha": true, "antialias": true});
      return this.element!;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text(widget.fileName),
        ),
        body: Container(
          child: HtmlElementView(viewType: divId),
        ),
        floatingActionButton: FloatingActionButton(
          child: Text("render"),
          onPressed: () {
            render();
          },
        ),
      ),
    );
  }

  render() {
    print(" render gl: ${gl} ");

    var _ext = gl.getExtension("EXT_texture_filter_anisotropic");

    print(" _ext: ${_ext} ");
    print(" _ext: ${_ext.TEXTURE_MAX_ANISOTROPY_EXT} ");
  }
}
