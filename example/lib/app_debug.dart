import 'dart:async';

import 'package:flutter/material.dart';
import 'dart:math' as Math;


class app_debug extends StatefulWidget {
  String fileName;

  app_debug({Key? key, required this.fileName}) : super(key: key);

  createState() => webgl_debugState();
}

class webgl_debugState extends State<app_debug> {

  @override
  void initState() {
    super.initState();   
  }


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text(widget.fileName),
        ),
        body: Builder(
          builder: (BuildContext context) {
            
            return SingleChildScrollView(
              child: _build(context)
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          child: Text("render"),
          onPressed: () {
            clickRender();
          },
        ),
      ),
    );
  }

  Widget _build(BuildContext context) {
    return Column(
      children: [
        Container(
         
        ),

      ],
    );
  }

  clickRender() {

    print(" click render.... ");


    var res = interpolate_();
    print(" res: ${res} ");
  }

  interpolate_() {

    var parameterPositions = [0.041669998317956924, 0.08332999795675278, 0.125, 0.16666999459266663, 0.20833000540733337, 0.25, 0.2916699945926666, 0.3333300054073334, 0.375, 0.4166699945926666];
    var values = [-0.006437911186367273, 0.8523336052894592, -0.5229341387748718, -0.0044136554934084415, -0.006838988047093153, 0.827555239200592, -0.5613213777542114, -0.004157633055001497, -0.007904959842562675, 0.7461036443710327, -0.6657804846763611, -0.0033440093975514174, -0.009084964171051979, 0.6201450824737549, -0.7844299674034119, -0.0022029252722859383, -0.009808935225009918, 0.5117224454879761, -0.8590943813323975, -0.0012874591629952192, -0.009998129680752754, 0.4723302721977234, -0.8813651204109192, -0.0009889232460409403, -0.009808935225009918, 0.5117224454879761, -0.8590943813323975, -0.0012874591629952192, -0.009084964171051979, 0.6201450824737549, -0.7844299674034119, -0.0022029252722859383, -0.007904959842562675, 0.7461036443710327, -0.6657804846763611, -0.0033440093975514174, -0.006839045789092779, 0.8275482058525085, -0.5613284707069397, -0.004157580900937319];

    List<num> result = [0, 0, 0, 0, -0.0052362778224051, 0.7072955369949341, -0.7068748474121094, -0.005794902332127094, 0, 0, 0, 0, -0.0052362778224051, 0.7072955369949341, -0.7068748474121094, -0.005794902332127094, 0, 0, 0, 1, 0, 0, 0, 0];

		var gi = QuaternionLinearInterpolant(parameterPositions, values, 2, result);

    gi.evaluate(0.1);

	}

  @override
  void dispose() {
    
    print(" dispose ............. ");

    super.dispose();
  }


 
}



class QuaternionLinearInterpolant extends Interpolant {

  QuaternionLinearInterpolant( parameterPositions, sampleValues, sampleSize, resultBuffer ) : super(parameterPositions, sampleValues, sampleSize, resultBuffer) {

  }

  interpolate( int i1, num x0, num t, num t1 ) {

		var result = this.resultBuffer;
		var values = this.sampleValues;
		var stride = this.valueSize;


    double _v0 = t + (x0 * -1);
    double _v1 = t1 + (x0 * -1);

		double alpha = _v0 / _v1;

		var offset = i1 * stride;

		for ( var end = offset + stride; offset < end; offset += 4 ) {

			Quaternion.slerpFlat( result, 0, values, offset - stride, values, offset, alpha );

		}

		return result;

	}

}


class Interpolant {

  late dynamic parameterPositions;
  int _cachedIndex = 0;
  late dynamic resultBuffer;
  late dynamic sampleValues;
  late dynamic valueSize;
  late dynamic settings;

  	// --- Protected interface

	dynamic DefaultSettings = {};

  Interpolant( parameterPositions, sampleValues, sampleSize, resultBuffer ) {

    // print(" parameterPositions sampleSize: ${sampleSize} ");
    // print(parameterPositions);

    this.parameterPositions = parameterPositions;

    this.resultBuffer = resultBuffer != null ? resultBuffer : null;
    this.sampleValues = sampleValues;
    this.valueSize = sampleSize;
  }



