import 'package:three_dart/three3d/geometries/cylinder_geometry.dart';
import 'package:three_dart/three3d/math/index.dart';

class ConeGeometry extends CylinderGeometry {
  ConeGeometry([
    radius = 1,
    height = 1,
    radialSegments = 8,
    heightSegments = 1,
    openEnded = false,
    thetaStart = 0,
    thetaLength = Math.pi * 2,
  ]) : super(
          0,
          radius,
          height,
          radialSegments,
          heightSegments,
          openEnded,
          thetaStart,
          thetaLength,
        ) {
    type = 'ConeGeometry';
    parameters = {
      "radius": radius,
      "height": height,
      "radialSegments": radialSegments,
      "heightSegments": heightSegments,
      "openEnded": openEnded,
      "thetaStart": thetaStart,
      "thetaLength": thetaLength
    };
  }
}
