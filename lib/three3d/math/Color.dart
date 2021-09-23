part of three_math;

var _colorKeywords = {
  'aliceblue': 0xF0F8FF,
  'antiquewhite': 0xFAEBD7,
  'aqua': 0x00FFFF,
  'aquamarine': 0x7FFFD4,
  'azure': 0xF0FFFF,
  'beige': 0xF5F5DC,
  'bisque': 0xFFE4C4,
  'black': 0x000000,
  'blanchedalmond': 0xFFEBCD,
  'blue': 0x0000FF,
  'blueviolet': 0x8A2BE2,
  'brown': 0xA52A2A,
  'burlywood': 0xDEB887,
  'cadetblue': 0x5F9EA0,
  'chartreuse': 0x7FFF00,
  'chocolate': 0xD2691E,
  'coral': 0xFF7F50,
  'cornflowerblue': 0x6495ED,
  'cornsilk': 0xFFF8DC,
  'crimson': 0xDC143C,
  'cyan': 0x00FFFF,
  'darkblue': 0x00008B,
  'darkcyan': 0x008B8B,
  'darkgoldenrod': 0xB8860B,
  'darkgray': 0xA9A9A9,
  'darkgreen': 0x006400,
  'darkgrey': 0xA9A9A9,
  'darkkhaki': 0xBDB76B,
  'darkmagenta': 0x8B008B,
  'darkolivegreen': 0x556B2F,
  'darkorange': 0xFF8C00,
  'darkorchid': 0x9932CC,
  'darkred': 0x8B0000,
  'darksalmon': 0xE9967A,
  'darkseagreen': 0x8FBC8F,
  'darkslateblue': 0x483D8B,
  'darkslategray': 0x2F4F4F,
  'darkslategrey': 0x2F4F4F,
  'darkturquoise': 0x00CED1,
  'darkviolet': 0x9400D3,
  'deeppink': 0xFF1493,
  'deepskyblue': 0x00BFFF,
  'dimgray': 0x696969,
  'dimgrey': 0x696969,
  'dodgerblue': 0x1E90FF,
  'firebrick': 0xB22222,
  'floralwhite': 0xFFFAF0,
  'forestgreen': 0x228B22,
  'fuchsia': 0xFF00FF,
  'gainsboro': 0xDCDCDC,
  'ghostwhite': 0xF8F8FF,
  'gold': 0xFFD700,
  'goldenrod': 0xDAA520,
  'gray': 0x808080,
  'green': 0x008000,
  'greenyellow': 0xADFF2F,
  'grey': 0x808080,
  'honeydew': 0xF0FFF0,
  'hotpink': 0xFF69B4,
  'indianred': 0xCD5C5C,
  'indigo': 0x4B0082,
  'ivory': 0xFFFFF0,
  'khaki': 0xF0E68C,
  'lavender': 0xE6E6FA,
  'lavenderblush': 0xFFF0F5,
  'lawngreen': 0x7CFC00,
  'lemonchiffon': 0xFFFACD,
  'lightblue': 0xADD8E6,
  'lightcoral': 0xF08080,
  'lightcyan': 0xE0FFFF,
  'lightgoldenrodyellow': 0xFAFAD2,
  'lightgray': 0xD3D3D3,
  'lightgreen': 0x90EE90,
  'lightgrey': 0xD3D3D3,
  'lightpink': 0xFFB6C1,
  'lightsalmon': 0xFFA07A,
  'lightseagreen': 0x20B2AA,
  'lightskyblue': 0x87CEFA,
  'lightslategray': 0x778899,
  'lightslategrey': 0x778899,
  'lightsteelblue': 0xB0C4DE,
  'lightyellow': 0xFFFFE0,
  'lime': 0x00FF00,
  'limegreen': 0x32CD32,
  'linen': 0xFAF0E6,
  'magenta': 0xFF00FF,
  'maroon': 0x800000,
  'mediumaquamarine': 0x66CDAA,
  'mediumblue': 0x0000CD,
  'mediumorchid': 0xBA55D3,
  'mediumpurple': 0x9370DB,
  'mediumseagreen': 0x3CB371,
  'mediumslateblue': 0x7B68EE,
  'mediumspringgreen': 0x00FA9A,
  'mediumturquoise': 0x48D1CC,
  'mediumvioletred': 0xC71585,
  'midnightblue': 0x191970,
  'mintcream': 0xF5FFFA,
  'mistyrose': 0xFFE4E1,
  'moccasin': 0xFFE4B5,
  'navajowhite': 0xFFDEAD,
  'navy': 0x000080,
  'oldlace': 0xFDF5E6,
  'olive': 0x808000,
  'olivedrab': 0x6B8E23,
  'orange': 0xFFA500,
  'orangered': 0xFF4500,
  'orchid': 0xDA70D6,
  'palegoldenrod': 0xEEE8AA,
  'palegreen': 0x98FB98,
  'paleturquoise': 0xAFEEEE,
  'palevioletred': 0xDB7093,
  'papayawhip': 0xFFEFD5,
  'peachpuff': 0xFFDAB9,
  'peru': 0xCD853F,
  'pink': 0xFFC0CB,
  'plum': 0xDDA0DD,
  'powderblue': 0xB0E0E6,
  'purple': 0x800080,
  'rebeccapurple': 0x663399,
  'red': 0xFF0000,
  'rosybrown': 0xBC8F8F,
  'royalblue': 0x4169E1,
  'saddlebrown': 0x8B4513,
  'salmon': 0xFA8072,
  'sandybrown': 0xF4A460,
  'seagreen': 0x2E8B57,
  'seashell': 0xFFF5EE,
  'sienna': 0xA0522D,
  'silver': 0xC0C0C0,
  'skyblue': 0x87CEEB,
  'slateblue': 0x6A5ACD,
  'slategray': 0x708090,
  'slategrey': 0x708090,
  'snow': 0xFFFAFA,
  'springgreen': 0x00FF7F,
  'steelblue': 0x4682B4,
  'tan': 0xD2B48C,
  'teal': 0x008080,
  'thistle': 0xD8BFD8,
  'tomato': 0xFF6347,
  'turquoise': 0x40E0D0,
  'violet': 0xEE82EE,
  'wheat': 0xF5DEB3,
  'white': 0xFFFFFF,
  'whitesmoke': 0xF5F5F5,
  'yellow': 0xFFFF00,
  'yellowgreen': 0x9ACD32
};

