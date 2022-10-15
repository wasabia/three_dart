
import 'package:three_dart/three3d/animation/keyframe_track.dart';
import 'package:three_dart/three3d/constants.dart';
import 'package:three_dart/three3d/math/interpolants/quaternion_linear_interpolant.dart';

/// A Track of quaternion keyframe values.

class QuaternionKeyframeTrack extends KeyframeTrack {
  @override
  var ValueTypeName = 'quaternion';
  @override
  var DefaultInterpolation = InterpolateLinear;

  QuaternionKeyframeTrack(name, times, values, [interpolation])
      : super(name, times, values, interpolation);

  @override
  InterpolantFactoryMethodLinear(result) {
    return QuaternionLinearInterpolant(
        times, values, getValueSize(), result);
  }

  @override
  InterpolantFactoryMethodSmooth(result) {
    return null;
  }
  // not yet implemented

}
