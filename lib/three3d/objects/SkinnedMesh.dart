part of three_objects;

var _basePosition = new Vector3.init();

var _skinIndex = new Vector4.init();
var _skinWeight = new Vector4.init();

var _vector = new Vector3.init();
var _matrix = new Matrix4();

class SkinnedMesh extends Mesh {
  bool isSkinnedMesh = true;
  String bindMode = "attached";
  Matrix4? bindMatrix = new Matrix4();
  Matrix4 bindMatrixInverse = new Matrix4();
  Skeleton? skeleton;
  String type = "SkinnedMesh";

  SkinnedMesh(geometry, material) : super(geometry, material) {}

  clone([bool? recursive]) {
    return SkinnedMesh(this.geometry!, this.material).copy(this, recursive);
  }

  copy(Object3D source, [bool? recursive]) {
    super.copy(source);

    SkinnedMesh source1 = source as SkinnedMesh;

    this.bindMode = source1.bindMode;
    this.bindMatrix!.copy(source1.bindMatrix);
    this.bindMatrixInverse.copy(source1.bindMatrixInverse);

    this.skeleton = source1.skeleton;

    return this;
  }

  bind(skeleton, Matrix4? bindMatrix) {
    this.skeleton = skeleton;

    if (bindMatrix == null) {
      this.updateMatrixWorld(true);

      this.skeleton!.calculateInverses();

      bindMatrix = this.matrixWorld;
    }

    this.bindMatrix!.copy(bindMatrix);
    this.bindMatrixInverse.copy(bindMatrix).invert();
  }

  pose() {
    this.skeleton!.pose();
  }

  normalizeSkinWeights() {
    var vector = new Vector4.init();

    var skinWeight = this.geometry!.attributes["skinWeight"];

    for (var i = 0, l = skinWeight.count; i < l; i++) {
      vector.x = skinWeight.getX(i);
      vector.y = skinWeight.getY(i);
      vector.z = skinWeight.getZ(i);
      vector.w = skinWeight.getW(i);

      var scale = 1.0 / vector.manhattanLength();

      if (scale != double.infinity) {
        vector.multiplyScalar(scale);
      } else {
        vector.set(1, 0, 0, 0); // do something reasonable

      }

      skinWeight.setXYZW(i, vector.x, vector.y, vector.z, vector.w);
    }
  }

  updateMatrixWorld(force) {
    super.updateMatrixWorld(force);

    if (this.bindMode == 'attached') {
      this.bindMatrixInverse.copy(this.matrixWorld).invert();
    } else if (this.bindMode == 'detached') {
      this.bindMatrixInverse.copy(this.bindMatrix).invert();
    } else {
      print('THREE.SkinnedMesh: Unrecognized bindMode: ${this.bindMode}');
    }
  }

  boneTransform(index, target) {
    var skeleton = this.skeleton;
    var geometry = this.geometry!;

    _skinIndex.fromBufferAttribute(
        geometry.attributes["skinIndex"], index, null);
    _skinWeight.fromBufferAttribute(
        geometry.attributes["skinWeight"], index, null);

    _basePosition.copy(target).applyMatrix4(this.bindMatrix);

    target.set(0, 0, 0);

    for (var i = 0; i < 4; i++) {
      var weight = _skinWeight.getComponent(i);

      if (weight != 0) {
        var boneIndex = _skinIndex.getComponent(i);

        _matrix.multiplyMatrices(skeleton!.bones[boneIndex].matrixWorld,
            skeleton.boneInverses[boneIndex]);

        target.addScaledVector(
            _vector.copy(_basePosition).applyMatrix4(_matrix), weight);
      }
    }

    return target.applyMatrix4(this.bindMatrixInverse);
  }

  getValue(name) {
    if (name == "bindMatrix") {
      return this.bindMatrix;
    } else if (name == "bindMatrixInverse") {
      return this.bindMatrixInverse;
    } else {
      return super.getValue(name);
    }
  }
}
