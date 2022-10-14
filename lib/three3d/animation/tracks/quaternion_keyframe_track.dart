part of three_animation;

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
