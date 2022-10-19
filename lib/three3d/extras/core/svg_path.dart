import 'package:three_dart/three3d/extras/core/shape_path.dart';
import 'package:three_dart/three3d/math/index.dart';

double degsToRads = Math.pi / 180;
num digit0 = 48, digit9 = 57, comma = 44, space = 32, period = 46, minus = 45;

class SvgPath {
  static transformSVGPath(svgPathStr) {
    var path = ShapePath();

    int idx = 1;
    String activeCmd;

    double x = 0;
    double y = 0;
    double nx = 0;
    double ny = 0;
    double firstX = 0, firstY = 0;
    double x1 = 0, x2 = 0, y1 = 0, y2 = 0, rx = 0, ry = 0, xar = 0, laf = 0, sf = 0;

    var len = svgPathStr.length;

    double eatNum() {
      int sidx;
      double c = 0.0;
      String s;

      // eat delims

      while (idx < len) {
        c = svgPathStr.codeUnitAt(idx);

        if (c != comma && c != space) break;

        idx++;
      }

      if (c == minus) {
        sidx = idx++;
      } else {
        sidx = idx;
      }

      // eat number

      while (idx < len) {
        c = svgPathStr.codeUnitAt(idx);

        if (digit0 <= c && c <= digit9) {
          idx++;
          continue;
        } else if (c == period) {
          idx++;
          continue;
        }

        s = svgPathStr.substring(sidx, idx);
        // return isFloat ? num.parse(s) : int.parse( s );

        // print("s: ${s}  sidx: ${sidx} idx: ${idx} c: ${c}");

        return double.parse(s);
      }

      s = svgPathStr.substring(sidx);
      // return isFloat ? num.parse( s ) : int.parse( s );
      return double.parse(s);
    }

    bool nextIsNum() {
      var c;

      // do permanently eat any delims...

      while (idx < len) {
        c = svgPathStr.codeUnitAt(idx);

        if (c != comma && c != space) break;

        idx++;
      }

      c = svgPathStr.codeUnitAt(idx);
      return (c == minus || (digit0 <= c && c <= digit9));
    }

    bool canRepeat;
    activeCmd = svgPathStr[0];

    while (idx <= len) {
      canRepeat = true;

      switch (activeCmd) {
        // moveto commands, become lineto's if repeated
        case 'M':
          x = eatNum();
          y = eatNum();

          path.moveTo(x, y);
          activeCmd = 'L';
          firstX = x;
          firstY = y;
          break;
        case 'm':
          x += eatNum();
          y += eatNum();
          path.moveTo(x, y);
          activeCmd = 'l';
          firstX = x;
          firstY = y;
          break;
        case 'Z':
        case 'z':
          canRepeat = false;
          if (x != firstX || y != firstY) path.lineTo(firstX, firstY);
          break;

        // - lines!
        case 'L':
        case 'H':
        case 'V':
          nx = (activeCmd == 'V') ? x : eatNum();
          ny = (activeCmd == 'H') ? y : eatNum();
          path.lineTo(nx, ny);
          x = nx;
          y = ny;
          break;

        case 'l':
        case 'h':
        case 'v':
          nx = (activeCmd == 'v') ? x : (x + eatNum());
          ny = (activeCmd == 'h') ? y : (y + eatNum());
          path.lineTo(nx, ny);
          x = nx;
          y = ny;
          break;

        // - cubic bezier
        case 'C':
          x1 = eatNum();
          y1 = eatNum();
          break;
        case 'S':
          if (activeCmd == 'S') {
            x1 = 2 * x - x2;
            y1 = 2 * y - y2;
          }

          x2 = eatNum();
          y2 = eatNum();
          nx = eatNum();
          ny = eatNum();
          path.bezierCurveTo(x1, y1, x2, y2, nx, ny);
          x = nx;
          y = ny;
          break;

        case 'c':
          x1 = x + eatNum();
          y1 = y + eatNum();
          break;
        case 's':
          if (activeCmd == 's') {
            x1 = 2 * x - x2;
            y1 = 2 * y - y2;
          }

          x2 = x + eatNum();
          y2 = y + eatNum();
          nx = x + eatNum();
          ny = y + eatNum();
          path.bezierCurveTo(x1, y1, x2, y2, nx, ny);
          x = nx;
          y = ny;
          break;

        // - quadratic bezier
        case 'Q':
          x1 = eatNum();
          y1 = eatNum();
          break;
        case 'T':
          if (activeCmd == 'T') {
            x1 = 2 * x - x1;
            y1 = 2 * y - y1;
          }
          nx = eatNum();
          ny = eatNum();
          path.quadraticCurveTo(x1, y1, nx, ny);
          x = nx;
          y = ny;
          break;

        case 'q':
          x1 = x + eatNum();
          y1 = y + eatNum();
          break;
        case 't':
          if (activeCmd == 't') {
            x1 = 2 * x - x1;
            y1 = 2 * y - y1;
          }

          nx = x + eatNum();
          ny = y + eatNum();
          path.quadraticCurveTo(x1, y1, nx, ny);
          x = nx;
          y = ny;
          break;

        // - elliptical arc
        case 'A':
          rx = eatNum();
          ry = eatNum();
          xar = eatNum() * degsToRads;
          laf = eatNum();
          sf = eatNum();
          nx = eatNum();
          ny = eatNum();
          if (rx != ry) {
            print('Forcing elliptical arc to be a circular one: $rx $ry');
          }

          // SVG implementation notes does all the math for us! woo!
          // http://www.w3.org/TR/SVG/implnote.html#ArcImplementationNotes

          // step1, using x1 as x1'

          x1 = Math.cos(xar) * (x - nx) / 2 + Math.sin(xar) * (y - ny) / 2;
          y1 = -Math.sin(xar) * (x - nx) / 2 + Math.cos(xar) * (y - ny) / 2;

          // step 2, using x2 as cx'

          var norm = Math.sqrt(
              (rx * rx * ry * ry - rx * rx * y1 * y1 - ry * ry * x1 * x1) / (rx * rx * y1 * y1 + ry * ry * x1 * x1));

          if (laf == sf) norm = -norm;

          x2 = norm * rx * y1 / ry;
          y2 = norm * -ry * x1 / rx;

          // step 3

          var u = Vector2(1, 0);
          var v = Vector2((x1 - x2) / rx, (y1 - y2) / ry);

          var startAng = Math.acos(u.dot(v) / u.length() / v.length());

          if (((u.x * v.y) - (u.y * v.x)) < 0) startAng = -startAng;

          // we can reuse 'v' from start angle as our 'u' for delta angle
          u.x = (-x1 - x2) / rx;
          u.y = (-y1 - y2) / ry;

          var deltaAng = Math.acos(v.dot(u) / v.length() / u.length());

          // This normalization ends up making our curves fail to triangulate...

          if (((v.x * u.y) - (v.y * u.x)) < 0) deltaAng = -deltaAng;

          // if ( ! sf && deltaAng > 0 ) deltaAng -= Math.PI * 2;
          // if ( sf && deltaAng < 0 ) deltaAng += Math.PI * 2;
          if (sf == 0 && deltaAng > 0) deltaAng -= Math.pi * 2;
          if (sf != 0 && deltaAng < 0) deltaAng += Math.pi * 2;

          // path.absarc( cx, cy, rx, startAng, startAng + deltaAng, sf );
          throw ("SvgPath path.absarc");

        default:
          throw ("Wrong path command: $activeCmd");
      }

      // just reissue the command

      if (canRepeat && nextIsNum()) continue;

      var _index = idx++;

      if (_index < len) {
        activeCmd = svgPathStr[_index];
      } else {
        activeCmd = "";
      }
    }

    return path;
  }
}
