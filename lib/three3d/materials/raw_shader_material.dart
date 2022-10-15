import 'package:three_dart/three3d/constants.dart';
import 'package:three_dart/three3d/materials/material.dart';
import 'package:three_dart/three3d/materials/shader_material.dart';
import 'package:three_dart/three3d/math/index.dart';

class RawShaderMaterial extends ShaderMaterial {
  RawShaderMaterial([parameters]) : super(parameters) {
    type = 'RawShaderMaterial';
  }
}