Map<String, num> _hslA = {"h": 0, "s": 0, "l": 0};
var _hslB = {"h": 0, "s": 0, "l": 0};

hue2rgb(p, q, t) {
  if (t < 0) t += 1;
  if (t > 1) t -= 1;
  if (t < 1 / 6) return p + (q - p) * 6 * t;
  if (t < 1 / 2) return q;
  if (t < 2 / 3) return p + (q - p) * 6 * (2 / 3 - t);
  return p;
}

SRGBToLinear(c) {
  return (c < 0.04045)
      ? c * 0.0773993808
      : Math.pow(c * 0.9478672986 + 0.0521327014, 2.4);
}

LinearToSRGB(c) {
  return (c < 0.0031308) ? c * 12.92 : 1.055 * (Math.pow(c, 0.41666)) - 0.055;
}

class Color {
  bool isColor = true;
  String type = "Color";

  // TODO WebGLBackground Scene.background 多种类型 Texture or Color
  bool isTexture = false;

  late num r;
  late num g;
  late num b;

  static Map<String, int> NAMES = _colorKeywords;

  Color(num? r, num? g, num? b) {
    this.r = r ?? 1.0;
    this.g = g ?? 1.0;
    this.b = b ?? 1.0;
  }


  // 
  factory Color.setRGB255(int r, int g, int b) {

    var _color = Color(r / 255.0, g / 255.0, b / 255.0);
  
    return _color;
  }

  factory Color.setRGBArray(List<num> cl) {

    var _color = Color(cl[0], cl[1], cl[2]);
  
    return _color;
  }

  // 0 ~ 255 
  factory Color.fromArray(List<int> list) {
    var _color = Color.setRGB255(list[0], list[1], list[2]);
  
    return _color;
  }

  static Color fromHex(hex) {
    return Color(0.0, 0.0, 0.0).setHex(hex);
  }


  equal(color) {
    return r == color.r && g == color.g && b == color.b; 
  }

  setScalar(scalar) {
    this.r = scalar;
    this.g = scalar;
    this.b = scalar;

    return this;
  }

