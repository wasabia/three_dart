/*
 * Ref: https://en.wikipedia.org/wiki/Cylindrical_coordinate_system
 */

part of three_math;

class Cylindrical {
  late num radius;
  late num theta;
  late num y;

  Cylindrical([num? radius, num? theta, num? y]) {
    this.radius = (radius != null)
        ? radius
        : 1.0; // distance from the origin to a point in the x-z plane
    this.theta = (theta != null)
        ? theta
        : 0; // counterclockwise angle in the x-z plane measured in radians from the positive z-axis
    this.y = (y != null) ? y : 0; // height above the x-z plane
  }

  Cylindrical set(num radius, num theta, num y) {
    this.radius = radius;
    this.theta = theta;
    this.y = y;

    return this;
  }

  Cylindrical clone() {
    return Cylindrical(null, null, null).copy(this);
  }

  Cylindrical copy(Cylindrical other) {
    radius = other.radius;
    theta = other.theta;
    y = other.y;

    return this;
  }

  Cylindrical setFromVector3(Vector3 v) {
    return setFromCartesianCoords(v.x, v.y, v.z);
  }

  Cylindrical setFromCartesianCoords(num x, num y, num z) {
    radius = Math.sqrt(x * x + z * z);
    theta = Math.atan2(x, z);
    this.y = y;

    return this;
  }
}
