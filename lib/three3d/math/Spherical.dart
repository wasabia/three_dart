/*
 * Ref: https://en.wikipedia.org/wiki/Spherical_coordinate_system
 *
 * The polar angle (phi) is measured from the positive y-axis. The positive y-axis is up.
 * The azimuthal angle (theta) is measured from the positive z-axis.
 */

part of three_math;

class Spherical {
  late num radius;
  late num phi;
  late num theta;

  Spherical({this.radius = 1, this.phi = 0, this.theta = 0});

  Spherical set(num radius, num phi, num theta) {
    this.radius = radius;
    this.phi = phi;
    this.theta = theta;

    return this;
  }

  Spherical clone() {
    return Spherical().copy(this);
  }

  Spherical copy(Spherical other) {
    radius = other.radius;
    phi = other.phi;
    theta = other.theta;

    return this;
  }

  // restrict phi to be betwee EPS and PI-EPS
  Spherical makeSafe() {
    const EPS = 0.000001;
    phi = Math.max(EPS, Math.min(Math.PI - EPS, phi)).toDouble();

    return this;
  }

  Spherical setFromVector3(v) {
    return setFromCartesianCoords(v.x, v.y, v.z);
  }

  Spherical setFromCartesianCoords(num x, num y, num z) {
    radius = Math.sqrt(x * x + y * y + z * z);

    if (radius == 0) {
      theta = 0;
      phi = 0;
    } else {
      theta = Math.atan2(x, z);
      phi = Math.acos(MathUtils.clamp(y / radius, -1, 1));
    }

    return this;
  }
}
