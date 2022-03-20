part of three_objects;

var _instanceLocalMatrix = Matrix4();
var _instanceWorldMatrix = Matrix4();

List<Intersection> _instanceIntersects = [];

var _mesh = Mesh(BufferGeometry(), Material());

class InstancedMesh extends Mesh {
  late InstancedBufferAttribute instanceMatrix;
  late BufferAttribute? instanceColor;

  InstancedMesh(geometry, material, count) : super(geometry, material) {
    type = "InstancedMesh";
    isInstancedMesh = true;

    var dl = Float32List(count * 16);
    instanceMatrix = InstancedBufferAttribute(dl, 16, false);
    instanceColor = null;

    this.count = count;

    frustumCulled = false;
  }

  @override
  InstancedMesh copy(Object3D source, [bool? recursive]) {
    super.copy(source);
    if (source is InstancedMesh) {
      instanceMatrix.copy(source.instanceMatrix);
      if (source.instanceColor != null) {
        instanceColor = source.instanceColor!.clone();
      }
      count = source.count;
    }
    return this;
  }

  Color getColorAt(int index, Color color) {
    return color.fromArray(instanceColor!.array, index * 3);
  }

  getMatrixAt(int index, matrix) {
    return matrix.fromArray(instanceMatrix.array, index * 16);
  }

  @override
  void raycast(Raycaster raycaster, List<Intersection> intersects) {
    var matrixWorld = this.matrixWorld;
    var raycastTimes = count;

    _mesh.geometry = geometry;
    _mesh.material = material;

    if (_mesh.material == null) return;

    for (var instanceId = 0; instanceId < raycastTimes!; instanceId++) {
      // calculate the world matrix for each instance

      getMatrixAt(instanceId, _instanceLocalMatrix);

      _instanceWorldMatrix.multiplyMatrices(matrixWorld, _instanceLocalMatrix);

      // the mesh represents this single instance

      _mesh.matrixWorld = _instanceWorldMatrix;

      _mesh.raycast(raycaster, _instanceIntersects);

      // process the result of raycast

      for (var i = 0, l = _instanceIntersects.length; i < l; i++) {
        var intersect = _instanceIntersects[i];
        intersect.instanceId = instanceId;
        intersect.object = this;
        intersects.add(intersect);
      }

      _instanceIntersects.length = 0;
    }
  }

  List<num> setColorAt(int index, Color color) {
    instanceColor ??= BufferAttribute(
        Float32List((instanceMatrix.count * 3).toInt()), 3, false);

    return color.toArray(instanceColor!.array, index * 3);
  }

  setMatrixAt(int index, Matrix4 matrix) {
    matrix.toArray(instanceMatrix.array, index * 16);
  }

  @override
  void updateMorphTargets() {}

  @override
  void dispose() {
    dispatchEvent(Event({"type": "dispose"}));
  }
}
