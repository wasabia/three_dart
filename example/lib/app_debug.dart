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
        body: Container(),
        floatingActionButton: FloatingActionButton(
          child: Text("render"),
          onPressed: () {
            clickRender();
          },
        ),
      ),
    );
  }

  clickRender() {
    print(" click render.... ");
    
    var parameterPositions = [0.041669998317956924, 0.08332999795675278, 0.125, 0.16666999459266663, 0.20833000540733337, 0.25, 0.2916699945926666, 0.3333300054073334, 0.375, 0.4166699945926666];
    var values = [-0.006437911186367273, 0.8523336052894592, -0.5229341387748718, -0.0044136554934084415, -0.006838988047093153, 0.827555239200592, -0.5613213777542114, -0.004157633055001497, -0.007904959842562675, 0.7461036443710327, -0.6657804846763611, -0.0033440093975514174, -0.009084964171051979, 0.6201450824737549, -0.7844299674034119, -0.0022029252722859383, -0.009808935225009918, 0.5117224454879761, -0.8590943813323975, -0.0012874591629952192, -0.009998129680752754, 0.4723302721977234, -0.8813651204109192, -0.0009889232460409403, -0.009808935225009918, 0.5117224454879761, -0.8590943813323975, -0.0012874591629952192, -0.009084964171051979, 0.6201450824737549, -0.7844299674034119, -0.0022029252722859383, -0.007904959842562675, 0.7461036443710327, -0.6657804846763611, -0.0033440093975514174, -0.006839045789092779, 0.8275482058525085, -0.5613284707069397, -0.004157580900937319];

    List<num> result = [0, 0, 0, 0, -0.0052362778224051, 0.7072955369949341, -0.7068748474121094, -0.005794902332127094, 0, 0, 0, 0, -0.0052362778224051, 0.7072955369949341, -0.7068748474121094, -0.005794902332127094, 0, 0, 0, 1, 0, 0, 0, 0];

		var gi = Interpolant(parameterPositions, values, 2, result);

    gi.evaluate(0.1);
  }


}


class Interpolant {

  late dynamic parameterPositions;
  int _cachedIndex = 0;
  late dynamic resultBuffer;
  late dynamic sampleValues;
  late dynamic valueSize;
  late dynamic settings;


  Interpolant( parameterPositions, sampleValues, sampleSize, resultBuffer ) {
    this.parameterPositions = parameterPositions;

    this.resultBuffer = resultBuffer != null ? resultBuffer : null;
    this.sampleValues = sampleValues;
    this.valueSize = sampleSize;
  }



  evaluate( double t ) {

		var pp = this.parameterPositions;
		int i1 = this._cachedIndex;

    num? t1;
		num t0 = 0;

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

								if ( t < t0 ) break forward_scan;

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
                t0 = 0;
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
        t0 = 0;

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

	interpolate( int i1, num t0, num t, num t1 ) {
		
		var result = this.resultBuffer;
		var values = this.sampleValues;
		var stride = this.valueSize;


    double _v0 = t + (t0 * -1);
    double _v1 = t1 + (t0 * -1);

		double alpha = _v0 / _v1;

		var offset = i1 * stride;

		for ( var end = offset + stride; offset < end; offset += 4 ) {

		
		}

		return result;
	}

	intervalChanged(v1, v2, v3) {
	}

  beforeStart(v1, v2, v3) {
  }

  afterEnd(v1, v2, v3) {
  }

}

