import 'package:three_dart/three3d/extras/core/shape.dart';
import 'package:three_dart/three3d/extras/core/shape_path.dart';
import 'package:three_dart/three3d/extras/core/ttf_font.dart';
import 'package:three_dart/three3d/math/index.dart';

class TYPRFont extends Font {
  TYPRFont(data) {
    this.data = data;
  }

  @override
  List<Shape> generateShapes(text, {double size = 100}) {
    List<Shape> shapes = [];
    var paths = createPaths(text, size, data);

    for (var p = 0, pl = paths.length; p < pl; p++) {
      // Array.prototype.push.apply( shapes, paths[ p ].toShapes() );
      shapes.addAll(paths[p].toShapes(true, false));
    }

    return shapes;
  }

  Map<String, dynamic> generateShapes2(text, {int size = 100}) {
    return createPaths2(text, size, data);
  }

  // 同样文字路径不重复生成
  // 生成唯一文字路径
  // 记录 offset
  Map<String, dynamic> createPaths2(String text, num size, Map<String, dynamic> data) {
    List<String> chars = text.split("");

    num scale = size / data["resolution"];
    num lineHeight = (data["boundingBox"]["yMax"] - data["boundingBox"]["yMin"] + data["underlineThickness"]) * scale;

    // List<ShapePath> paths = [];

    Map<String, Map<String, dynamic>> paths = {};
    List<Map<String, dynamic>> result = [];

    num offsetX = 0.0;
    num offsetY = 0.0;

    num maxWidth = 0.0;

    for (var i = 0; i < chars.length; i++) {
      var char = chars[i];

      if (char == '\n') {
        offsetX = 0;
        offsetY -= lineHeight;
      } else {
        var charPath = paths[char];
        if (charPath == null) {
          var ret = createPath(char, scale, 0.0, 0.0, data);
          paths[char] = ret;
          charPath = ret;
        }

        Map<String, dynamic> charData = {"char": char, "offsetX": offsetX, "offsetY": offsetY};

        result.add(charData);

        offsetX += charPath["offsetX"];
        // paths.add(ret["path"]);

        if (offsetX > maxWidth) {
          maxWidth = offsetX;
        }
      }
    }

    Map<String, dynamic> _data = {"paths": paths, "chars": result, "height": offsetY + lineHeight, "width": maxWidth};

    return _data;
  }

  List<ShapePath> createPaths(String text, num size, Map<String, dynamic> data) {
    // var chars = Array.from ? Array.from( text ) : String( text ).split( '' ); // workaround for IE11, see #13988
    List<String> chars = text.split("");

    num scale = size / data["resolution"];
    num lineHeight = (data["boundingBox"]["yMax"] - data["boundingBox"]["yMin"] + data["underlineThickness"]) * scale;

    List<ShapePath> paths = [];

    num offsetX = 0.0;
    num offsetY = 0.0;

    for (var i = 0; i < chars.length; i++) {
      var char = chars[i];

      if (char == '\n') {
        offsetX = 0;
        offsetY -= lineHeight;
      } else {
        var ret = createPath(char, scale, offsetX, offsetY, data);
        offsetX += ret["offsetX"];
        paths.add(ret["path"]);
      }
    }

    return paths;
  }

  Map<String, dynamic> createPath(String char, num scale, num offsetX, num offsetY, data) {
    var _font = data["font"];
    List<int> _glyphs = List<int>.from(_font.stringToGlyphs(char));

    var gid = _glyphs[0];
    var charPath = _font.glyphToPath(gid);

    var _preScale = (100000) / ((_font.head["unitsPerEm"] ?? 2048) * 72);
    // var _preScale = 1;
    var ha = Math.round(_font.hmtx["aWidth"][gid] * _preScale);

    var path = ShapePath();

    double x = 0.1;
    double y = 0.1;
    double cpx, cpy, cpx1, cpy1, cpx2, cpy2;

    var cmds = charPath["cmds"];
    List<double> crds = List<double>.from(charPath["crds"].map((e) => e.toDouble()));

    // print(" charPath  before scale ....");
    // print(charPath);

    crds = crds.map((n) => Math.round(n * _preScale).toDouble()).toList();

    // print(" charPath ha: ${ha} _preScale: ${_preScale} ");
    // print(cmds);
    // print(crds);

    int i = 0;
    int l = cmds.length;
    for (int j = 0; j < l; j++) {
      var action = cmds[j];

      switch (action) {
        case 'M': // moveTo
          x = crds[i++] * scale + offsetX;
          y = crds[i++] * scale + offsetY;

          path.moveTo(x, y);
          break;

        case 'L': // lineTo

          x = crds[i++] * scale + offsetX;
          y = crds[i++] * scale + offsetY;

          path.lineTo(x, y);

          break;

        case 'Q': // quadraticCurveTo

          cpx = crds[i++] * scale + offsetX;
          cpy = crds[i++] * scale + offsetY;
          cpx1 = crds[i++] * scale + offsetX;
          cpy1 = crds[i++] * scale + offsetY;

          path.quadraticCurveTo(cpx1, cpy1, cpx, cpy);

          break;

        case 'B':
        case 'C': // bezierCurveTo

          cpx = crds[i++] * scale + offsetX;
          cpy = crds[i++] * scale + offsetY;
          cpx1 = crds[i++] * scale + offsetX;
          cpy1 = crds[i++] * scale + offsetY;
          cpx2 = crds[i++] * scale + offsetX;
          cpy2 = crds[i++] * scale + offsetY;

          path.bezierCurveTo(cpx, cpy, cpx1, cpy1, cpx2, cpy2);

          break;
      }
    }

    return {"offsetX": ha * scale, "path": path};
  }

  dispose() {}
}
