import 'package:three_dart/three_dart.dart';

/// A Track that interpolates Strings

class StringKeyframeTrack extends KeyframeTrack {
  StringKeyframeTrack(name, times, values, interpolation) : super(name, times, values, interpolation) {
    valueTypeName = 'string';
    valueBufferType = "Array";

    defaultInterpolation = InterpolateDiscrete;
  }

  @override
  Interpolant? interpolantFactoryMethodLinear(result) => null;

  @override
  Interpolant? interpolantFactoryMethodSmooth(result) => null;
}
