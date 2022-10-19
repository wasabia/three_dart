import 'package:flutter_gl/flutter_gl.dart';
import 'package:three_dart/three3d/core/index.dart';
import 'package:three_dart/three3d/lights/index.dart';
import 'package:three_dart/three3d/materials/line_basic_material.dart';
import 'package:three_dart/three3d/math/index.dart';
import 'package:three_dart/three3d/objects/line.dart';

var _v1 = /*@__PURE__*/ Vector3.init();
var _v2 = /*@__PURE__*/ Vector3.init();
var _v3 = /*@__PURE__*/ Vector3.init();

class DirectionalLightHelper extends Object3D {
  late DirectionalLight light;
  late Line lightPlane;
  late Line targetLine;
  Color? color;

  DirectionalLightHelper(this.light, [int? size = 1, this.color]) : super() {
    light.updateMatrixWorld(false);

    matrix = light.matrixWorld;
    matrixAutoUpdate = false;

    size ??= 1;
    var geometry = BufferGeometry();

    double _size = size.toDouble();

    List<double> _posData = [
      -_size,
      _size,
      0.0,
      _size,
      _size,
      0.0,
      _size,
      -_size,
      0.0,
      -_size,
      -_size,
      0.0,
      -_size,
      _size,
      0.0
    ];

    geometry.setAttribute('position', Float32BufferAttribute(Float32Array.from(_posData), 3, false));

    var material = LineBasicMaterial({"fog": false, "toneMapped": false});

    lightPlane = Line(geometry, material);
    add(lightPlane);

    geometry = BufferGeometry();
    List<double> _d2 = [0, 0, 0, 0, 0, 1];
    geometry.setAttribute('position', Float32BufferAttribute(Float32Array.from(_d2), 3, false));

    targetLine = Line(geometry, material);
    add(targetLine);

    update();
  }

  @override
  dispose() {
    lightPlane.geometry!.dispose();
    lightPlane.material.dispose();
    targetLine.geometry!.dispose();
    targetLine.material.dispose();
  }

  update() {
    _v1.setFromMatrixPosition(light.matrixWorld);
    _v2.setFromMatrixPosition(light.target!.matrixWorld);
    _v3.subVectors(_v2, _v1);

    lightPlane.lookAt(_v2);

    if (color != null) {
      lightPlane.material.color.set(color);
      targetLine.material.color.set(color);
    } else {
      lightPlane.material.color.copy(light.color);
      targetLine.material.color.copy(light.color);
    }

    targetLine.lookAt(_v2);
    targetLine.scale.z = _v3.length();
  }
}
