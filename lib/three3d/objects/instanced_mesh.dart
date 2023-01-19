import 'package:flutter_gl/flutter_gl.dart';
import 'package:three_dart/three3d/core/index.dart';
import 'package:three_dart/three3d/materials/index.dart';
import 'package:three_dart/three3d/math/index.dart';
import 'package:three_dart/three3d/objects/mesh.dart';

var _instanceLocalMatrix = Matrix4();
var _instanceWorldMatrix = Matrix4();

List<Intersection> _instanceIntersects = [];

var _mesh = Mesh(BufferGeometry(), Material());

class InstancedMesh extends Mesh {
  InstancedMesh(BufferGeometry? geometry, material, int count)
      : super(geometry, material) {
    type = "InstancedMesh";

    var dl = Float32Array(count * 16);
    instanceMatrix = InstancedBufferAttribute(dl, 16, false);
    instanceColor = null;

    this.count = count;

    frustumCulled = false;
  }

  @override
  InstancedMesh copy(Object3D source, [bool? recursive]) {
    super.copy(source);
    if (source is InstancedMesh) {
      instanceMatrix!.copy(source.instanceMatrix!);
      if (source.instanceColor != null) {
        instanceColor = source.instanceColor!.clone();
      }
      count = source.count;
    }
    return this;
  }

  Color getColorAt(int index, Color color) {
    return color.fromArray(instanceColor!.array.data, index * 3);
  }

  getMatrixAt(int index, matrix) {
    return matrix.fromArray(instanceMatrix!.array, index * 16);
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

  void setColorAt(int index, Color color) {
    instanceColor ??= InstancedBufferAttribute(
        Float32Array((instanceMatrix!.count * 3).toInt()), 3, false);

    color.toArray(instanceColor!.array, index);
  }

  void setMatrixAt(int index, Matrix4 matrix) {
    matrix.toArray(instanceMatrix!.array, index * 16);
  }

  @override
  void updateMorphTargets() {}

  @override
  void dispose() {
    dispatchEvent(Event({"type": "dispose"}));
  }
}
