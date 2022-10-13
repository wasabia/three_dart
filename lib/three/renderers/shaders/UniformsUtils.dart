// import 'package:three_dart/three/math/index.dart';
// import 'package:three_dart/three/textures/index.dart';

part of three_shaders;

/// Uniform Utilities

Map<String, dynamic> cloneUniforms(Map<String, dynamic> src) {
  var dst = <String, dynamic>{};

  for (var u in src.keys) {
    dst[u] = {};

    for (var p in src[u].keys) {
      var property = src[u][p];

      if (property != null &&
          (property is Color ||
              property is Matrix3 ||
              property is Matrix4 ||
              property is Vector2 ||
              property is Vector3 ||
              property is Vector4 ||
              property is Texture ||
              property is Quaternion)) {
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
