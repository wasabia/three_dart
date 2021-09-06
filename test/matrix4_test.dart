import 'package:flutter_test/flutter_test.dart';

import 'package:three_dart/three_dart.dart';

void main() {
  test('adds one to input values', () {

    var left = -0.19803038838554346;
    var top = 0.41421356237309503;
    var near = 1;
    var height = 0.8284271247461901;
    var width = 0.3960607767710869;
    var far = 10000;

    var a = new Matrix4().makePerspective( left, left + width, top, top - height, near, far );
    var expected = new Matrix4().set(
      1, 0, 0, 0,
      0, - 1, 0, 0,
      0, 0, - 101 / 99, - 200 / 99,
      0, 0, - 1, 0
    );

    print(a.elements);
    print(expected.elements );

    expect(a.elements, expected.elements);
  
  });
}
