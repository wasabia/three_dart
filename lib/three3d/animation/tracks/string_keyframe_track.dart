import 'package:three_dart/three3d/animation/keyframe_track.dart';
import 'package:three_dart/three3d/constants.dart';

/// A Track that interpolates Strings

class StringKeyframeTrack extends KeyframeTrack {
  @override
  var valueTypeName = 'string';
  @override
  var valueBufferType = "Array";

  @override
  var defaultInterpolation = InterpolateDiscrete;

  StringKeyframeTrack(name, times, values, interpolation) : super(name, times, values, interpolation);

  @override
  interpolantFactoryMethodLinear(result) {}

  @override
  interpolantFactoryMethodSmooth(result) {}
}
