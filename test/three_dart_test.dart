import 'package:flutter_test/flutter_test.dart';

import 'package:three_dart/three_dart.dart';

void main() {
  test('adds one to input values', () {
    var voidMainRegExp = RegExp(r"\bvoid\s+main\s*\(\s*\)\s*{");

    var str = """
      void main {
        hello worl
      }
    """;

    var matches = voidMainRegExp.firstMatch(str);

    print(matches!.group(0));

  });
}
