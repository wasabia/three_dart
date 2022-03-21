part of three_animation;

/**
 * A Track of quaternion keyframe values.
 */

class QuaternionKeyframeTrack extends KeyframeTrack {
  var ValueTypeName = 'quaternion';
  var DefaultInterpolation = InterpolateLinear;

  QuaternionKeyframeTrack(name, times, values, [interpolation])
      : super(name, times, values, interpolation) {}

  InterpolantFactoryMethodLinear(result) {
    return new QuaternionLinearInterpolant(
        this.times, this.values, this.getValueSize(), result);
  }

  InterpolantFactoryMethodSmooth(result) {
    return null;
  }
  // not yet implemented

}
