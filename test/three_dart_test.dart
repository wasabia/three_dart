import 'package:flutter_test/flutter_test.dart';


void main() {
  test('adds one to input values', () {
    
    var str = "2589/3069/2612 2591/3071/2614 2588/3068/2611";

    var _list = str.split(RegExp(r"\s+"));

    print(_list);

  });
}
