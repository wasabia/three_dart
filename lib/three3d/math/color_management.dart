import 'package:three_dart/three3d/constants.dart';
import 'package:three_dart/three3d/math/index.dart';

double sRGBToLinear(double c) {
  return (c < 0.04045) ? c * 0.0773993808 : Math.pow(c * 0.9478672986 + 0.0521327014, 2.4).toDouble();
}

double linearToSRGB(double c) {
  return (c < 0.0031308) ? c * 12.92 : 1.055 * (Math.pow(c, 0.41666)) - 0.055;
}

// JavaScript RGB-to-RGB transforms, defined as
// FN[InputColorSpace][OutputColorSpace] callback functions.
var fn = {
  SRGBColorSpace: {LinearSRGBColorSpace: sRGBToLinear},
  LinearSRGBColorSpace: {SRGBColorSpace: linearToSRGB},
};

class ColorManagement {
  static bool legacyMode = true;

  static get workingColorSpace {
    return LinearSRGBColorSpace;
  }

  static set workingColorSpace(colorSpace) {
    print('three.ColorManagement: .workingColorSpace is readonly.');
  }

  static convert(color, sourceColorSpace, targetColorSpace) {
    if (legacyMode || sourceColorSpace == targetColorSpace || !sourceColorSpace || !targetColorSpace) {
      return color;
    }

    if (fn[sourceColorSpace] != null && fn[sourceColorSpace]![targetColorSpace] != null) {
      var fun = fn[sourceColorSpace]![targetColorSpace]!;

      color.r = fun(color.r);
      color.g = fun(color.g);
      color.b = fun(color.b);

      return color;
    }

    throw ('Unsupported color space conversion.');
  }

  static fromWorkingColorSpace(color, targetColorSpace) {
    return convert(color, workingColorSpace, targetColorSpace);
  }

  static toWorkingColorSpace(color, sourceColorSpace) {
    return convert(color, sourceColorSpace, workingColorSpace);
  }
}
