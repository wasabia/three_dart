part of three_math;

/// Spherical linear unit quaternion interpolant.

class QuaternionLinearInterpolant extends Interpolant {
  QuaternionLinearInterpolant(
      parameterPositions, sampleValues, sampleSize, resultBuffer)
      : super(parameterPositions, sampleValues, sampleSize, resultBuffer);

  @override
  interpolate(int i1, num x0, num t, num t1) {
    var result = resultBuffer;
    var values = sampleValues;
    var stride = valueSize;

    double _v0 = t + (x0 * -1);
    double _v1 = t1 + (x0 * -1);

    double alpha = _v0 / _v1;

    var offset = i1 * stride;

    for (var end = offset + stride; offset < end; offset += 4) {
      Quaternion.slerpFlat(
          result, 0, values, offset - stride, values, offset, alpha);
    }

    return result;
  }
}