  setHex(hex) {
    hex = Math.floor(hex);

    this.r = (hex >> 16 & 255) / 255;
    this.g = (hex >> 8 & 255) / 255;
    this.b = (hex & 255) / 255;

    return this;
  }

  setRGB(r, g, b) {
    this.r = r;
    this.g = g;
    this.b = b;

    return this;
  }

  setHSL(h, s, l) {
    // h,s,l ranges are in 0.0 - 1.0
    h = MathUtils.euclideanModulo(h, 1);
    s = MathUtils.clamp(s, 0, 1);
    l = MathUtils.clamp(l, 0, 1);

    if (s == 0) {
      this.r = this.g = this.b = l;
    } else {
      var p = l <= 0.5 ? l * (1 + s) : l + s - (l * s);
      var q = (2 * l) - p;

      this.r = hue2rgb(q, p, h + 1 / 3);
      this.g = hue2rgb(q, p, h);
      this.b = hue2rgb(q, p, h - 1 / 3);
    }

    return this;
  }

  setStyle(String style) {
    Function handleAlpha = (string) {
      if (string == null) return;
      if (double.parse(string) < 1) {
        print('THREE.Color: Alpha component of ${style} will be ignored.');
      }
    };

    var _reg1 = RegExp(r"^\#([A-Fa-f\d]+)$");

    if (_reg1.hasMatch(style)) {
      var match = _reg1.firstMatch(style);
      var hex = match!.group(1)!;
      var size = hex.length;

      if (size == 3) {
        // #ff0
        this.r = int.parse(charAt(hex, 0) + charAt(hex, 0), radix: 16) / 255;
        this.g = int.parse(charAt(hex, 1) + charAt(hex, 1), radix: 16) / 255;
        this.b = int.parse(charAt(hex, 2) + charAt(hex, 2), radix: 16) / 255;

        return this;
      } else if (size == 6) {
        // #ff0000
        this.r = int.parse(charAt(hex, 0) + charAt(hex, 1), radix: 16) / 255;
        this.g = int.parse(charAt(hex, 2) + charAt(hex, 3), radix: 16) / 255;
        this.b = int.parse(charAt(hex, 4) + charAt(hex, 5), radix: 16) / 255;

        return this;
      }
    } else {
      var _reg2 = RegExp(r"^((?:rgb|hsl)a?)\(\s*([^\)]*)\)");

      if (_reg2.hasMatch(style)) {
        var match = _reg2.firstMatch(style)!;

        // print(" match.groupCount: ${match.groupCount} 1: ${match.group(1)} 2: ${match.group(2)} ");

     
        var name = match.group(1)!;
        var components = match.group(2)!;

        switch (name) {
          case 'rgb':
          case 'rgba':
            var _colorReg1 = RegExp(
                r"^(\d+)\s*,\s*(\d+)\s*,\s*(\d+)\s*(?:,\s*(\d*\.?\d+)\s*)?$");
            if (_colorReg1.hasMatch(components)) {
              var match1 = _colorReg1.firstMatch(components)!;

              var c1 = match1.group(1)!;
              var c2 = match1.group(2)!;
              var c3 = match1.group(3)!;
              var c4 = match1.group(4);
              // rgb(255,0,0) rgba(255,0,0,0.5)
              this.r = Math.min(255, int.parse(c1, radix: 10)) / 255;
              this.g = Math.min(255, int.parse(c2, radix: 10)) / 255;
              this.b = Math.min(255, int.parse(c3, radix: 10)) / 255;

              handleAlpha(c4);

              return this;
            } else {
              var _colorReg2 = RegExp(
                  r"^(\d+)\%\s*,\s*(\d+)\%\s*,\s*(\d+)\%\s*(?:,\s*(\d*\.?\d+)\s*)?$");
              if (_colorReg2.hasMatch(components)) {
                var match2 = _colorReg2.firstMatch(components)!;

                var c1 = match2.group(1)!;
                var c2 = match2.group(2)!;
                var c3 = match2.group(3)!;
                var c4 = match2.group(4);

                // rgb(100%,0%,0%) rgba(100%,0%,0%,0.5)
                this.r = Math.min(100, int.parse(c1, radix: 10)) / 100;
                this.g = Math.min(100, int.parse(c2, radix: 10)) / 100;
                this.b = Math.min(100, int.parse(c3, radix: 10)) / 100;

                handleAlpha(c4);

                return this;
              }
            }

            break;

          case 'hsl':
          case 'hsla':
            var _colorReg3 = RegExp(
                r"^(\d*\.?\d+)\s*,\s*(\d+)\%\s*,\s*(\d+)\%\s*(?:,\s*(\d*\.?\d+)\s*)?$");
            if (_colorReg3.hasMatch(components)) {
              var match3 = _colorReg3.firstMatch(components)!;

              var c1 = match3.group(1)!;
              var c2 = match3.group(2)!;
              var c3 = match3.group(3)!;
              var c4 = match3.group(4);

              // hsl(120,50%,50%) hsla(120,50%,50%,0.5)
              var h = double.parse(c1) / 360;
              var s = int.parse(c2, radix: 10) / 100;
              var l = int.parse(c3, radix: 10) / 100;

              handleAlpha(c4);

              return this.setHSL(h, s, l);
            }

            break;
        }
      } else {

        if ( style != null && style.length > 0 ) {
          return this.setColorName( style );
        }

      }
    }

    // #ff0000
    // var hex = style.replaceAll("#", "");
    // var size = hex.length;

    // this.r = int.parse( hex[0] + hex[1], radix: 16 ) / 255;
    // this.g = int.parse( hex[2] + hex[3], radix: 16 ) / 255;
    // this.b = int.parse( hex[4] + hex[5], radix: 16 ) / 255;

    return this;
  }

