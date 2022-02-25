// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

class Proxy {

  @override
  dynamic noSuchMethod(Invocation invocation) {
    String name = invocation.memberName.toString();
    
    name = name.replaceFirst(RegExp(r'^Symbol\("'), "");
    name = name.replaceFirst(RegExp(r'"\)$'), "");


    print("noSuchMethod name: ${name}  ");


    return super.noSuchMethod(invocation);
  }


}


void main() {
  group('demo test', () {
    test('list demo 0', () {



    });
  });
}
