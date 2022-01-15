part of three_helpers;

var _axis = /*@__PURE__*/ new Vector3.init();
var _lineGeometry, _coneGeometry;

class ArrowHelper extends Object3D {
  late Line line;
  late Mesh cone;

  ArrowHelper(dir, origin, length, color, headLength, headWidth) : super() {
    // dir is assumed to be normalized

    this.type = 'ArrowHelper';

    if (dir == null) dir = new Vector3(0, 0, 1);
    if (origin == null) origin = new Vector3(0, 0, 0);
    if (length == null) length = 1;
    if (color == null) color = 0xffff00;
    if (headLength == null) headLength = 0.2 * length;
    if (headWidth == null) headWidth = 0.2 * headLength;

    if (_lineGeometry == null) {
      _lineGeometry = new BufferGeometry();
      _lineGeometry.setAttribute(
          'position', new Float32BufferAttribute([0, 0, 0, 0, 1, 0], 3, false));

      _coneGeometry = new CylinderGeometry(0, 0.5, 1, 5, 1);
      _coneGeometry.translate(0, -0.5, 0);
    }

    this.position.copy(origin);

    this.line = new Line(_lineGeometry,
        new LineBasicMaterial({"color": color, "toneMapped": false}));
    this.line.matrixAutoUpdate = false;
    this.add(this.line);

    this.cone = new Mesh(_coneGeometry,
        new MeshBasicMaterial({"color": color, "toneMapped": false}));
    this.cone.matrixAutoUpdate = false;
    this.add(this.cone);

    this.setDirection(dir);
    this.setLength(length, headLength, headWidth);
  }

  setDirection(dir) {
    // dir is assumed to be normalized

    if (dir.y > 0.99999) {
      this.quaternion.set(0, 0, 0, 1);
    } else if (dir.y < -0.99999) {
      this.quaternion.set(1, 0, 0, 0);
    } else {
      _axis.set(dir.z, 0, -dir.x).normalize();

      var radians = Math.acos(dir.y);

      this.quaternion.setFromAxisAngle(_axis, radians);
    }
  }

  setLength(length, headLength, headWidth) {
    if (headLength == null) headLength = 0.2 * length;
    if (headWidth == null) headWidth = 0.2 * headLength;

    this
        .line
        .scale
        .set(1, Math.max(0.0001, length - headLength), 1); // see #17458
    this.line.updateMatrix();

    this.cone.scale.set(headWidth, headLength, headWidth);
    this.cone.position.y = length;
    this.cone.updateMatrix();
  }

  setColor(color) {
    this.line.material.color.set(color);
    this.cone.material.color.set(color);
  }

  copy(source, [bool? recursive]) {
    super.copy(source, false);

    var source1 = source as ArrowHelper;

    this.line.copy(source1.line, false);
    this.cone.copy(source1.cone, false);

    return this;
  }
}
