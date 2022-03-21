part of three_math;

/**
 *
 * Interpolant that evaluates to the sample value at the position preceeding
 * the parameter.
 */

class DiscreteInterpolant extends Interpolant {
  DiscreteInterpolant(
      parameterPositions, sampleValues, sampleSize, resultBuffer)
      : super(parameterPositions, sampleValues, sampleSize, resultBuffer) {}

  interpolate(i1, t0, t, t1) {
    return copySampleValue(i1 - 1);
  }
}
