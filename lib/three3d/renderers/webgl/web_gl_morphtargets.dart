
import 'package:flutter/foundation.dart';
import 'package:flutter_gl/flutter_gl.dart';
import 'package:three_dart/extra/console.dart';
import 'package:three_dart/three3d/constants.dart';
import 'package:three_dart/three3d/core/index.dart';
import 'package:three_dart/three3d/materials/index.dart';
import 'package:three_dart/three3d/math/index.dart';
import 'package:three_dart/three3d/renderers/webgl/index.dart';
import 'package:three_dart/three3d/textures/index.dart';
import 'package:three_dart/three3d/weak_map.dart';

int numericalSort(a, b) {
  return a[0] - b[0];
}

int absNumericalSort(a, b) {
  return Math.abs(b[1]) >= Math.abs(a[1]) ? 1 : -1;
}

denormalize(morph, BufferAttribute attribute) {
  var denominator = 1;
  NativeArray array = attribute is InterleavedBufferAttribute ? attribute.data!.array : attribute.array;

  if (array is Int8Array) {
    denominator = 127;
  } else if (array is Int16Array) {
    denominator = 32767;
  } else if (array is Int32Array) {
    denominator = 2147483647;
  } else {
    console.error('three.WebGLMorphtargets: Unsupported morph attribute data type: ', array);
  }

  morph.divideScalar(denominator);
}

class WebGLMorphtargets {
  var influencesList = {};
  var morphInfluences = Float32List(8);
  var morphTextures = WeakMap();
  var morph = Vector4();

  List<List<num>> workInfluences = [];

  dynamic gl;
  WebGLCapabilities capabilities;
  WebGLTextures textures;

  WebGLMorphtargets(this.gl, this.capabilities, this.textures) {
    for (var i = 0; i < 8; i++) {
      workInfluences.add([i, 0]);
    }
  }

