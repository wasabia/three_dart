
part of three_extra;

/**
 * Extensible curve object.
 *
 * Some common of curve methods:
 * .getPoint( t, optionalTarget ), .getTangent( t, optionalTarget )
 * .getPointAt( u, optionalTarget ), .getTangentAt( u, optionalTarget )
 * .getPoints(), .getSpacedPoints()
 * .getLength()
 * .updateArcLengths()
 *
 * This following curves inherit from THREE.Curve:
 *
 * -- 2D curves --
 * THREE.ArcCurve
 * THREE.CubicBezierCurve
 * THREE.EllipseCurve
 * THREE.LineCurve
 * THREE.QuadraticBezierCurve
 * THREE.SplineCurve
 *
 * -- 3D curves --
 * THREE.CatmullRomCurve3
 * THREE.CubicBezierCurve3
 * THREE.LineCurve3
 * THREE.QuadraticBezierCurve3
 *
 * A series of curves can be represented as a THREE.CurvePath.
 *
 **/

class Curve {


  late num arcLengthDivisions;
  bool needsUpdate = false;

  List<num>? cacheArcLengths;
  List<num>? cacheLengths;

  bool autoClose = false;
  List<Curve> curves = [];
  late List points;

  bool isEllipseCurve = false;
  bool isLineCurve3 = false;
  bool isLineCurve = false;
  bool isSplineCurve = false;
  bool isCubicBezierCurve = false;
  bool isQuadraticBezierCurve = false;

  Vector2 currentPoint = new Vector2(null, null);

  late Vector2 v0;
  late Vector2 v1;
  late Vector2 v2;

  String type = "Curve";


  Curve() {
    this.arcLengthDivisions = 200;
  }



	Curve.fromJSON ( Map<String, dynamic> json ) {

		this.arcLengthDivisions = json["arcLengthDivisions"];
    this.v1 = Vector2.fromJSON(json["v1"]);
    this.v2 = Vector2.fromJSON(json["v2"]);
	}


  static castJSON(Map<String, dynamic> json) {
    String _type = json["type"];

    if(_type == "Shape") {
      return Shape.fromJSON(json);
    } else if(_type == "Curve") {
      return Curve.fromJSON(json);
    } else if(_type == "LineCurve") {
      return LineCurve.fromJSON(json);  
    } else {
      throw " type: ${_type} Curve.castJSON is not support yet... ";
    }
  }



	// Virtual base class method to overwrite and implement in subclasses
	//	- t [0 .. 1]

	getPoint ( num t, optionalTarget ) {

		print( 'THREE.Curve: .getPoint() not implemented.' );
		return null;

	}

	// Get point at relative position in curve according to arc length
	// - u [0 .. 1]

	getPointAt ( u, optionalTarget ) {

		var t = this.getUtoTmapping( u, null );
		return this.getPoint( t, optionalTarget );

	}

	// Get sequence of points using getPoint( t )

	getPoints ( {num divisions = 5} ) {

		var points = [];

		for ( var d = 0; d <= divisions; d ++ ) {

			points.add( this.getPoint( d / divisions, null ) );

		}

		return points;

	}

	// Get sequence of points using getPointAt( u )

	getSpacedPoints ( {num divisions = 5} ) {

		var points = [];

		for ( var d = 0; d <= divisions; d ++ ) {

			points.add( this.getPointAt( d / divisions, null ) );

		}

		return points;

	}

	// Get total curve arc length

	getLength () {

		var lengths = this.getLengths(null);
		return lengths[ lengths.length - 1 ];

	}

	// Get list of cumulative segment lengths

	getLengths ( divisions ) {

		if ( divisions == null ) divisions = this.arcLengthDivisions;

		if ( this.cacheArcLengths != null &&
			( this.cacheArcLengths!.length == divisions + 1 ) &&
			! this.needsUpdate ) {

			return this.cacheArcLengths;

		}

		this.needsUpdate = false;

		List<num> cache = [];
		var current, last = this.getPoint( 0, null );
		num sum = 0.0;

		cache.add( 0 );

		for ( var p = 1; p <= divisions; p ++ ) {

			current = this.getPoint( p / divisions, null );
			sum += current.distanceTo( last );
			cache.add( sum );
			last = current;

		}

		this.cacheArcLengths = cache;

		return cache; // { sums: cache, sum: sum }; Sum is in the last element.

	}

	updateArcLengths () {

		this.needsUpdate = true;
		this.getLengths(null);

	}

	// Given u ( 0 .. 1 ), get a t to find p. This gives you points which are equidistant

	getUtoTmapping ( u, distance ) {

		var arcLengths = this.getLengths(null);

		int i = 0;
		int il = arcLengths.length;

		var targetArcLength; // The targeted u distance value to get

		if ( distance != null ) {

			targetArcLength = distance;

		} else {

			targetArcLength = u * arcLengths[ il - 1 ];

		}

		// binary search for the index with largest value smaller than target u distance

		var low = 0, high = il - 1, comparison;

		while ( low <= high ) {

			i = Math.floor( low + ( high - low ) / 2 ).toInt(); // less likely to overflow, though probably not issue here, JS doesn't really have integers, all numbers are floats

			comparison = arcLengths[ i ] - targetArcLength;

			if ( comparison < 0 ) {

				low = i + 1;

			} else if ( comparison > 0 ) {

				high = i - 1;

			} else {

				high = i;
				break;

				// DONE

			}

		}

		i = high;

		if ( arcLengths[ i ] == targetArcLength ) {

			return i / ( il - 1 );

		}

		// we could get finer grain at lengths, or use simple interpolation between two points

		var lengthBefore = arcLengths[ i ];
		var lengthAfter = arcLengths[ i + 1 ];

		var segmentLength = lengthAfter - lengthBefore;

		// determine where we are between the 'before' and 'after' points

		var segmentFraction = ( targetArcLength - lengthBefore ) / segmentLength;

		// add that fractional amount to t

		var t = ( i + segmentFraction ) / ( il - 1 );

		return t;

	}

