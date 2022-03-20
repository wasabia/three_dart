part of three_helpers;

class PlaneHelper extends Line {
  String type = "PlaneHelper";
  num size = 1.0;
  Plane? plane;

  PlaneHelper.create(geometry, material) : super(geometry, material) {}

  factory PlaneHelper(plane, [size = 1, hex = 0xffff00]) {
    var color = hex;

    var positions = [
      1,
      -1,
      1,
      -1,
      1,
      1,
      -1,
      -1,
      1,
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
      1,
      0,
      0,
      1,
      0,
      0,
      0
    ];

    var geometry = new BufferGeometry();
    geometry.setAttribute(
        'position', new Float32BufferAttribute(positions, 3, false));
    geometry.computeBoundingSphere();

    var planeHelper = PlaneHelper.create(
        geometry, new LineBasicMaterial({"color": color, "toneMapped": false}));

    planeHelper.plane = plane;

    planeHelper.size = size;

    var positions2 = [
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
      1,
      1,
      -1,
      -1,
      1,
      1,
      -1,
      1
    ];

    var geometry2 = new BufferGeometry();
    geometry2.setAttribute(
        'position', new Float32BufferAttribute(positions2, 3, false));
    geometry2.computeBoundingSphere();

    planeHelper.add(Mesh(
        geometry2,
        MeshBasicMaterial({
          "color": color,
          "opacity": 0.2,
          "transparent": true,
          "depthWrite": false,
          "toneMapped": false
        })));

    return planeHelper;
  }

  updateMatrixWorld([bool force = false]) {
    var scale = -this.plane!.constant;

    if (Math.abs(scale) < 1e-8) scale = 1e-8; // sign does not matter

    this.scale.set(0.5 * this.size, 0.5 * this.size, scale);

    this.children[0].material.side = (scale < 0)
        ? BackSide
        : FrontSide; // renderer flips side when determinant < 0; flipping not wanted here

    this.lookAt(this.plane!.normal);

    super.updateMatrixWorld(force);
  }
}
