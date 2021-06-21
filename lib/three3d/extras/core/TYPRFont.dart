part of three_extra;

class TYPRFont extends Font {
  

  TYPRFont(data) {
    this.data = data;
  }

  List<Shape> generateShapes(text, {int size = 100}) {
    List<Shape> shapes = [];
    var paths = createPaths(text, size, this.data);

    for (var p = 0, pl = paths.length; p < pl; p++) {
      // Array.prototype.push.apply( shapes, paths[ p ].toShapes() );
      shapes.addAll(paths[p].toShapes(true, true));
    }

    return shapes;
  }


  List<ShapePath> createPaths(String text, num size, Map<String, dynamic> data) {
    // var chars = Array.from ? Array.from( text ) : String( text ).split( '' ); // workaround for IE11, see #13988
    List<String> chars = text.split("");

    num scale = size / data["resolution"];
    num line_height = (data["boundingBox"]["yMax"] -
            data["boundingBox"]["yMin"] +
            data["underlineThickness"]) *
        scale;

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
    
    var _font = data["font"];
    List<int> _glyphs = List<int>.from(_font.stringToGlyphs(char));

    var gid = _glyphs[0];
    var charPath = _font.glyphToPath(gid);


    var _preScale = ( 100000 ) / ( ( _font.head["unitsPerEm"] ?? 2048 ) * 72 );
    // var _preScale = 1;
    var ha = Math.round(_font.hmtx["aWidth"][gid] * _preScale);
    


    var path = ShapePath();

    num x = 0.1;
    num y = 0.1;  
    num cpx, cpy, cpx1, cpy1, cpx2, cpy2;

    var cmds = charPath["cmds"];
    List<num> crds = List<num>.from(charPath["crds"]);

    // print(" charPath  before scale ....");
    // print(crds);

    crds = crds.map((n) => Math.round(n * _preScale)).toList();

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
        case 'C':  // bezierCurveTo

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


  dispose() {
    
  }
}