  evaluate( double t ) {

		var pp = this.parameterPositions;
		int i1 = this._cachedIndex;

    num? t1;
		num? t0;

    if(i1 < pp.length) {
      t1 = pp[ i1 ];
    }
    if(i1 - 1 >= 0) {
      t0 = pp[ i1 - 1 ];
    }

 
		validate_interval: {
			seek: {

				int right;

				linear_scan: {

					//- See http://jsperf.com/comparison-to-undefined/3
					//- slower code:
					//-
					//- 				if ( t >= t1 || t1 == null ) {
					forward_scan: if ( t1 == null || t >= t1 ) {

						for ( var giveUpAt = i1 + 2; ; ) {

							if ( t1 == null ) {

								if ( t < t0! ) break forward_scan;

								// after end

								i1 = pp.length;
								this._cachedIndex = i1;
								return this.afterEnd( i1 - 1, t, t0 );

							}

							if ( i1 == giveUpAt ) break; // this loop

							t0 = t1;

              int _idx = ++ i1;

              if(_idx < pp.length) {
                t1 = pp[ _idx ];
              } else {
                t1 = null;
              }

							if (t1 != null && t < t1 ) {

								// we have arrived at the sought interval
								break seek;

							}

						}

						// prepare binary search on the right side of the index
						right = pp.length;
						break linear_scan;

					}

					//- slower code:
					//-					if ( t < t0 || t0 == null ) {
					if (t0 == null || ! ( t >= t0 ) ) {

						// looping?

						var t1global = pp[ 1 ];

						if ( t < t1global ) {

							i1 = 2; // + 1, using the scan for the details
							t0 = t1global;

						}

						// linear reverse scan

						for ( var giveUpAt = i1 - 2; ; ) {

							if ( t0 == null ) {

								// before start

								this._cachedIndex = 0;
								return this.beforeStart( 0, t, t1 );

							}

							if ( i1 == giveUpAt ) break; // this loop

							t1 = t0;

              int iii = -- i1 - 1;
              if(iii < 0) {
                t0 = null;
              } else {
                t0 = pp[ iii ];
              }
							

							if ( t0 != null && t >= t0 ) {

								// we have arrived at the sought interval
								break seek;

							}

						}

						// prepare binary search on the left side of the index
						right = i1;
						i1 = 0;
						break linear_scan;

					}

					// the interval is valid

					break validate_interval;

				} // linear scan

				// binary search

				while ( i1 < right ) {

					var mid = ( i1 + right ) >> 1;

          // print(" Interpolant i1: ${i1} right: ${right} pp: ${pp.length} mid: ${mid} ");

					if ( t < pp[ mid ] ) {

						right = mid;

					} else {

						i1 = mid + 1;

					}

				}

        t1 = null;
        t0 = null;

        if(i1 < pp.length) {
          t1 = pp[ i1 ];
        }
        if(i1 - 1 < pp.length) {
          t0 = pp[ i1 - 1 ];
        }
				

				// check boundary cases, again

				if ( t0 == null ) {

					this._cachedIndex = 0;
					return this.beforeStart( 0, t, t1 );

				}

				if ( t1 == null ) {

					i1 = pp.length;
					this._cachedIndex = i1;
					return this.afterEnd( i1 - 1, t0, t );

				}

			} // seek

			this._cachedIndex = i1;

			this.intervalChanged( i1, t0, t1 );

		} // validate_interval

		return this.interpolate( i1, t0, t, t1! );

	}



	getSettings() {

		return this.settings ?? this.DefaultSettings;

	}

	copySampleValue( index ) {

		// copies a sample value to the result buffer

		var result = this.resultBuffer,
			values = this.sampleValues,
			stride = this.valueSize,
			offset = index * stride;

		for ( var i = 0; i != stride; ++ i ) {

			result[ i ] = values[ offset + i ];

		}

		return result;

	}

	// Template methods for derived classes:

	interpolate( int i1, num t0, num t, num t1 ) {

		throw ( 'call to abstract method' );
		// implementations shall return this.resultBuffer

	}

	intervalChanged(v1, v2, v3) {

		// empty

	}

  beforeStart(v1, v2, v3) {
    // return copySampleValue_(v1, v2, v3);
  }

