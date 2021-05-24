/**
 * Ref: https://en.wikipedia.org/wiki/Spherical_coordinate_system
 *
 * The polar angle (phi) is measured from the positive y-axis. The positive y-axis is up.
 * The azimuthal angle (theta) is measured from the positive z-axis.
 */

part of three_math;


class Spherical {

  late double radius;
  late double phi;
  late double theta;

	Spherical( {double radius = 1, double phi = 0, double theta = 0} ) {

		this.radius = radius;
		this.phi = phi; // polar angle
		this.theta = theta; // azimuthal angle

	}

	set( radius, phi, theta ) {

		this.radius = radius;
		this.phi = phi;
		this.theta = theta;

		return this;

	}

	clone() {

		return new Spherical().copy( this );

	}

	copy( other ) {

		this.radius = other.radius;
		this.phi = other.phi;
		this.theta = other.theta;

		return this;

	}

	// restrict phi to be betwee EPS and PI-EPS
	makeSafe() {

		const EPS = 0.000001;
		this.phi = Math.max( EPS, Math.min( Math.PI - EPS, this.phi ) ).toDouble();

		return this;

	}

	setFromVector3( v ) {

		return this.setFromCartesianCoords( v.x, v.y, v.z );

	}

	setFromCartesianCoords( x, y, z ) {

		this.radius = Math.sqrt( x * x + y * y + z * z );

		if ( this.radius == 0 ) {

			this.theta = 0;
			this.phi = 0;

		} else {

			this.theta = Math.atan2( x, z );
			this.phi = Math.acos( MathUtils.clamp( y / this.radius, - 1, 1 ) );

		}

		return this;

	}

}
