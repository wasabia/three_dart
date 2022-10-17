import 'package:three_dart/three3d/animation/keyframe_track.dart';
import 'package:three_dart/three3d/constants.dart';
import 'package:three_dart/three3d/math/interpolants/quaternion_linear_interpolant.dart';

import '../../math/interpolant.dart';

/// A Track of quaternion keyframe values.

class QuaternionKeyframeTrack extends KeyframeTrack {
  QuaternionKeyframeTrack(name, times, values, [interpolation]) : super(name, times, values, interpolation) {
    valueTypeName = 'quaternion';
    defaultInterpolation = InterpolateLinear;
  }

  @override
  Interpolant? interpolantFactoryMethodLinear(result) {
    return QuaternionLinearInterpolant(times, values, getValueSize(), result);
  }

  @override
  Interpolant? interpolantFactoryMethodSmooth(result) {
    return null;
  }
  // not yet implemented

}
