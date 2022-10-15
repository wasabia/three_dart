
import 'package:flutter_gl/flutter_gl.dart';
import 'package:three_dart/three3d/core/buffer_attribute.dart';
import 'package:three_dart/three3d/core/buffer_geometry.dart';
import 'package:three_dart/three3d/materials/line_basic_material.dart';
import 'package:three_dart/three3d/math/index.dart';
import 'package:three_dart/three3d/objects/bone.dart';
import 'package:three_dart/three3d/objects/line_segments.dart';

var _shvector = /*@__PURE__*/ Vector3.init();
var _boneMatrix = /*@__PURE__*/ Matrix4();
var _matrixWorldInv = /*@__PURE__*/ Matrix4();

class SkeletonHelper extends LineSegments {
  @override
  String type = 'SkeletonHelper';
  bool isSkeletonHelper = true;
  @override
  bool matrixAutoUpdate = false;
  late dynamic root;
  late dynamic bones;

  SkeletonHelper.create(geometry, material) : super(geometry, material);

  factory SkeletonHelper(object) {
    var bones = getBoneList(object);

    var geometry = BufferGeometry();

    List<double> vertices = [];
    List<double> colors = [];

    var color1 = Color(0, 0, 1);
    var color2 = Color(0, 1, 0);

    for (var i = 0; i < bones.length; i++) {
      var bone = bones[i];

      if (bone.parent != null && bone.parent!.type == "Bone") {
        vertices.addAll([0, 0, 0]);
        vertices.addAll([0, 0, 0]);
        colors.addAll(
            [color1.r.toDouble(), color1.g.toDouble(), color1.b.toDouble()]);
        colors.addAll(
            [color2.r.toDouble(), color2.g.toDouble(), color2.b.toDouble()]);
      }
    }

    geometry.setAttribute(
        'position',
        Float32BufferAttribute(Float32Array.from(vertices), 3, false));
    geometry.setAttribute(
        'color',
        Float32BufferAttribute(Float32Array.from(colors), 3, false));

    var material = LineBasicMaterial({
      "vertexColors": true,
      "depthTest": false,
      "depthWrite": false,
      "toneMapped": false,
      "transparent": true
    });

    var keletonHelper = SkeletonHelper.create(geometry, material);

    keletonHelper.root = object;
    keletonHelper.bones = bones;

    keletonHelper.matrix = object.matrixWorld;

    return keletonHelper;
  }

  @override
  updateMatrixWorld([bool force = false]) {
    var bones = this.bones;

    var geometry = this.geometry!;
    var position = geometry.getAttribute('position');

    _matrixWorldInv.copy(root.matrixWorld).invert();

    for (var i = 0, j = 0; i < bones.length; i++) {
      var bone = bones[i];

      if (bone.parent != null && bone.parent.type == "Bone") {
        _boneMatrix.multiplyMatrices(_matrixWorldInv, bone.matrixWorld);
        _shvector.setFromMatrixPosition(_boneMatrix);
        position.setXYZ(j, _shvector.x, _shvector.y, _shvector.z);

        _boneMatrix.multiplyMatrices(_matrixWorldInv, bone.parent.matrixWorld);
        _shvector.setFromMatrixPosition(_boneMatrix);
        position.setXYZ(j + 1, _shvector.x, _shvector.y, _shvector.z);

        j += 2;
      }
    }

    geometry.getAttribute('position').needsUpdate = true;

    super.updateMatrixWorld(force);
  }
}

List<Bone> getBoneList(object) {
  List<Bone> boneList = [];

  if (object != null && object.type == "Bone") {
    boneList.add(object);
  }

  for (var i = 0; i < object.children.length; i++) {
    boneList.addAll(getBoneList(object.children[i]));
  }

  return boneList;
}
