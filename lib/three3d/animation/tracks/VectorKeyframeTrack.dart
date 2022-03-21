part of three_animation;

/**
 * A Track of vectored keyframe values.
 */

class VectorKeyframeTrack extends KeyframeTrack {
  var ValueTypeName = 'vector';

  VectorKeyframeTrack(name, times, values, [interpolation])
      : super(name, times, values, interpolation) {}
}
