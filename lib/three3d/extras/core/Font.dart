part of three_extra;

class Font {
  String type = 'Font';
  Map<String, dynamic> data;
  bool isFont = true;

  Font(this.data) {}

  List<Shape> generateShapes(text, {int size = 100}) {
    List<Shape> shapes = [];
    var paths = createPaths(text, size, this.data);

    for (var p = 0, pl = paths.length; p < pl; p++) {
      // Array.prototype.push.apply( shapes, paths[ p ].toShapes() );
      shapes.addAll(paths[p].toShapes(false, false));
    }

    return shapes;
  }

  dispose() {
    
  }
}

List<ShapePath> createPaths(String text, num size, Map<String, dynamic> data) {
  // var chars = Array.from ? Array.from( text ) : String( text ).split( '' ); // workaround for IE11, see #13988
  List<String> chars = text.split("");

  num scale = size / data["resolution"];
  num line_height = (data["boundingBox"]["yMax"] -
          data["boundingBox"]["yMin"] +
          data["underlineThickness"]) * scale;

  List<ShapePath> paths = [];

  num offsetX = 0.0;
  num offsetY = 0.0;

  


  for (var i = 0; i < chars.length; i++) {
    var char = chars[i];

    if (char == '\n') {
      offsetX = 0;
      offsetY -= line_height;
    } else {
      var ret = createPath(char, scale, offsetX, offsetY, data);
      offsetX += ret["offsetX"];
      paths.add(ret["path"]);
    }
  }

  return paths;
}

Map<String, dynamic> createPath(String char, num scale, num offsetX, num offsetY, data) {
  
  var glyph = data["glyphs"][char] ?? data["glyphs"]['?'];

  if (glyph == null) {
    print("THREE.Font: character ${char} does not exists in font family ${data.familyName}");
    // return null;
    glyph = data["glyphs"]["a"];
  }

  var _font = data["font"];
  var _glyphs = _font.stringToGlyphs(char);
  var _paths = _font.glyphsToPath(_glyphs);



  var path = ShapePath();

  num x = 0.1;
  num y = 0.1;
  num cpx, cpy, cpx1, cpy1, cpx2, cpy2;

  for(var path in _paths) {
    var cmds = path["cmds"];
    var crds = path["crds"];

    int i = 0;
    for (int j = 0, l = cmds.length; j < l;) {
      var action = cmds[j];
      j = j + 1;

      switch (action) {  
        case 'M': // moveTo
          x = int.parse(crds[i++]) * scale + offsetX;
          y = int.parse(crds[i++]) * scale + offsetY;

          path.moveTo(x, y);
          break;

        case 'L': // lineTo

          x = int.parse(crds[i++]) * scale + offsetX;
          y = int.parse(crds[i++]) * scale + offsetY;

          path.lineTo(x, y);

          break;

        case 'Q': // quadraticCurveTo

          cpx = int.parse(crds[i++]) * scale + offsetX;
          cpy = int.parse(crds[i++]) * scale + offsetY;
          cpx1 = int.parse(crds[i++]) * scale + offsetX;
          cpy1 = int.parse(crds[i++]) * scale + offsetY;

          path.quadraticCurveTo(cpx1, cpy1, cpx, cpy);

          break;

        case 'B': // bezierCurveTo

          cpx = int.parse(crds[i++]) * scale + offsetX;
          cpy = int.parse(crds[i++]) * scale + offsetY;
          cpx1 = int.parse(crds[i++]) * scale + offsetX;
          cpy1 = int.parse(crds[i++]) * scale + offsetY;
          cpx2 = int.parse(crds[i++]) * scale + offsetX;
          cpy2 = int.parse(crds[i++]) * scale + offsetY;

          path.bezierCurveTo(cpx1, cpy1, cpx2, cpy2, cpx, cpy);

          break;
      }
    }
  }

  return {"offsetX": glyph["ha"] * scale, "path": path};
}