  setColorName(String style) {
    // color keywords
    var hex = _colorKeywords[ style.toLowerCase() ];

    if (hex != null) {
      // red
      this.setHex(hex);
    } else {
      // unknown color
      print('THREE.Color: Unknown color ' + style);
    }

    return this;
  }

  clone() {
    return Color(this.r, this.g, this.b);
  }

  copy(color) {
    this.r = color.r;
    this.g = color.g;
    this.b = color.b;

    return this;
  }

  copyGammaToLinear(color, {double gammaFactor = 2.0}) {
    this.r = Math.pow(color.r, gammaFactor).toDouble();
    this.g = Math.pow(color.g, gammaFactor).toDouble();
    this.b = Math.pow(color.b, gammaFactor).toDouble();

    return this;
  }

  copyLinearToGamma(color, {double gammaFactor = 2.0}) {
    var safeInverse = (gammaFactor > 0) ? (1.0 / gammaFactor) : 1.0;

    this.r = Math.pow(color.r, safeInverse).toDouble();
    this.g = Math.pow(color.g, safeInverse).toDouble();
    this.b = Math.pow(color.b, safeInverse).toDouble();

    return this;
  }

  convertGammaToLinear(gammaFactor) {
    this.copyGammaToLinear(this, gammaFactor: gammaFactor);

    return this;
  }

  convertLinearToGamma(gammaFactor) {
    this.copyLinearToGamma(this, gammaFactor: gammaFactor);

    return this;
  }

  copySRGBToLinear(color) {
    this.r = SRGBToLinear(color.r);
    this.g = SRGBToLinear(color.g);
    this.b = SRGBToLinear(color.b);

    return this;
  }

  copyLinearToSRGB(color) {
    this.r = LinearToSRGB(color.r);
    this.g = LinearToSRGB(color.g);
    this.b = LinearToSRGB(color.b);

    return this;
  }

  convertSRGBToLinear() {
    this.copySRGBToLinear(this);

    return this;
  }

  convertLinearToSRGB() {
    this.copyLinearToSRGB(this);

    return this;
  }

  getHex() {
    return (this.r * 255).toInt() << 16 ^
        (this.g * 255).toInt() << 8 ^
        (this.b * 255).toInt() << 0;
  }

  getHexString() {
    return ('000000' + this.getHex().toString(16)).substring(-6);
  }

