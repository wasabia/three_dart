import 'package:flutter_test/flutter_test.dart';


void main() {
  test('adds one to input values', () {
    var voidMainRegExp = RegExp(r"\bvoid\s+main\s*{");

    var str = """
    ss
void main  {
  hello worl
}
    """;

    var matches = voidMainRegExp.firstMatch(str);

    print(matches!.group(0));


    var _reg = RegExp(r"\bvoid\s+main\s*{");

    print( _reg.hasMatch("""void main{""") );


  });
}