	// Returns a unit vector tangent at t
	// In case any sub curve does not implement its tangent derivation,
	// 2 points a small delta apart will be used to find its gradient
	// which seems to give a reasonable approximation

	getTangent ( t, optionalTarget ) {

		var delta = 0.0001;
		num t1 = t - delta;
		num t2 = t + delta;

		// Capping in case of danger

		if ( t1 < 0 ) t1 = 0;
		if ( t2 > 1 ) t2 = 1;

		var pt1 = this.getPoint( t1, null );
		var pt2 = this.getPoint( t2, null );

		var tangent = optionalTarget ?? ( ( pt1.isVector2 ) ? new Vector2(null, null) : new Vector3.init() );

		tangent.copy( pt2 ).sub( pt1 ).normalize();

		return tangent;

	}

	getTangentAt ( u, optionalTarget ) {

		var t = this.getUtoTmapping( u, null );
		return this.getTangent( t, optionalTarget );

	}

	computeFrenetFrames ( segments, closed ) {

		// see http://www.cs.indiana.edu/pub/techreports/TR425.pdf

		var normal = new Vector3.init();

		var tangents = [];
		var normals = [];
		var binormals = [];

		var vec = new Vector3.init();
		var mat = new Matrix4();

		// compute the tangent vectors for each segment on the curve

		for ( var i = 0; i <= segments; i ++ ) {

			var u = i / segments;

			tangents.add( this.getTangentAt( u, new Vector3.init() ) );
			tangents[ i ].normalize();

		}

		// select an initial normal vector perpendicular to the first tangent vector,
		// and in the direction of the minimum tangent xyz component

		normals.add( new Vector3.init() );
		binormals.add( new Vector3.init() );
		var min = Math.MAX_VALUE;
		var tx = Math.abs( tangents[ 0 ].x );
		var ty = Math.abs( tangents[ 0 ].y );
		var tz = Math.abs( tangents[ 0 ].z );

		if ( tx <= min ) {

			min = tx;
			normal.set( 1, 0, 0 );

		}

		if ( ty <= min ) {

			min = ty;
			normal.set( 0, 1, 0 );

		}

		if ( tz <= min ) {

			normal.set( 0, 0, 1 );

		}

		vec.crossVectors( tangents[ 0 ], normal ).normalize();

		normals[ 0 ].crossVectors( tangents[ 0 ], vec );
		binormals[ 0 ].crossVectors( tangents[ 0 ], normals[ 0 ] );


		// compute the slowly-varying normal and binormal vectors for each segment on the curve

		for ( var i = 1; i <= segments; i ++ ) {

			normals.add( normals[ i - 1 ].clone() );

			binormals.add( binormals[ i - 1 ].clone() );

			vec.crossVectors( tangents[ i - 1 ], tangents[ i ] );

			if ( vec.length() > Math.EPSILON ) {

				vec.normalize();

				var theta = Math.acos( MathUtils.clamp( tangents[ i - 1 ].dot( tangents[ i ] ), - 1, 1 ) ); // clamp for floating pt errors

				normals[ i ].applyMatrix4( mat.makeRotationAxis( vec, theta ) );

			}

			binormals[ i ].crossVectors( tangents[ i ], normals[ i ] );

		}

		// if the curve is closed, postprocess the vectors so the first and last normal vectors are the same

		if ( closed == true ) {

			var theta = Math.acos( MathUtils.clamp( normals[ 0 ].dot( normals[ segments ] ), - 1, 1 ) );
			theta /= segments;

			if ( tangents[ 0 ].dot( vec.crossVectors( normals[ 0 ], normals[ segments ] ) ) > 0 ) {

				theta = - theta;

			}

			for ( var i = 1; i <= segments; i ++ ) {

				// twist a little...
				normals[ i ].applyMatrix4( mat.makeRotationAxis( tangents[ i ], theta * i ) );
				binormals[ i ].crossVectors( tangents[ i ], normals[ i ] );

			}

		}

		return {
			"tangents": tangents,
			"normals": normals,
			"binormals": binormals
		};

	}

	clone () {

		return Curve().copy( this );

	}


	copy ( source ) {

		this.arcLengthDivisions = source.arcLengthDivisions;

		return this;

	}

	toJSON () {

		Map<String, dynamic> data = {
			"metadata": {
				"version": 4.5,
				"type": 'Curve',
				"generator": 'Curve.toJSON'
			}
		};

		data["arcLengthDivisions"] = this.arcLengthDivisions;
		data["type"] = this.type;

		return data;

	}

  fromJSON( json ) {

		this.arcLengthDivisions = json.arcLengthDivisions;

		return this;

	}

}
