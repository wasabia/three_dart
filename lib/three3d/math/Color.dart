part of three_math;

const Map<String, int> _colorKeywords = {
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

class _HslData {
  double h = 0, s = 0, l = 0;
}

class _RgbData {
  double r = 0, g = 0, b = 0;
}

_RgbData _rgb = _RgbData();
_HslData _hslA = _HslData();
_HslData _hslB = _HslData();

double hue2rgb(double p, double q, double t) {
  if (t < 0) t += 1;
  if (t > 1) t -= 1;
  if (t < 1 / 6) return p + (q - p) * 6 * t;
  if (t < 1 / 2) return q;
  if (t < 2 / 3) return p + (q - p) * 6 * (2 / 3 - t);
  return p;
}

toComponents(source, target) {
  target.r = source.r;
  target.g = source.g;
  target.b = source.b;

  return target;
}

class Color {
  bool isColor = true;
  String type = "Color";

  // TODO WebGLBackground Scene.background 多种类型 Texture or Color
  // need fix
  bool isTexture = false;

  // set default value
  // var c = Color();
  // r g b is all 1.0;
  double r = 1.0;
  double g = 1.0;
  double b = 1.0;

  static const Map<String, int> NAMES = _colorKeywords;

  /// Color class.
  /// r g b value range (0.0 ~ 1.0)
  /// var color = Color(0xff00ff);
  /// var color = Color(1.0, 0.0, 1.0);
  /// var color = Color("#ff00ee");
  /// r is THREE.Color, hex or string
  Color([r, double? g, double? b]) {
    if (g == null && b == null) {
      // r is THREE.Color, hex or string
      set(r);
    } else {
      setRGB(r.toDouble(), g, b);
    }
  }

  // value Color | int | String
  Color set<T>(T? value) {
    if (value == null) {
      return this;
    }

    if (value is Color) {
      copy(value);
    } else if (value is int) {
      setHex(value);
    } else if (value is String) {
      setStyle(value);
    } else {
      throw (" Color set use not support type ${value.runtimeType} value: $value ");
    }

    return this;
  }

  //
  factory Color.setRGB255(int r, int g, int b) {
    var _color = Color(r / 255.0, g / 255.0, b / 255.0);

    return _color;
  }

  factory Color.setRGBArray(List<double> cl) {
    var _color = Color(cl[0], cl[1], cl[2]);

    return _color;
  }

  // 0 ~ 255
  factory Color.fromArray(List<int> list) {
    var _color = Color.setRGB255(list[0], list[1], list[2]);

    return _color;
  }

  static Color fromHex(int hex) {
    return Color(0.0, 0.0, 0.0).setHex(hex);
  }

  bool equal(Color color) {
    return r == color.r && g == color.g && b == color.b;
  }

  Color setScalar(double scalar) {
    r = scalar;
    g = scalar;
    b = scalar;

    return this;
  }

  Color setHex(int hex, [String colorSpace = SRGBColorSpace]) {
    hex = Math.floor(hex);

    r = (hex >> 16 & 255) / 255;
    g = (hex >> 8 & 255) / 255;
    b = (hex & 255) / 255;

    ColorManagement.toWorkingColorSpace(this, colorSpace);

    return this;
  }

  Color setRGB(
      [double? r,
      double? g,
      double? b,
      String colorSpace = LinearSRGBColorSpace]) {
    this.r = r ?? 1.0;
    this.g = g ?? 1.0;
    this.b = b ?? 1.0;

    ColorManagement.toWorkingColorSpace(this, colorSpace);

    return this;
  }

  Color setHSL(double h, double s, double l,
      [String colorSpace = LinearSRGBColorSpace]) {
    // h,s,l ranges are in 0.0 - 1.0
    h = MathUtils.euclideanModulo(h, 1).toDouble();
    s = MathUtils.clamp(s, 0, 1);
    l = MathUtils.clamp(l, 0, 1);

    if (s == 0) {
      r = g = b = l;
    } else {
      var p = l <= 0.5 ? l * (1 + s) : l + s - (l * s);
      var q = (2 * l) - p;

      r = hue2rgb(q, p, h + 1 / 3);
      g = hue2rgb(q, p, h);
      b = hue2rgb(q, p, h - 1 / 3);
    }

    ColorManagement.toWorkingColorSpace(this, colorSpace);

    return this;
  }

  Color setStyle([String style = '', String colorSpace = SRGBColorSpace]) {
    void handleAlpha(String? string) {
      if (string == null) return;
      if (double.parse(string) < 1) {
        print('THREE.Color: Alpha component of $style will be ignored.');
      }
    }

    var _reg1 = RegExp(r"^\#([A-Fa-f\d]+)$");

    if (_reg1.hasMatch(style)) {
      var match = _reg1.firstMatch(style);
      var hex = match!.group(1)!;
      var size = hex.length;

      if (size == 3) {
        // #ff0
        r = int.parse(charAt(hex, 0) + charAt(hex, 0), radix: 16) / 255;
        g = int.parse(charAt(hex, 1) + charAt(hex, 1), radix: 16) / 255;
        b = int.parse(charAt(hex, 2) + charAt(hex, 2), radix: 16) / 255;

        return this;
      } else if (size == 6) {
        // #ff0000
        r = int.parse(charAt(hex, 0) + charAt(hex, 1), radix: 16) / 255;
        g = int.parse(charAt(hex, 2) + charAt(hex, 3), radix: 16) / 255;
        b = int.parse(charAt(hex, 4) + charAt(hex, 5), radix: 16) / 255;

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
              r = Math.min(255, int.parse(c1, radix: 10)) / 255;
              g = Math.min(255, int.parse(c2, radix: 10)) / 255;
              b = Math.min(255, int.parse(c3, radix: 10)) / 255;

              ColorManagement.toWorkingColorSpace(this, colorSpace);

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
                r = Math.min(100, int.parse(c1, radix: 10)) / 100;
                g = Math.min(100, int.parse(c2, radix: 10)) / 100;
                b = Math.min(100, int.parse(c3, radix: 10)) / 100;

                ColorManagement.toWorkingColorSpace(this, colorSpace);

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

              return setHSL(h, s, l, colorSpace);
            }

            break;
        }
      } else {
        if (style.isNotEmpty) {
          return setColorName(style);
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

  Color setColorName(String style, [String colorSpace = SRGBColorSpace]) {
    // color keywords
    var hex = _colorKeywords[style.toLowerCase()];

    if (hex != null) {
      // red
      setHex(hex, colorSpace);
    } else {
      // unknown color
      print('THREE.Color: Unknown color ' + style);
    }

    return this;
  }

  Color clone() {
    return Color(r, g, b);
  }

  Color copy(Color color) {
    r = color.r;
    g = color.g;
    b = color.b;

    return this;
  }

  Color copyGammaToLinear(Color color, [double gammaFactor = 2.0]) {
    r = Math.pow(color.r, gammaFactor).toDouble();
    g = Math.pow(color.g, gammaFactor).toDouble();
    b = Math.pow(color.b, gammaFactor).toDouble();

    return this;
  }

  Color copyLinearToGamma(Color color, [double gammaFactor = 2.0]) {
    var safeInverse = (gammaFactor > 0) ? (1.0 / gammaFactor) : 1.0;

    r = Math.pow(color.r, safeInverse).toDouble();
    g = Math.pow(color.g, safeInverse).toDouble();
    b = Math.pow(color.b, safeInverse).toDouble();

    return this;
  }

  Color convertGammaToLinear([double? gammaFactor]) {
    if (gammaFactor == null) {
      copyGammaToLinear(this);
    } else {
      copyGammaToLinear(this, gammaFactor);
    }

    return this;
  }

  Color convertLinearToGamma([double? gammaFactor]) {
    if (gammaFactor == null) {
      copyLinearToGamma(this);
    } else {
      copyLinearToGamma(this, gammaFactor);
    }

    return this;
  }

  Color copySRGBToLinear(Color color) {
    r = SRGBToLinear(color.r);
    g = SRGBToLinear(color.g);
    b = SRGBToLinear(color.b);

    return this;
  }

  Color copyLinearToSRGB(Color color) {
    r = LinearToSRGB(color.r);
    g = LinearToSRGB(color.g);
    b = LinearToSRGB(color.b);

    return this;
  }

  Color convertSRGBToLinear() {
    copySRGBToLinear(this);

    return this;
  }

  Color convertLinearToSRGB() {
    copyLinearToSRGB(this);

    return this;
  }

  int getHex([String colorSpace = SRGBColorSpace]) {
    ColorManagement.fromWorkingColorSpace(toComponents(this, _rgb), colorSpace);

    return (r * 255).toInt() << 16 ^
        (g * 255).toInt() << 8 ^
        (b * 255).toInt() << 0;
  }

  String getHexString([String colorSpace = SRGBColorSpace]) {
    String _str = ('000000' + getHex().toRadixString(16));
    return _str.substring(_str.length - 6);
  }

  // target map target = { "h": 0, "s": 0, "l": 0 };
  _HslData getHSL(_HslData target, [String colorSpace = LinearSRGBColorSpace]) {
    // h,s,l ranges are in 0.0 - 1.0
    ColorManagement.fromWorkingColorSpace(toComponents(this, _rgb), colorSpace);

    double r = _rgb.r, g = _rgb.g, b = _rgb.b;

    double max = Math.max3(r!, g!, b!).toDouble();
    double min = Math.min3(r, g, b).toDouble();

    double hue, saturation;
    double lightness = (min + max) / 2.0;

    if (min == max) {
      hue = 0;
      saturation = 0;
    } else {
      double delta = max - min;

      saturation =
          lightness <= 0.5 ? delta / (max + min) : delta / (2 - max - min);

      if (max == r) {
        hue = (g - b) / delta + (g < b ? 6 : 0);
      } else if (max == g) {
        hue = (b - r) / delta + 2;
        //} else if (max == b) {
      } else {
        hue = (r - g) / delta + 4;
      }

      hue /= 6;
    }

    target.h = hue;
    target.s = saturation;
    target.l = lightness;

    return target;
  }

  getRGB(target, [String colorSpace = LinearSRGBColorSpace]) {
    ColorManagement.fromWorkingColorSpace(toComponents(this, _rgb), colorSpace);

    target.r = _rgb.r;
    target.g = _rgb.g;
    target.b = _rgb.b;

    return target;
  }

  getStyle([String colorSpace = SRGBColorSpace]) {
    ColorManagement.fromWorkingColorSpace(toComponents(this, _rgb), colorSpace);

    if (colorSpace != SRGBColorSpace) {
      // Requires CSS Color Module Level 4 (https://www.w3.org/TR/css-color-4/).
      return "color($colorSpace  ${_rgb.r} ${_rgb.g} ${_rgb.b})";
    }

    return "rgb(${(_rgb.r * 255)},${(_rgb.g * 255)},${(_rgb.b * 255)})";
  }

  Color offsetHSL(double h, double s, double l) {
    getHSL(_hslA);

    _hslA.h = _hslA.h + h;
    _hslA.s = _hslA.s + s;
    _hslA.l = _hslA.l + l;

    setHSL(_hslA.h, _hslA.s, _hslA.l);

    return this;
  }

  Color add(Color color) {
    r += color.r;
    g += color.g;
    b += color.b;

    return this;
  }

  Color addColors(Color color1, Color color2) {
    r = color1.r + color2.r;
    g = color1.g + color2.g;
    b = color1.b + color2.b;

    return this;
  }

  Color addScalar(num s) {
    r += s;
    g += s;
    b += s;

    return this;
  }

  Color sub(Color color) {
    r = Math.max(0.0, r - color.r);
    g = Math.max(0.0, g - color.g);
    b = Math.max(0.0, b - color.b);

    return this;
  }

  Color multiply(Color color) {
    r *= color.r;
    g *= color.g;
    b *= color.b;

    return this;
  }

  Color multiplyScalar(num s) {
    r *= s;
    g *= s;
    b *= s;

    return this;
  }

  Color lerp(Color color, num alpha) {
    r += (color.r - r) * alpha;
    g += (color.g - g) * alpha;
    b += (color.b - b) * alpha;

    return this;
  }

  Color lerpColors(Color color1, Color color2, num alpha) {
    r = color1.r + (color2.r - color1.r) * alpha;
    g = color1.g + (color2.g - color1.g) * alpha;
    b = color1.b + (color2.b - color1.b) * alpha;

    return this;
  }

  Color lerpHSL(Color color, num alpha) {
    getHSL(_hslA);
    color.getHSL(_hslB);

    var h = MathUtils.lerp(_hslA.h, _hslB.h, alpha).toDouble();
    var s = MathUtils.lerp(_hslA.s, _hslB.s, alpha).toDouble();
    var l = MathUtils.lerp(_hslA.l, _hslB.l, alpha).toDouble();

    setHSL(h, s, l);

    return this;
  }

  bool equals(Color c) {
    return (c.r == r) && (c.g == g) && (c.b == b);
  }

  bool isBlack() {
    return (r == 0) && (g == 0) && (b == 0);
  }

  Color fromArray(List<double> array, [int offset = 0]) {
    r = array[offset];
    g = array[offset + 1];
    b = array[offset + 2];

    return this;
  }

  /// dart array can not expand default
  /// so have to set array length enough first.
  // It's working, but ugly. consider to adds a new function:
  // toBufferAttribute(BufferAttribute attribute, int index) ???
  toArray([array, int offset = 0]) {
    array ??= List<double>.filled(3, 0.0);

    array[offset] = r;
    array[offset + 1] = g;
    array[offset + 2] = b;

    return array;
  }

  Color fromBufferAttribute(BufferAttribute attribute, int index) {
    r = attribute.getX(index)!.toDouble();
    g = attribute.getY(index)!.toDouble();
    b = attribute.getZ(index)!.toDouble();

    if (attribute.normalized == true) {
      // assuming Uint8Array

      r /= 255;
      g /= 255;
      b /= 255;
    }

    return this;
  }

  int toJSON() {
    return getHex();
  }
}
