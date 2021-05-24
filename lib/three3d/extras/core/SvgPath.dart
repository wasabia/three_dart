part of three_extra;

double DEGS_TO_RADS = Math.PI / 180;
num DIGIT_0 = 48, DIGIT_9 = 57, COMMA = 44, SPACE = 32, PERIOD = 46, MINUS = 45;


class SvgPath {

  
  static transformSVGPath( svgPathStr ) {

    var path = ShapePath();

    int idx = 1;
    String activeCmd;

    double x = 0;
    double y = 0;
    double nx = 0;
    double ny = 0;
    var firstX = null, firstY = null;
    double x1 = 0, x2 = 0, y1 = 0, y2 = 0,
      rx = 0, ry = 0, xar = 0, laf = 0, sf = 0, cx, cy;

    var len = svgPathStr.length;

    Function eatNum = () {

      int sidx;
      double c = 0.0;
      bool isFloat = false;
      String s;

      // eat delims

      while ( idx < len ) {

        c = svgPathStr.codeUnitAt(idx);

        if ( c != COMMA && c != SPACE ) break;

        idx ++;

      }

      if ( c == MINUS ) {

        sidx = idx ++;

      } else {

        sidx = idx;

      }

      // eat number

      while ( idx < len ) {

        c = svgPathStr.codeUnitAt(idx);

        if ( DIGIT_0 <= c && c <= DIGIT_9 ) {

          idx ++;
          continue;

        } else if ( c == PERIOD ) {

          idx ++;
          isFloat = true;
          continue;

        }

        s = svgPathStr.substring( sidx, idx );
        // return isFloat ? num.parse(s) : int.parse( s );

        // print("s: ${s}  sidx: ${sidx} idx: ${idx} c: ${c}"); 

        return num.parse(s);

      }

      s = svgPathStr.substring( sidx );
      // return isFloat ? num.parse( s ) : int.parse( s );
      return num.parse(s);
    };

    Function nextIsNum = () {

      var c;

      // do permanently eat any delims...

      while ( idx < len ) {

        c = svgPathStr.codeUnitAt(idx);

        if ( c != COMMA && c != SPACE ) break;

        idx ++;

      }

      c = svgPathStr.codeUnitAt(idx);
      return ( c == MINUS || ( DIGIT_0 <= c && c <= DIGIT_9 ) );

    };

    var canRepeat;
    activeCmd = svgPathStr[ 0 ];

    while ( idx <= len ) {

      canRepeat = true;

      switch ( activeCmd ) {
        // moveto commands, become lineto's if repeated
        case 'M':
          x = eatNum();
          y = eatNum();

          path.moveTo( x, y );
          activeCmd = 'L';
          firstX = x;
          firstY = y;
          break;
        case 'm':
          x += eatNum();
          y += eatNum();
          path.moveTo( x, y );
          activeCmd = 'l';
          firstX = x;
          firstY = y;
          break;
        case 'Z':
        case 'z':
          canRepeat = false;
          if ( x != firstX || y != firstY ) path.lineTo( firstX, firstY );
          break;

        // - lines!
        case 'L':
        case 'H':
        case 'V':
          nx = ( activeCmd == 'V' ) ? x : eatNum();
          ny = ( activeCmd == 'H' ) ? y : eatNum();
          path.lineTo( nx, ny );
          x = nx;
          y = ny;
          break;

        case 'l':
        case 'h':
        case 'v':
          nx = ( activeCmd == 'v' ) ? x : ( x + eatNum() );
          ny = ( activeCmd == 'h' ) ? y : ( y + eatNum() );
          path.lineTo( nx, ny );
          x = nx;
          y = ny;
          break;

        // - cubic bezier
        case 'C':
          x1 = eatNum(); y1 = eatNum();
          break;
        case 'S':
          if ( activeCmd == 'S' ) {

            x1 = 2 * x - x2;
            y1 = 2 * y - y2;

          }

          x2 = eatNum();
          y2 = eatNum();
          nx = eatNum();
          ny = eatNum();
          path.bezierCurveTo( x1, y1, x2, y2, nx, ny );
          x = nx; y = ny;
          break;

        case 'c':
          x1 = x + eatNum();
          y1 = y + eatNum();
          break;
        case 's':
          if ( activeCmd == 's' ) {

            x1 = 2 * x - x2;
            y1 = 2 * y - y2;

          }

          x2 = x + eatNum();
          y2 = y + eatNum();
          nx = x + eatNum();
          ny = y + eatNum();
          path.bezierCurveTo( x1, y1, x2, y2, nx, ny );
          x = nx; y = ny;
          break;

        // - quadratic bezier
        case 'Q':
          x1 = eatNum(); y1 = eatNum();
          break;
        case 'T':
          if ( activeCmd == 'T' ) {

            x1 = 2 * x - x1;
            y1 = 2 * y - y1;

          }
          nx = eatNum();
          ny = eatNum();
          path.quadraticCurveTo( x1, y1, nx, ny );
          x = nx;
          y = ny;
          break;

        case 'q':
          x1 = x + eatNum();
          y1 = y + eatNum();
          break;
        case 't':
          if ( activeCmd == 't' ) {

            x1 = 2 * x - x1;
            y1 = 2 * y - y1;

          }

          nx = x + eatNum();
          ny = y + eatNum();
          path.quadraticCurveTo( x1, y1, nx, ny );
          x = nx; y = ny;
          break;

        // - elliptical arc
        case 'A':
          rx = eatNum();
          ry = eatNum();
          xar = eatNum() * DEGS_TO_RADS;
          laf = eatNum();
          sf = eatNum();
          nx = eatNum();
          ny = eatNum();
          if ( rx != ry ) print( 'Forcing elliptical arc to be a circular one: ${rx} ${ry}');

          // SVG implementation notes does all the math for us! woo!
          // http://www.w3.org/TR/SVG/implnote.html#ArcImplementationNotes

          // step1, using x1 as x1'

          x1 = Math.cos( xar ) * ( x - nx ) / 2 + Math.sin( xar ) * ( y - ny ) / 2;
          y1 = - Math.sin( xar ) * ( x - nx ) / 2 + Math.cos( xar ) * ( y - ny ) / 2;

          // step 2, using x2 as cx'

          var norm = Math.sqrt( ( rx * rx * ry * ry - rx * rx * y1 * y1 - ry * ry * x1 * x1 ) /
              ( rx * rx * y1 * y1 + ry * ry * x1 * x1 ) );

          if ( laf == sf ) norm = - norm;

          x2 = norm * rx * y1 / ry;
          y2 = norm * - ry * x1 / rx;

          // step 3

          cx = Math.cos( xar ) * x2 - Math.sin( xar ) * y2 + ( x + nx ) / 2;
          cy = Math.sin( xar ) * x2 + Math.cos( xar ) * y2 + ( y + ny ) / 2;

          var u = Vector2( 1, 0 );
          var v = Vector2( ( x1 - x2 ) / rx, ( y1 - y2 ) / ry );

          var startAng = Math.acos( u.dot( v ) / u.length() / v.length() );

          if ( ( ( u.x * v.y ) - ( u.y * v.x ) ) < 0 ) startAng = - startAng;

          // we can reuse 'v' from start angle as our 'u' for delta angle
          u.x = ( - x1 - x2 ) / rx;
          u.y = ( - y1 - y2 ) / ry;

          var deltaAng = Math.acos( v.dot( u ) / v.length() / u.length() );

          // This normalization ends up making our curves fail to triangulate...

          if ( ( ( v.x * u.y ) - ( v.y * u.x ) ) < 0 ) deltaAng = - deltaAng;
          
          // if ( ! sf && deltaAng > 0 ) deltaAng -= Math.PI * 2;
          // if ( sf && deltaAng < 0 ) deltaAng += Math.PI * 2;
          if ( sf == 0 && deltaAng > 0 ) deltaAng -= Math.PI * 2;
          if ( sf != 0 && deltaAng < 0 ) deltaAng += Math.PI * 2;

          // path.absarc( cx, cy, rx, startAng, startAng + deltaAng, sf );
          throw("SvgPath path.absarc");

          x = nx;
          y = ny;
          break;

        default:
          throw("Wrong path command: ${activeCmd}");

      }

      // just reissue the command

      if ( canRepeat && nextIsNum() ) continue;

      var _index = idx ++;

      if(_index < len) {
        activeCmd = svgPathStr[ _index ];
      } else {
        activeCmd = "";
      }
      
    }

    return path;

  }

  


}