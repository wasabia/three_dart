part of three_animation;

/// A Track that interpolates Strings

class StringKeyframeTrack extends KeyframeTrack {
  @override
  var ValueTypeName = 'string';
  @override
  var ValueBufferType = "Array";

  @override
  var DefaultInterpolation = InterpolateDiscrete;

  StringKeyframeTrack(name, times, values, interpolation)
      : super(name, times, values, interpolation);

  @override
  InterpolantFactoryMethodLinear(result) {}

  @override
  InterpolantFactoryMethodSmooth(result) {}
}
