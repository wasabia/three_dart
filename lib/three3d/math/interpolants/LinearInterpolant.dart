part of three_math;


class LinearInterpolant extends Interpolant {

  LinearInterpolant( parameterPositions, sampleValues, sampleSize, resultBuffer ) : super(parameterPositions, sampleValues, sampleSize, resultBuffer) {

  }

  interpolate( i1, t0, t, t1 ) {

		var result = this.resultBuffer,
			values = this.sampleValues,
			stride = this.valueSize,

			offset1 = i1 * stride,
			offset0 = offset1 - stride,

			weight1 = ( t - t0 ) / ( t1 - t0 ),
			weight0 = 1 - weight1;

		for ( var i = 0; i != stride; ++ i ) {

			result[ i ] =
					values[ offset0 + i ] * weight0 +
					values[ offset1 + i ] * weight1;

		}

		return result;

	}


}
