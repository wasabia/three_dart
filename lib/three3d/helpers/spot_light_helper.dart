import 'package:flutter_gl/flutter_gl.dart';
import 'package:three_dart/three3d/core/buffer_attribute.dart';
import 'package:three_dart/three3d/core/buffer_geometry.dart';
import 'package:three_dart/three3d/core/object_3d.dart';
import 'package:three_dart/three3d/lights/light.dart';
import 'package:three_dart/three3d/materials/line_basic_material.dart';
import 'package:three_dart/three3d/math/index.dart';
import 'package:three_dart/three3d/objects/line_segments.dart';

var _spotLightHelpervector = Vector3.init();

class SpotLightHelper extends Object3D {
  late Light light;

  late Color? color;
  late LineSegments cone;

  SpotLightHelper(this.light, this.color) : super() {
    matrixAutoUpdate = false;
    light.updateMatrixWorld(false);

    matrix = light.matrixWorld;

    var geometry = BufferGeometry();

    List<double> positions = [
      0,
      0,
      0,
      0,
      0,
      1,
      0,
      0,
      0,
      1,
      0,
      1,
      0,
      0,
      0,
      -1,
      0,
      1,
      0,
      0,
      0,
      0,
      1,
      1,
      0,
      0,
      0,
      0,
      -1,
      1
    ];

    for (var i = 0, j = 1, l = 32; i < l; i++, j++) {
      var p1 = (i / l) * Math.pi * 2;
      var p2 = (j / l) * Math.pi * 2;

      positions.addAll([Math.cos(p1), Math.sin(p1), 1, Math.cos(p2), Math.sin(p2), 1]);
    }

    geometry.setAttribute('position', Float32BufferAttribute(Float32Array.from(positions), 3, false));

    var material = LineBasicMaterial({"fog": false, "toneMapped": false});

    cone = LineSegments(geometry, material);
    add(cone);

    update();
  }

  @override
  dispose() {
    cone.geometry!.dispose();
    cone.material.dispose();
  }

  update() {
    light.updateMatrixWorld(false);

    double coneLength = light.distance ?? 1000;
    var coneWidth = coneLength * Math.tan(light.angle!);

    cone.scale.set(coneWidth, coneWidth, coneLength);

    _spotLightHelpervector.setFromMatrixPosition(light.target!.matrixWorld);

    cone.lookAt(_spotLightHelpervector);

    if (color != null) {
      cone.material.color.copy(color);
    } else {
      cone.material.color.copy(light.color);
    }
  }
}
