part of three_helpers;

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
