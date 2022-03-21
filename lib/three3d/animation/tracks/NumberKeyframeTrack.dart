part of three_animation;

/**
 * A Track of numeric keyframe values.
 */

class NumberKeyframeTrack extends KeyframeTrack {
  var ValueTypeName = "number";

  NumberKeyframeTrack(name, times, values, [interpolation])
      : super(name, times, values, interpolation) {}
}
