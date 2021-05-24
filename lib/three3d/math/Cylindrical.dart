/**
 * Ref: https://en.wikipedia.org/wiki/Cylindrical_coordinate_system
 */

part of three_math;



class Cylindrical {

  late num radius;
  late num theta;
  late num y;

	Cylindrical( radius, theta, y ) {

		this.radius = ( radius != null ) ? radius : 1.0; // distance from the origin to a point in the x-z plane
		this.theta = ( theta != null ) ? theta : 0; // counterclockwise angle in the x-z plane measured in radians from the positive z-axis
		this.y = ( y != null ) ? y : 0; // height above the x-z plane

	}

	set( radius, theta, y ) {

		this.radius = radius;
		this.theta = theta;
		this.y = y;

		return this;

	}

	clone() {

		return new Cylindrical(null, null, null).copy( this );

	}

	copy( other ) {

		this.radius = other.radius;
		this.theta = other.theta;
		this.y = other.y;

		return this;

	}

	setFromVector3( v ) {

		return this.setFromCartesianCoords( v.x, v.y, v.z );

	}

	setFromCartesianCoords( x, y, z ) {

		this.radius = Math.sqrt( x * x + z * z );
		this.theta = Math.atan2( x, z );
		this.y = y;

		return this;

	}

}