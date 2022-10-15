
import 'package:flutter_gl/flutter_gl.dart';
import 'package:three_dart/three3d/core/buffer_attribute.dart';
import 'package:three_dart/three3d/core/buffer_geometry.dart';
import 'package:three_dart/three3d/materials/line_basic_material.dart';
import 'package:three_dart/three3d/math/box3.dart';
import 'package:three_dart/three3d/objects/line_segments.dart';

class Box3Helper extends LineSegments {
  Box3? box;

  Box3Helper.create(geometry, material) : super(geometry, material);

  factory Box3Helper(box, [color = 0xffff00]) {
    var indices = Uint16Array.from([
      0,
      1,
      1,
      2,
      2,
      3,
      3,
      0,
      4,
      5,
      5,
      6,
      6,
      7,
      7,
      4,
      0,
      4,
      1,
      5,
      2,
      6,
      3,
      7
    ]);

    List<double> positions = [
      1,
      1,
      1,
      -1,
      1,
      1,
      -1,
      -1,
      1,
      1,
      -1,
      1,
      1,
      1,
      -1,
      -1,
      1,
      -1,
      -1,
      -1,
      -1,
      1,
      -1,
      -1
    ];

    var geometry = BufferGeometry();

    geometry.setIndex(Uint16BufferAttribute(indices, 1, false));

    geometry.setAttribute(
        'position',
        Float32BufferAttribute(Float32Array.from(positions), 3, false));

    var box3Helper = Box3Helper.create(
        geometry, LineBasicMaterial({"color": color, "toneMapped": false}));

    box3Helper.box = box;

    box3Helper.type = 'Box3Helper';

    box3Helper.geometry!.computeBoundingSphere();

    return box3Helper;
  }

  @override
  updateMatrixWorld([bool force = false]) {
    var box = this.box!;

    if (box.isEmpty()) return;

    box.getCenter(position);

    box.getSize(scale);

    scale.multiplyScalar(0.5);

    super.updateMatrixWorld(force);
  }
}
