part of three_objects;

var _geometry;

var _intersectPoint = Vector3.init();
var _worldScale = Vector3.init();
var _mvPosition = Vector3.init();

var _alignedPosition = Vector2(null, null);
var _rotatedPosition = Vector2(null, null);
var _viewWorldMatrix = Matrix4();

var _spritevA = Vector3.init();
var _spritevB = Vector3.init();
var _spritevC = Vector3.init();

var _spriteuvA = Vector2(null, null);
var _spriteuvB = Vector2(null, null);
var _spriteuvC = Vector2(null, null);

class Sprite extends Object3D {
  Vector2 center = Vector2(0.5, 0.5);

  bool isSprite = true;

  Sprite([Material? material]) : super() {
    type = 'Sprite';

    if (_geometry == null) {
      _geometry = BufferGeometry();

      var float32List = Float32Array.from([
        -0.5,
        -0.5,
        0,
        0,
        0,
        0.5,
        -0.5,
        0,
        1,
        0,
        0.5,
        0.5,
        0,
        1,
        1,
        -0.5,
        0.5,
        0,
        0,
        1
      ]);

      var interleavedBuffer = InterleavedBuffer(float32List, 5);

      _geometry.setIndex([0, 1, 2, 0, 2, 3]);
      _geometry.setAttribute('position',
          InterleavedBufferAttribute(interleavedBuffer, 3, 0, false));
      _geometry.setAttribute(
          'uv', InterleavedBufferAttribute(interleavedBuffer, 2, 3, false));
    }

    geometry = _geometry;
    this.material = (material != null) ? material : SpriteMaterial(null);
  }

  Sprite.fromJSON(Map<String, dynamic> json, Map<String, dynamic> rootJSON)
      : super.fromJSON(json, rootJSON) {
    type = 'Sprite';
  }

  @override
  void raycast(Raycaster raycaster, List<Intersection> intersects) {
    _worldScale.setFromMatrixScale(matrixWorld);

    _viewWorldMatrix.copy(raycaster.camera.matrixWorld);
    modelViewMatrix.multiplyMatrices(
        raycaster.camera.matrixWorldInverse, matrixWorld);

    _mvPosition.setFromMatrixPosition(modelViewMatrix);

    if (raycaster.camera.type == "PerspectiveCamera" &&
        material.sizeAttenuation == false) {
      _worldScale.multiplyScalar(-_mvPosition.z);
    }

    var rotation = material.rotation;
    double? sin, cos;

    if (rotation != 0) {
      cos = Math.cos(rotation);
      sin = Math.sin(rotation);
    }

    var center = this.center;

    transformVertex(_spritevA.set(-0.5, -0.5, 0), _mvPosition, center,
        _worldScale, sin, cos);
    transformVertex(_spritevB.set(0.5, -0.5, 0), _mvPosition, center,
        _worldScale, sin, cos);
    transformVertex(
        _spritevC.set(0.5, 0.5, 0), _mvPosition, center, _worldScale, sin, cos);

    _spriteuvA.set(0, 0);
    _spriteuvB.set(1, 0);
    _spriteuvC.set(1, 1);

    // check first triangle
    var intersect = raycaster.ray.intersectTriangle(
        _spritevA, _spritevB, _spritevC, false, _intersectPoint);

    if (intersect == null) {
      // check second triangle
      transformVertex(_spritevB.set(-0.5, 0.5, 0), _mvPosition, center,
          _worldScale, sin, cos);
      _spriteuvB.set(0, 1);

      intersect = raycaster.ray.intersectTriangle(
          _spritevA, _spritevC, _spritevB, false, _intersectPoint);
      if (intersect == null) {
        return;
      }
    }

    var distance = raycaster.ray.origin.distanceTo(_intersectPoint);

    if (distance < raycaster.near || distance > raycaster.far) return;

    intersects.add(Intersection({
      "distance": distance,
      "point": _intersectPoint.clone(),
      "uv": Triangle.static_getUV(_intersectPoint, _spritevA, _spritevB,
          _spritevC, _spriteuvA, _spriteuvB, _spriteuvC, Vector2(null, null)),
      "face": null,
      "object": this
    }));
  }

  @override
  Sprite copy(Object3D source, [bool? recursive]) {
    super.copy(source);

    if (source is Sprite) {
      if (source.center != null) center.copy(source.center);
      material = source.material;
    }
    return this;
  }
}

void transformVertex(vertexPosition, Vector3 mvPosition, Vector2 center, scale,
    double? sin, double? cos) {
  // compute position in camera space
  _alignedPosition
      .subVectors(vertexPosition, center)
      .addScalar(0.5)
      .multiply(scale);

  // to check if rotation is not zero
  if (sin != null && cos != null) {
    _rotatedPosition.x =
        (cos * _alignedPosition.x) - (sin * _alignedPosition.y);
    _rotatedPosition.y =
        (sin * _alignedPosition.x) + (cos * _alignedPosition.y);
  } else {
    _rotatedPosition.copy(_alignedPosition);
  }

  vertexPosition.copy(mvPosition);
  vertexPosition.x += _rotatedPosition.x;
  vertexPosition.y += _rotatedPosition.y;

  // transform to world space
  vertexPosition.applyMatrix4(_viewWorldMatrix);
}
