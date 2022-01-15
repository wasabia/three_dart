import 'package:three_dart/three_dart.dart';

class ThreeHelper {
  // 绕某个点旋转
  // https://stackoverflow.com/questions/42812861/three-js-pivot-point/42866733#42866733
  // obj - your object (THREE.Object3D or derived)
  // point - the point of rotation (THREE.Vector3)
  // axis - the axis of rotation (normalized THREE.Vector3)
  // theta - radian value of rotation
  // pointIsWorld - boolean indicating the point is in world coordinates (default = false)
  static rotateAboutPoint(obj, point, axis, theta,
      {bool pointIsWorld = false}) {
    if (pointIsWorld) {
      obj.parent.localToWorld(obj.position); // compensate for world coordinate
    }

    obj.position.sub(point); // remove the offset
    obj.position.applyAxisAngle(axis, theta); // rotate the POSITION
    obj.position.add(point); // re-add the offset

    if (pointIsWorld) {
      obj.parent
          .worldToLocal(obj.position); // undo world coordinates compensation
    }

    obj.rotateOnAxis(axis, theta); // rotate the OBJECT
  }

  static rotateWithPoint(obj, anchorPoint,
      {angleX = 0.0, angleY = 0.0, angleZ = 0.0}) {
    /// step 1: calculate move direction and move distance:
    var moveDir = new Vector3(anchorPoint.x - obj.position.x,
        anchorPoint.y - obj.position.y, anchorPoint.z - obj.position.z);
    moveDir.normalize();
    var moveDist = obj.position.distanceTo(anchorPoint);

    /// step 2: move camera to anchor point
    obj.translateOnAxis(moveDir, moveDist);

    /// step 3: rotate camera
    // obj.rotateX(angleX);
    // obj.rotateY(angleY);
    // obj.rotateZ(angleZ);
    obj.rotation.z = angleZ;

    /// step4: move camera along the opposite direction
    moveDir.multiplyScalar(-1);
    obj.translateOnAxis(moveDir, moveDist);
  }

  //make sure rotateAxis is already Normalize:
  static rotatePointWithPoint(Vector3 point, Vector3 rotateAxis, num angle) {
    var _point = point.clone();

    var axis = rotateAxis;

    // Define the matrix:
    var matrix = new Matrix4();

    // Define the rotation in radians:
    var radians = angle * Math.PI / 180.0;

    // Rotate the matrix:
    matrix.makeRotationAxis(axis, radians);

    // Now apply the rotation to all vectors in the tree
    // Define the vector3:

    _point.applyMatrix4(matrix);

    return _point;
  }
}
