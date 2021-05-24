part of three_math;

/**
 * Spherical linear unit quaternion interpolant.
 */

class QuaternionLinearInterpolant extends Interpolant {

  QuaternionLinearInterpolant( parameterPositions, sampleValues, sampleSize, resultBuffer ) : super(parameterPositions, sampleValues, sampleSize, resultBuffer) {

  }

  interpolate_( i1, t0, t, t1 ) {

		var result = this.resultBuffer,
			values = this.sampleValues,
			stride = this.valueSize,

			alpha = ( t - t0 ) / ( t1 - t0 );

		var offset = i1 * stride;

		for ( var end = offset + stride; offset != end; offset += 4 ) {

			Quaternion.slerpFlat( result, 0, values, offset - stride, values, offset, alpha );

		}

		return result;

	}

}

