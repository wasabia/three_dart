part of three_math;


var _startP = /*@__PURE__*/ new Vector3.init();
var _startEnd = /*@__PURE__*/ new Vector3.init();

class Line3 {

  late Vector3 start;
  late Vector3 end;

	Line3( start, end ) {

		this.start = ( start != null ) ? start : new Vector3.init();
		this.end = ( end != null ) ? end : new Vector3.init();

	}

	set( start, end ) {

		this.start.copy( start );
		this.end.copy( end );

		return this;

	}

	clone() {

		return new Line3(null, null).copy( this );

	}

	copy( line ) {

		this.start.copy( line.start );
		this.end.copy( line.end );

		return this;

	}

	getCenter( target ) {

		if ( target == null ) {

			print( 'THREE.Line3: .getCenter() target is now required' );
			target = new Vector3.init();

		}

		return target.addVectors( this.start, this.end ).multiplyScalar( 0.5 );

	}

	delta( target ) {

		if ( target == null ) {

			print( 'THREE.Line3: .delta() target is now required' );
			target = new Vector3.init();

		}

		return target.subVectors( this.end, this.start );

	}

	distanceSq() {

		return this.start.distanceToSquared( this.end );

	}

	distance() {

		return this.start.distanceTo( this.end );

	}

	at( t, target ) {

		if ( target == null ) {

			print( 'THREE.Line3: .at() target is now required' );
			target = new Vector3.init();

		}

		return this.delta( target ).multiplyScalar( t ).add( this.start );

	}

	closestPointToPointParameter( point, clampToLine ) {

		_startP.subVectors( point, this.start );
		_startEnd.subVectors( this.end, this.start );

		var startEnd2 = _startEnd.dot( _startEnd );
		var startEnd_startP = _startEnd.dot( _startP );

		var t = startEnd_startP / startEnd2;

		if ( clampToLine ) {

			t = MathUtils.clamp( t, 0, 1 );

		}

		return t;

	}

	closestPointToPoint( point, clampToLine, target ) {

		var t = this.closestPointToPointParameter( point, clampToLine );

		if ( target == null ) {

			print( 'THREE.Line3: .closestPointToPoint() target is now required' );
			target = new Vector3.init();

		}

		return this.delta( target ).multiplyScalar( t ).add( this.start );

	}

	applyMatrix4( matrix ) {

		this.start.applyMatrix4( matrix );
		this.end.applyMatrix4( matrix );

		return this;

	}

	equals( line ) {

		return line.start.equals( this.start ) && line.end.equals( this.end );

	}

}

