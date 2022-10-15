
import 'package:three_dart/three3d/math/interpolant.dart';

///
/// Interpolant that evaluates to the sample value at the position preceeding
/// the parameter.

class DiscreteInterpolant extends Interpolant {
  DiscreteInterpolant(
      parameterPositions, sampleValues, sampleSize, resultBuffer)
      : super(parameterPositions, sampleValues, sampleSize, resultBuffer);

  @override
  interpolate(i1, t0, t, t1) {
    return copySampleValue_(i1 - 1);
  }
}
