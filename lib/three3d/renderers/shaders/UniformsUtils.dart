// import 'package:three_dart/three3d/math/index.dart';
// import 'package:three_dart/three3d/textures/index.dart';

part of three_shaders;

/// Uniform Utilities

Map<String, dynamic> cloneUniforms(Map<String, dynamic> src) {
  var dst = <String, dynamic>{};

  for (var u in src.keys) {
    dst[u] = {};

    for (var p in src[u].keys) {
      var property = src[u][p];

      if (property != null &&
          (property.runtimeType == Color ||
              property.runtimeType == Matrix3 ||
              property.runtimeType == Matrix4 ||
              property.runtimeType == Vector2 ||
              property.runtimeType == Vector3 ||
              property.runtimeType == Vector4 ||
              property.runtimeType == Texture ||
              property.runtimeType == Quaternion)) {
        dst[u][p] = property.clone();
      } else if (property is List) {
        dst[u][p] = property.sublist(0);
      } else {
        dst[u][p] = property;
      }
    }
  }

  return dst;
}

Map<String, dynamic> mergeUniforms(uniforms) {
  Map<String, dynamic> merged = <String, dynamic>{};

  for (var u = 0; u < uniforms.length; u++) {
    var tmp = cloneUniforms(uniforms[u]);

    for (var p in tmp.keys) {
      merged[p] = tmp[p];
    }
  }

  return merged;
}

class UniformsUtils {
  static Map<String, dynamic> clone(Map<String, dynamic> p) {
    return cloneUniforms(p);
  }

  static Map<String, dynamic> merge(p) {
    return mergeUniforms(p);
  }
}
