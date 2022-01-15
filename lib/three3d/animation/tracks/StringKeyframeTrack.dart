part of three_animation;

/**
 * A Track that interpolates Strings
 */

class StringKeyframeTrack extends KeyframeTrack {
  var ValueTypeName = 'string';
  var ValueBufferType = "Array";

  var DefaultInterpolation = InterpolateDiscrete;

  StringKeyframeTrack(name, times, values, interpolation)
      : super(name, times, values, interpolation) {}

  InterpolantFactoryMethodLinear(result) {}

  InterpolantFactoryMethodSmooth(result) {}
}