  void update(Object3D object, BufferGeometry geometry, Material material, WebGLProgram program) {
    List<num>? objectInfluences = object.morphTargetInfluences;

    if (capabilities.isWebGL2 == true) {
      // instead of using attributes, the WebGL 2 code path encodes morph targets
      // into an array of data textures. Each layer represents a single morph target.

      var morphAttribute = geometry.morphAttributes["position"] ??
          geometry.morphAttributes["normal"] ??
          geometry.morphAttributes["color"];
      var morphTargetsCount = (morphAttribute != null) ? morphAttribute.length : 0;

      Map? entry = morphTextures.get(geometry);

      if (entry == null || (entry["count"] != morphTargetsCount)) {
        if (entry != null) entry["texture"].dispose();

        var hasMorphPosition = geometry.morphAttributes["position"] != null;
        var hasMorphNormals = geometry.morphAttributes["normal"] != null;
        var hasMorphColors = geometry.morphAttributes["color"] != null;

        var morphTargets = geometry.morphAttributes["position"] ?? [];
        var morphNormals = geometry.morphAttributes["normal"] ?? [];
        var morphColors = geometry.morphAttributes["color"] ?? [];

        int vertexDataCount = 0;
        if (hasMorphPosition) vertexDataCount = 1;
        if (hasMorphNormals) vertexDataCount = 2;
        if (hasMorphColors) vertexDataCount = 3;

        int width = (geometry.attributes["position"].count * vertexDataCount).toInt();
        int height = 1;

        if (width > capabilities.maxTextureSize) {
          height = Math.ceil(width / capabilities.maxTextureSize).toInt();
          width = capabilities.maxTextureSize.toInt();
        }

        var buffer = Float32Array((width * height * 4 * morphTargetsCount).toInt());

        var texture = DataArrayTexture(buffer, width, height, morphTargetsCount);
        texture.type = FloatType;
        texture.needsUpdate = true;

        // fill buffer

        int vertexDataStride = vertexDataCount * 4;

        for (var i = 0; i < morphTargetsCount; i++) {
          var morphTarget = morphTargets[i];

          int offset = (width * height * 4 * i).toInt();

          for (var j = 0; j < morphTarget.count; j++) {
            var stride = j * vertexDataStride;

            if (hasMorphPosition == true) {
              morph.fromBufferAttribute(morphTarget, j);

              if (morphTarget.normalized == true) {
                denormalize(morph, morphTarget);
              }

              buffer[offset + stride + 0] = morph.x.toDouble();
              buffer[offset + stride + 1] = morph.y.toDouble();
              buffer[offset + stride + 2] = morph.z.toDouble();
              buffer[offset + stride + 3] = 0;
            }

            if (hasMorphNormals == true) {
              var morphNormal = morphNormals[i];
              morph.fromBufferAttribute(morphNormal, j);

              if (morphNormal.normalized == true) {
                denormalize(morph, morphNormal);
              }

              buffer[offset + stride + 4] = morph.x.toDouble();
              buffer[offset + stride + 5] = morph.y.toDouble();
              buffer[offset + stride + 6] = morph.z.toDouble();
              buffer[offset + stride + 7] = 0;
            }

            if (hasMorphColors == true) {
              var morphColor = morphColors[i];
              morph.fromBufferAttribute(morphColor, j);

              if (morphColor.normalized == true) {
                denormalize(morph, morphColor);
              }

              buffer[offset + stride + 8] = morph.x.toDouble();
              buffer[offset + stride + 9] = morph.y.toDouble();
              buffer[offset + stride + 10] = morph.z.toDouble();
              buffer[offset + stride + 11] = ((morphColor.itemSize == 4) ? morph.w : 1).toDouble();
            }
          }
        }

        entry = {"count": morphTargetsCount, "texture": texture, "size": Vector2(width.toDouble(), height.toDouble())};

        morphTextures.set(geometry, entry);

        disposeTexture() {
          texture.dispose();

          morphTextures.delete(geometry);

          geometry.removeEventListener('dispose', disposeTexture);
        }

        geometry.addEventListener('dispose', disposeTexture);
      }

      //

      num morphInfluencesSum = 0;

      for (var i = 0; i < objectInfluences!.length; i++) {
        morphInfluencesSum += objectInfluences[i];
      }

      var morphBaseInfluence = geometry.morphTargetsRelative ? 1 : 1 - morphInfluencesSum;

      program.getUniforms().setValue(gl, 'morphTargetBaseInfluence', morphBaseInfluence);
      program.getUniforms().setValue(gl, 'morphTargetInfluences', objectInfluences);

      program.getUniforms().setValue(gl, 'morphTargetsTexture', entry["texture"], textures);
      program.getUniforms().setValue(gl, 'morphTargetsTextureSize', entry["size"]);
    } else {
      // When object doesn't have morph target influences defined, we treat it as a 0-length array
      // This is important to make sure we set up morphTargetBaseInfluence / morphTargetInfluences

      var length = objectInfluences == undefined ? 0 : objectInfluences!.length;

      List<List<num>>? influences = influencesList[geometry.id];

      if (influences == undefined || influences!.length != length) {
        // initialise list

        influences = [];

        for (var i = 0; i < length; i++) {
          influences.add([i, 0.0]);
        }

        influencesList[geometry.id] = influences;
      }

      // Collect influences

      for (var i = 0; i < length; i++) {
        var influence = influences[i];

        influence[0] = i;
        influence[1] = objectInfluences![i];
      }

      influences.sort(absNumericalSort);

      for (var i = 0; i < 8; i++) {
        if (i < length && influences[i][1] != 0) {
          workInfluences[i][0] = influences[i][0];
          workInfluences[i][1] = influences[i][1];
        } else {
          workInfluences[i][0] = Math.MAX_SAFE_INTEGER;
          workInfluences[i][1] = 0;
        }
      }

      workInfluences.sort(numericalSort);

      var morphTargets = geometry.morphAttributes["position"];
      var morphNormals = geometry.morphAttributes["normal"];

      num morphInfluencesSum = 0;

      for (var i = 0; i < 8; i++) {
        var influence = workInfluences[i];
        var index = influence[0].toInt();
        var value = influence[1];

        if (index != Math.MAX_SAFE_INTEGER && value != 0) {
          if (morphTargets != null && geometry.getAttribute('morphTarget$i') != morphTargets[index]) {
            geometry.setAttribute('morphTarget$i', morphTargets[index]);
          }

          if (morphNormals != null && geometry.getAttribute('morphNormal$i') != morphNormals[index]) {
            geometry.setAttribute('morphNormal$i', morphNormals[index]);
          }

          morphInfluences[i] = value.toDouble();
          morphInfluencesSum += value;
        } else {
          if (morphTargets != null && geometry.hasAttribute('morphTarget$i') == true) {
            geometry.deleteAttribute('morphTarget$i');
          }

          if (morphNormals != null && geometry.hasAttribute('morphNormal$i') == true) {
            geometry.deleteAttribute('morphNormal$i');
          }

          morphInfluences[i] = 0;
        }
      }

      // GLSL shader uses formula baseinfluence * base + sum(target * influence)
      // This allows us to switch between absolute morphs and relative morphs without changing shader code
      // When baseinfluence = 1 - sum(influence), the above is equivalent to sum((target - base) * influence)
      var morphBaseInfluence = geometry.morphTargetsRelative ? 1 : 1 - morphInfluencesSum;

      program.getUniforms().setValue(gl, 'morphTargetBaseInfluence', morphBaseInfluence);
      program.getUniforms().setValue(gl, 'morphTargetInfluences', morphInfluences);
    }
  }
}
