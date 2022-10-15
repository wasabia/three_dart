
import 'package:three_dart/three3d/core/index.dart';
import 'package:three_dart/three3d/math/index.dart';

class Camera extends Object3D {
  @override
  String type = "Camera";

  Matrix4 matrixWorldInverse = Matrix4();

  Matrix4 projectionMatrix = Matrix4();
  Matrix4 projectionMatrixInverse = Matrix4();

  late num fov;
  double zoom = 1.0;
  late num near;
  late num far;
  num focus = 10;
  late num aspect;
  num filmGauge = 35; // width of the film (default in millimeters)
  num filmOffset = 0; // horizontal film offset (same unit as gauge)

  //OrthographicCamera
  late num left;
  late num right;
  late num top;
  late num bottom;

  Map<String, dynamic>? view;

  late Vector4 viewport;

  Camera() : super();

  Camera.fromJSON(Map<String, dynamic> json, Map<String, dynamic> rootJSON)
      : super.fromJSON(json, rootJSON);

  updateProjectionMatrix() {
    print(" Camera.updateProjectionMatrix ");
  }

  @override
  Camera copy(Object3D source, [bool? recursive]) {
    super.copy(source, recursive);

    Camera source1 = source as Camera;

    matrixWorldInverse.copy(source1.matrixWorldInverse);

    projectionMatrix.copy(source1.projectionMatrix);
    projectionMatrixInverse.copy(source1.projectionMatrixInverse);

    return this;
  }

  @override
  Vector3 getWorldDirection(Vector3 target) {
    updateWorldMatrix(true, false);

    var e = matrixWorld.elements;

    return target.set(-e[8], -e[9], -e[10]).normalize();
  }

  @override
  void updateMatrixWorld([bool force = false]) {
    super.updateMatrixWorld(force);

    matrixWorldInverse.copy(matrixWorld).invert();
  }

  @override
  void updateWorldMatrix(updateParents, updateChildren) {
    super.updateWorldMatrix(updateParents, updateChildren);

    matrixWorldInverse.copy(matrixWorld).invert();
  }

  @override
  Camera clone([bool? recursive = true]) {
    return Camera()..copy(this);
  }
}
