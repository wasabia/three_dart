
import 'package:three_dart/three3d/math/vector3.dart';

/// Primary reference:
///   https://graphics.stanford.edu/papers/envmap/envmap.pdf
///
/// Secondary reference:
///   https://www.ppsloan.org/publications/StupidSH36.pdf

// 3-band SH defined by 9 coefficients

class SphericalHarmonics3 {
  String type = "SphericalHarmonics3";

  List<Vector3> coefficients = [];

  SphericalHarmonics3() {
    for (var i = 0; i < 9; i++) {
      coefficients.add(Vector3.init());
    }
  }

  SphericalHarmonics3 set(List<Vector3> coefficients) {
    for (var i = 0; i < 9; i++) {
      this.coefficients[i].copy(coefficients[i]);
    }

    return this;
  }

  SphericalHarmonics3 zero() {
    for (var i = 0; i < 9; i++) {
      coefficients[i].set(0, 0, 0);
    }

    return this;
  }

  // get the radiance in the direction of the normal
  // target is a Vector3
  Vector3 getAt(Vector3 normal, Vector3 target) {
    // normal is assumed to be unit length

    var x = normal.x, y = normal.y, z = normal.z;

    var coeff = coefficients;

    // band 0
    target.copy(coeff[0]).multiplyScalar(0.282095);

    // band 1
    target.addScaledVector(coeff[1], 0.488603 * y);
    target.addScaledVector(coeff[2], 0.488603 * z);
    target.addScaledVector(coeff[3], 0.488603 * x);

    // band 2
    target.addScaledVector(coeff[4], 1.092548 * (x * y));
    target.addScaledVector(coeff[5], 1.092548 * (y * z));
    target.addScaledVector(coeff[6], 0.315392 * (3.0 * z * z - 1.0));
    target.addScaledVector(coeff[7], 1.092548 * (x * z));
    target.addScaledVector(coeff[8], 0.546274 * (x * x - y * y));

    return target;
  }

  // get the irradiance (radiance convolved with cosine lobe) in the direction of the normal
  // target is a Vector3
  // https://graphics.stanford.edu/papers/envmap/envmap.pdf
  Vector3 getIrradianceAt(Vector3 normal, Vector3 target) {
    // normal is assumed to be unit length

    var x = normal.x, y = normal.y, z = normal.z;

    var coeff = coefficients;

    // band 0
    target.copy(coeff[0]).multiplyScalar(0.886227); // π * 0.282095

    // band 1
    target.addScaledVector(
        coeff[1], 2.0 * 0.511664 * y); // ( 2 * π / 3 ) * 0.488603
    target.addScaledVector(coeff[2], 2.0 * 0.511664 * z);
    target.addScaledVector(coeff[3], 2.0 * 0.511664 * x);

    // band 2
    target.addScaledVector(
        coeff[4], 2.0 * 0.429043 * x * y); // ( π / 4 ) * 1.092548
    target.addScaledVector(coeff[5], 2.0 * 0.429043 * y * z);
    target.addScaledVector(
        coeff[6], 0.743125 * z * z - 0.247708); // ( π / 4 ) * 0.315392 * 3
    target.addScaledVector(coeff[7], 2.0 * 0.429043 * x * z);
    target.addScaledVector(
        coeff[8], 0.429043 * (x * x - y * y)); // ( π / 4 ) * 0.546274

    return target;
  }

  SphericalHarmonics3 add(SphericalHarmonics3 sh) {
    for (var i = 0; i < 9; i++) {
      coefficients[i].add(sh.coefficients[i]);
    }

    return this;
  }

  SphericalHarmonics3 addScaledSH(SphericalHarmonics3 sh, num s) {
    for (var i = 0; i < 9; i++) {
      coefficients[i].addScaledVector(sh.coefficients[i], s);
    }

    return this;
  }

  SphericalHarmonics3 scale(num s) {
    for (var i = 0; i < 9; i++) {
      coefficients[i].multiplyScalar(s);
    }

    return this;
  }

  SphericalHarmonics3 lerp(SphericalHarmonics3 sh, double alpha) {
    for (var i = 0; i < 9; i++) {
      coefficients[i].lerp(sh.coefficients[i], alpha);
    }

    return this;
  }

  bool equals(SphericalHarmonics3 sh) {
    for (var i = 0; i < 9; i++) {
      if (!coefficients[i].equals(sh.coefficients[i])) {
        return false;
      }
    }

    return true;
  }

  SphericalHarmonics3 copy(SphericalHarmonics3 sh) {
    return set(sh.coefficients);
  }

  SphericalHarmonics3 clone() {
    return SphericalHarmonics3().copy(this);
  }

  SphericalHarmonics3 fromArray(List<double> array, [int offset = 0]) {
    var coefficients = this.coefficients;

    for (var i = 0; i < 9; i++) {
      coefficients[i].fromArray(array, offset + (i * 3));
    }

    return this;
  }

  List<double> toArray(List<double> array, [int offset = 0]) {
    var coefficients = this.coefficients;

    for (var i = 0; i < 9; i++) {
      coefficients[i].toArray(array, offset + (i * 3));
    }

    return array;
  }

  // evaluate the basis functions
  // shBasis is an Array[ 9 ]
  static getBasisAt(Vector3 normal, List<double> shBasis) {
    // normal is assumed to be unit length

    var x = normal.x, y = normal.y, z = normal.z;

    // band 0
    shBasis[0] = 0.282095;

    // band 1
    shBasis[1] = 0.488603 * y;
    shBasis[2] = 0.488603 * z;
    shBasis[3] = 0.488603 * x;

    // band 2
    shBasis[4] = 1.092548 * x * y;
    shBasis[5] = 1.092548 * y * z;
    shBasis[6] = 0.315392 * (3 * z * z - 1);
    shBasis[7] = 1.092548 * x * z;
    shBasis[8] = 0.546274 * (x * x - y * y);
  }
}
