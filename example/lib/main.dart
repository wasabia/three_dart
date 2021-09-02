import 'package:example/webgl_interactive_voxelpainter.dart';
import 'package:flutter/material.dart';



void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    // return MyApp1();
    // return MyApp2();
    // return MyApp3();
    // return ExampleTextBufferGeometry();
    // return ExampleText();
    // return ExampleMultiSamples();
    // return ExampleSlide();
    // return ExampleUnrealBloom();
    // return MyAppLut();
    // return ExampleLineFat();
    // return ExampleLineDrawRange();
    // return ExampleModifierCurve();
    // return Container();
    return Webgl_interactive_voxelpainter(key: GlobalKey(debugLabel: "Webgl_interactive_voxelpainter"));
  }
}
