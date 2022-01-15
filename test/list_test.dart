// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('list test', () {
    test('list test 0', () {
      var _list = Float32List.fromList([0, 1, 2, 3, 1, 1]);
      print(" _list ${_list.runtimeType} ");

      Float32List _list2 = _list.buffer.asFloat32List() as Float32List;
      print(" _list2 ${_list2 is Float32List} ");
    });
  });
}
