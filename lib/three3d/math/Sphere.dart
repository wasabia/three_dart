part of three_math;


var _box = new Box3(null, null);

class Sphere {

  late Vector3 center;
  late double radius;


	Sphere( center, radius ) {

		this.center = ( center != null ) ? center : new Vector3.init();
		this.radius = ( radius != null ) ? radius : - 1;

	}

  toJSON() {
    List<double> _data = center.toJSON();
    _data.add(radius);

    return _data;
  }

	set( center, radius ) {

		this.center.copy( center );
		this.radius = radius;

		return this;

	}

	setFromPoints( points, optionalCenter ) {

		var center = this.center;

		if ( optionalCenter != null ) {

			center.copy( optionalCenter );

		} else {

			_box.setFromPoints( points ).getCenter( center );

		}

		num maxRadiusSq = 0.0;

		for ( var i = 0, il = points.length; i < il; i ++ ) {

			maxRadiusSq = Math.max( maxRadiusSq, center.distanceToSquared( points[ i ] ) );

		}

		this.radius = Math.sqrt( maxRadiusSq );

		return this;

	}

	clone() {

		return new Sphere(null, null).copy( this );

	}

	copy( sphere ) {

		this.center.copy( sphere.center );
		this.radius = sphere.radius;

		return this;

	}

	isEmpty() {

		return ( this.radius < 0 );

	}

	makeEmpty() {

		this.center.set( 0, 0, 0 );
		this.radius = - 1;

		return this;

	}

	containsPoint( point ) {

		return ( point.distanceToSquared( this.center ) <= ( this.radius * this.radius ) );

	}

	distanceToPoint( point ) {

		return ( point.distanceTo( this.center ) - this.radius );

	}

	intersectsSphere( sphere ) {

		var radiusSum = this.radius + sphere.radius;

		return sphere.center.distanceToSquared( this.center ) <= ( radiusSum * radiusSum );

	}

	intersectsBox( box ) {

		return box.intersectsSphere( this );

	}

	intersectsPlane( plane ) {

		return Math.abs( plane.distanceToPoint( this.center ) ) <= this.radius;

	}

	clampPoint( point, target ) {

		var deltaLengthSq = this.center.distanceToSquared( point );

		if ( target == null ) {

			print( 'THREE.Sphere: .clampPoint() target is now required' );
			target = new Vector3.init();

		}

		target.copy( point );

		if ( deltaLengthSq > ( this.radius * this.radius ) ) {

			target.sub( this.center ).normalize();
			target.multiplyScalar( this.radius ).add( this.center );

		}

		return target;

	}

	getBoundingBox( target ) {

		if ( target == null ) {

			print( 'THREE.Sphere: .getBoundingBox() target is now required' );
			target = new Box3(null, null);

		}

		if ( this.isEmpty() ) {

			// Empty sphere produces empty bounding box
			target.makeEmpty();
			return target;

		}

		target.set( this.center, this.center );
		target.expandByScalar( this.radius );

		return target;

	}

	applyMatrix4( matrix ) {

		this.center.applyMatrix4( matrix );
    
		this.radius = this.radius * matrix.getMaxScaleOnAxis();

		return this;

	}

	translate( offset ) {

		this.center.add( offset );

		return this;

	}

	equals( sphere ) {

		return sphere.center.equals( this.center ) && ( sphere.radius == this.radius );

	}

}

