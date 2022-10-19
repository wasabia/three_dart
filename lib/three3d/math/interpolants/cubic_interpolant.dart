import 'package:three_dart/three3d/constants.dart';
import 'package:three_dart/three3d/math/interpolant.dart';

/// Fast and simple cubic spline interpolant.
///
/// It was derived from a Hermitian construction setting the first derivative
/// at each sample position to the linear slope between neighboring positions
/// over their parameter interval.

class CubicInterpolant extends Interpolant {
  late num _weightPrev;
  late num _offsetPrev;
  late num _weightNext;
  late num _offsetNext;

  CubicInterpolant(parameterPositions, sampleValues, sampleSize, resultBuffer)
      : super(parameterPositions, sampleValues, sampleSize, resultBuffer) {
    _weightPrev = -0;
    _offsetPrev = -0;
    _weightNext = -0;
    _offsetNext = -0;

    defaultSettings = {"endingStart": ZeroCurvatureEnding, "endingEnd": ZeroCurvatureEnding};
  }

  @override
  intervalChanged(v1, v2, v3) {
    var pp = parameterPositions;
    var iPrev = v1 - 2, iNext = v1 + 1, tPrev = pp[iPrev], tNext = pp[iNext];

    if (tPrev == null) {
      switch (getSettings().endingStart) {
        case ZeroSlopeEnding:

          // f'(t0) = 0
          iPrev = v1;
          tPrev = 2 * v2 - v3;

          break;

        case WrapAroundEnding:

          // use the other end of the curve
          iPrev = pp.length - 2;
          tPrev = v2 + pp[iPrev] - pp[iPrev + 1];

          break;

        default: // ZeroCurvatureEnding

          // f''(t0) = 0 a.k.a. Natural Spline
          iPrev = v1;
          tPrev = v3;
      }
    }

    if (tNext == null) {
      switch (getSettings().endingEnd) {
        case ZeroSlopeEnding:

          // f'(tN) = 0
          iNext = v1;
          tNext = 2 * v3 - v2;

          break;

        case WrapAroundEnding:

          // use the other end of the curve
          iNext = 1;
          tNext = v3 + pp[1] - pp[0];

          break;

        default: // ZeroCurvatureEnding

          // f''(tN) = 0, a.k.a. Natural Spline
          iNext = v1 - 1;
          tNext = v2;
      }
    }

    var halfDt = (v3 - v2) * 0.5, stride = valueSize;

    _weightPrev = halfDt / (v2 - tPrev);
    _weightNext = halfDt / (tNext - v3);
    _offsetPrev = iPrev * stride;
    _offsetNext = iNext * stride;
  }

  @override
  interpolate(i1, t0, t, t1) {
    var result = resultBuffer,
        values = sampleValues,
        stride = valueSize,
        o1 = i1 * stride,
        o0 = o1 - stride,
        oP = _offsetPrev,
        oN = _offsetNext,
        wP = _weightPrev,
        wN = _weightNext,
        p = (t - t0) / (t1 - t0),
        pp = p * p,
        ppp = pp * p;

    // evaluate polynomials

    var sP = -wP * ppp + 2 * wP * pp - wP * p;
    var s0 = (1 + wP) * ppp + (-1.5 - 2 * wP) * pp + (-0.5 + wP) * p + 1;
    var s1 = (-1 - wN) * ppp + (1.5 + wN) * pp + 0.5 * p;
    var sN = wN * ppp - wN * pp;

    // combine data linearly

    for (var i = 0; i != stride; ++i) {
      result[i] = sP * values[oP + i] + s0 * values[o0 + i] + s1 * values[o1 + i] + sN * values[oN + i];
    }

    return result;
  }
}
