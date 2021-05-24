part of three_animation;

/**
 * A Track of Boolean keyframe values.
 */

class BooleanKeyframeTrack extends KeyframeTrack {

  var ValueTypeName = 'bool';
  var DefaultInterpolation = InterpolateDiscrete;
  var ValueBufferType = "Array";

  // Note: Actually this track could have a optimized / compressed
	// representation of a single value and a custom interpolant that
	// computes "firstValue ^ isOdd( index )".

  BooleanKeyframeTrack( name, times, values, interpolation) : super(name, times, values, null) {

  }

  InterpolantFactoryMethodLinear(result) {

  }
  InterpolantFactoryMethodSmooth(result) {

  }

}
