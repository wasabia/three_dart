import 'package:flutter_gl/flutter_gl.dart';
import 'package:three_dart/three3d/core/index.dart';
import 'package:three_dart/three3d/geometries/index.dart';
import 'package:three_dart/three3d/materials/index.dart';
import 'package:three_dart/three3d/math/index.dart';
import 'package:three_dart/three3d/objects/line.dart';
import 'package:three_dart/three3d/objects/mesh.dart';

var _axis = /*@__PURE__*/ Vector3.init();
var _lineGeometry, _coneGeometry;

class ArrowHelper extends Object3D {
  late Line line;
  late Mesh cone;

  ArrowHelper(dir, origin, length, color, headLength, headWidth) : super() {
    // dir is assumed to be normalized

    type = 'ArrowHelper';

    dir ??= Vector3(0, 0, 1);
    origin ??= Vector3(0, 0, 0);
    length ??= 1;
    color ??= 0xffff00;
    headLength ??= 0.2 * length;
    headWidth ??= 0.2 * headLength;

    if (_lineGeometry == null) {
      _lineGeometry = BufferGeometry();
      _lineGeometry.setAttribute('position', Float32BufferAttribute(Float32Array.from([0, 0, 0, 0, 1, 0]), 3, false));

      _coneGeometry = CylinderGeometry(0, 0.5, 1, 5, 1);
      _coneGeometry.translate(0, -0.5, 0);
    }

    position.copy(origin);

    line = Line(_lineGeometry, LineBasicMaterial({"color": color, "toneMapped": false}));
    line.matrixAutoUpdate = false;
    add(line);

    cone = Mesh(_coneGeometry, MeshBasicMaterial({"color": color, "toneMapped": false}));
    cone.matrixAutoUpdate = false;
    add(cone);

    setDirection(dir);
    setLength(length, headLength, headWidth);
  }

  setDirection(dir) {
    // dir is assumed to be normalized

    if (dir.y > 0.99999) {
      quaternion.set(0, 0, 0, 1);
    } else if (dir.y < -0.99999) {
      quaternion.set(1, 0, 0, 0);
    } else {
      _axis.set(dir.z, 0, -dir.x).normalize();

      var radians = Math.acos(dir.y);

      quaternion.setFromAxisAngle(_axis, radians);
    }
  }

  setLength(length, headLength, headWidth) {
    headLength ??= 0.2 * length;
    headWidth ??= 0.2 * headLength;

    line.scale.set(1, Math.max(0.0001, length - headLength), 1); // see #17458
    line.updateMatrix();

    cone.scale.set(headWidth, headLength, headWidth);
    cone.position.y = length;
    cone.updateMatrix();
  }

  void setColor(Color color) {
    line.material?.color?.set(color);
    cone.material?.color?.set(color);
  }

  @override
  ArrowHelper copy(Object3D source, [bool? recursive]) {
    super.copy(source, false);
    if (source is ArrowHelper) {
      line.copy(source.line, false);
      cone.copy(source.cone, false);
    }
    return this;
  }
}