	//( N-1, tN-1, t ), returns this.resultBuffer
	// afterEnd_: Interpolant.prototype.copySampleValue_,

  afterEnd(v1, v2, v3) {
    // return copySampleValue_(v1, v2, v3);
  }

}



class Quaternion {


	static static_slerp( qa, qb, qm, t ) {

    print( 'THREE.Quaternion: Static .slerp() has been deprecated. Use is now qm.slerpQuaternions( qa, qb, t ) instead.' );
		return qm.slerpQuaternions( qa, qb, t );

	}

	static slerpFlat( dst, dstOffset, src0, srcOffset0, src1, srcOffset1, t ) {

		// fuzz-free, array-based Quaternion SLERP operation

		var x0 = src0[ srcOffset0 + 0 ],
			y0 = src0[ srcOffset0 + 1 ],
			z0 = src0[ srcOffset0 + 2 ],
			w0 = src0[ srcOffset0 + 3 ];

		var x1 = src1[ srcOffset1 + 0 ],
			y1 = src1[ srcOffset1 + 1 ],
			z1 = src1[ srcOffset1 + 2 ],
			w1 = src1[ srcOffset1 + 3 ];

    if ( t == 0 ) {

			dst[ dstOffset ] = x0;
			dst[ dstOffset + 1 ] = y0;
			dst[ dstOffset + 2 ] = z0;
			dst[ dstOffset + 3 ] = w0;
			return;

		}

		if ( t == 1 ) {

			dst[ dstOffset ] = x1;
			dst[ dstOffset + 1 ] = y1;
			dst[ dstOffset + 2 ] = z1;
			dst[ dstOffset + 3 ] = w1;
			return;

		}

		if ( w0 != w1 || x0 != x1 || y0 != y1 || z0 != z1 ) {

			var s = 1 - t;
			double cos = x0 * x1 + y0 * y1 + z0 * z1 + w0 * w1;
			var dir = ( cos >= 0 ? 1 : - 1 ),
				sqrSin = 1 - cos * cos;

			// Skip the Slerp for tiny steps to avoid numeric problems:
			if ( sqrSin > 4.94065645841247E-324 ) {

				var sin = Math.sqrt( sqrSin ),
					len = Math.atan2( sin, cos * dir );

				s = Math.sin( s * len ) / sin;
				t = Math.sin( t * len ) / sin;

			}

			var tDir = t * dir;

			x0 = x0 * s + x1 * tDir;
			y0 = y0 * s + y1 * tDir;
			z0 = z0 * s + z1 * tDir;
			w0 = w0 * s + w1 * tDir;

			// Normalize in case we just did a lerp:
			if ( s == 1 - t ) {

				var f = 1 / Math.sqrt( x0 * x0 + y0 * y0 + z0 * z0 + w0 * w0 );

				x0 *= f;
				y0 *= f;
				z0 *= f;
				w0 *= f;

			}

		}

		dst[ dstOffset ] = x0;
		dst[ dstOffset + 1 ] = y0;
		dst[ dstOffset + 2 ] = z0;
		dst[ dstOffset + 3 ] = w0;

	}

	static multiplyQuaternionsFlat( dst, dstOffset, src0, srcOffset0, src1, srcOffset1 ) {

		var x0 = src0[ srcOffset0 ];
		var y0 = src0[ srcOffset0 + 1 ];
		var z0 = src0[ srcOffset0 + 2 ];
		var w0 = src0[ srcOffset0 + 3 ];

		var x1 = src1[ srcOffset1 ];
		var y1 = src1[ srcOffset1 + 1 ];
		var z1 = src1[ srcOffset1 + 2 ];
		var w1 = src1[ srcOffset1 + 3 ];

		dst[ dstOffset ] = x0 * w1 + w0 * x1 + y0 * z1 - z0 * y1;
		dst[ dstOffset + 1 ] = y0 * w1 + w0 * y1 + z0 * x1 - x0 * z1;
		dst[ dstOffset + 2 ] = z0 * w1 + w0 * z1 + x0 * y1 - y0 * x1;
		dst[ dstOffset + 3 ] = w0 * w1 - x0 * x1 - y0 * y1 - z0 * z1;

		return dst;

	}

}