  // target map target = { "h": 0, "s": 0, "l": 0 };
  getHSL( target ) {

		// h,s,l ranges are in 0.0 - 1.0
		var r = this.r, g = this.g, b = this.b;

		var max = Math.max3( r, g, b );
		var min = Math.min3( r, g, b );

		var hue, saturation;
		var lightness = ( min + max ) / 2.0;

		if ( min == max ) {

			hue = 0;
			saturation = 0;

		} else {

			var delta = max - min;

			saturation = lightness <= 0.5 ? delta / ( max + min ) : delta / ( 2 - max - min );

			if ( max == r ) {
        hue = ( g - b ) / delta + ( g < b ? 6 : 0 );
      } else if (max == g) {
        hue = ( b - r ) / delta + 2;
      } else if(max == b) {
        hue = ( r - g ) / delta + 4;
      }
	

			hue /= 6;

		}

		target["h"] = hue;
		target["s"] = saturation;
		target["l"] = lightness;

		return target;

	}

  getStyle() {

		return 'rgb(${( ( this.r * 255 ).toInt() | 0 )},${( ( this.g * 255 ).toInt() | 0 )},${( ( this.b * 255 ).toInt() | 0 )})';

	}

	offsetHSL( h, s, l ) {

		this.getHSL( _hslA );

		_hslA["h"] = _hslA["h"]! + h; 
    _hslA["s"] = _hslA["s"]! + s; 
    _hslA["l"] = _hslA["l"]! + l;

		this.setHSL( _hslA["h"], _hslA["s"], _hslA["l"] );

		return this;

	}

  add(color) {
    this.r += color.r;
    this.g += color.g;
    this.b += color.b;

    return this;
  }

  addColors(color1, color2) {
    this.r = color1.r + color2.r;
    this.g = color1.g + color2.g;
    this.b = color1.b + color2.b;

    return this;
  }

  addScalar(s) {
    this.r += s;
    this.g += s;
    this.b += s;

    return this;
  }

  sub(color) {
    this.r = Math.max(0, this.r - color.r);
    this.g = Math.max(0, this.g - color.g);
    this.b = Math.max(0, this.b - color.b);

    return this;
  }

  multiply(color) {
    this.r *= color.r;
    this.g *= color.g;
    this.b *= color.b;

    return this;
  }

  multiplyScalar(s) {
    this.r *= s;
    this.g *= s;
    this.b *= s;

    return this;
  }

  lerp(color, alpha) {
    this.r += (color.r - this.r) * alpha;
    this.g += (color.g - this.g) * alpha;
    this.b += (color.b - this.b) * alpha;

    return this;
  }

  lerpColors( Color color1, Color color2, num alpha ) {

		this.r = color1.r + ( color2.r - color1.r ) * alpha;
		this.g = color1.g + ( color2.g - color1.g ) * alpha;
		this.b = color1.b + ( color2.b - color1.b ) * alpha;

		return this;

	}

	lerpHSL( color, alpha ) {

		this.getHSL( _hslA );
		color.getHSL( _hslB );

		var h = MathUtils.lerp( _hslA["h"], _hslB["h"], alpha );
		var s = MathUtils.lerp( _hslA["s"], _hslB["s"], alpha );
		var l = MathUtils.lerp( _hslA["l"], _hslB["l"], alpha );

		this.setHSL( h, s, l );

		return this;

	}


  equals(c) {
    return (c.r == this.r) && (c.g == this.g) && (c.b == this.b);
  }

  isBlack() {

		return ( this.r == 0 ) && ( this.g == 0 ) && ( this.b == 0 );

	}

  fromArray(array, {int offset = 0}) {
    this.r = array[offset];
    this.g = array[offset + 1];
    this.b = array[offset + 2];

    return this;
  }

  toArray(array, {int offset = 0}) {
    array[offset] = this.r;
    array[offset + 1] = this.g;
    array[offset + 2] = this.b;

    return array;
  }

  fromBufferAttribute(attribute, index) {
    this.r = attribute.getX(index);
    this.g = attribute.getY(index);
    this.b = attribute.getZ(index);

    if (attribute.normalized == true) {
      // assuming Uint8Array

      this.r /= 255;
      this.g /= 255;
      this.b /= 255;
    }

    return this;
  }

  List<num> toJSON() {
    return [this.r, this.g, this.b];
  }

  Color.fromJson(Map<String, dynamic> json) {
    r = json['r'];
    g = json['g'];
    b = json['b'];
  }

  Map<String, dynamic> toJson() {
    return {
      'r': r,
      'g': g,
      'b': b
    };
  }
}
