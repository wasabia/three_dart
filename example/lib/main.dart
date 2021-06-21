import 'package:example/ExampleText.dart';
import 'package:example/ExampleTextBufferGeometry.dart';
import 'package:flutter/material.dart';

import 'ExampleMultiSamples.dart';
import 'MyApp1.dart';
import 'MyApp2.dart';
import 'MyApp3.dart';
import 'ExampleSlide.dart';

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
    return ExampleSlide();
  }
}
