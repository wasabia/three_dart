
import 'package:three_dart/three3d/animation/keyframe_track.dart';
import 'package:three_dart/three3d/constants.dart';

/// A Track of Boolean keyframe values.

class BooleanKeyframeTrack extends KeyframeTrack {
  @override
  var ValueTypeName = 'bool';
  @override
  var DefaultInterpolation = InterpolateDiscrete;
  @override
  var ValueBufferType = "Array";

  // Note: Actually this track could have a optimized / compressed
  // representation of a single value and a custom interpolant that
  // computes "firstValue ^ isOdd( index )".

  BooleanKeyframeTrack(name, times, values, interpolation)
      : super(name, times, values, null);

  @override
  InterpolantFactoryMethodLinear(result) {}
  @override
  InterpolantFactoryMethodSmooth(result) {}
}
