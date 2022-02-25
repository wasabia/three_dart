
import 'package:flutter/material.dart';
import 'ExampleApp.dart';
import 'package:example/webgpu_rtt.dart';

void main() {
  // runApp(ExampleApp());
  runApp( MaterialApp(home: webgpu_rtt(fileName: "webgpu_rtt"),) );
}
