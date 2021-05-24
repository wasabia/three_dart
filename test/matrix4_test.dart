
// import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:three_dart/three_dart.dart';

void main() {
  test('adds one to input values', () {
    
    var _m1 = Matrix4();
    var _m2 = Matrix4();
    var _m3 = Matrix4();

    int _t = DateTime.now().millisecondsSinceEpoch;
    var a = 1.2;

    for(var i=0; i< 50000; i++) {
      var a1 = a * 2.0 + a * 2.5 + a * 4.2 + 5.1 * a;
      a = a + 0.1;
    }
  

    int _t1 = DateTime.now().millisecondsSinceEpoch;

    print(" test cost ${_t1 - _t}  ");



    // var _m1 = Matrix4.identity();
    // var _m2 = Matrix4.identity();
    // var _m3 = Matrix4.identity();

    // int _t = DateTime.now().millisecondsSinceEpoch;

    // for(var i=0; i< 5000; i++) {
    //   _m1.multiply(_m2);
    // }

    // int _t1 = DateTime.now().millisecondsSinceEpoch;

    // print(" test cost ${_t1 - _t}  ");

  });
}
