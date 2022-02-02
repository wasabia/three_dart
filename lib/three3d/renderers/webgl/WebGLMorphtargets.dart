part of three_webgl;

int numericalSort(a, b) {
  return a[0] - b[0];
}

int absNumericalSort(a, b) {
  return Math.abs(b[1]) >= Math.abs(a[1]) ? 1 : -1;
}

denormalize(morph, attribute) {
  var denominator = 1;
  var array = attribute.isInterleavedBufferAttribute
      ? attribute.data.array
      : attribute.array;

  if (array is Int8Array)
    denominator = 127;
  else if (array is Int16Array)
    denominator = 32767;
  else if (array is Int32Array)
    denominator = 2147483647;
  else
    console.error(
        'THREE.WebGLMorphtargets: Unsupported morph attribute data type: ',
        array);

  morph.divideScalar(denominator);
}

class WebGLMorphtargets {
  var influencesList = {};
  var morphInfluences = new Float32List(8);
  var morphTextures = new WeakMap();
  var morph = new Vector3();

  List<List<num>> workInfluences = [];

  dynamic gl;
  WebGLCapabilities capabilities;
  WebGLTextures textures;

  WebGLMorphtargets(this.gl, this.capabilities, this.textures) {
    for (var i = 0; i < 8; i++) {
      workInfluences.add([i, 0]);
    }
  }

  update(Object3D object, geometry, material, program) {
    List<num>? objectInfluences = object.morphTargetInfluences;

    if (capabilities.isWebGL2 == true) {
      // instead of using attributes, the WebGL 2 code path encodes morph targets
      // into an array of data textures. Each layer represents a single morph target.

      int numberOfMorphTargets = geometry.morphAttributes["position"].length;

      Map? entry = morphTextures.get(geometry);

      if (entry == undefined || entry!["count"] != numberOfMorphTargets) {
        if (entry != undefined) entry!["texture"].dispose();

        var hasMorphNormals = geometry.morphAttributes["normal"] != undefined;

        var morphTargets = geometry.morphAttributes["position"];
        var morphNormals = geometry.morphAttributes["normal"] ?? [];

        var numberOfVertices = geometry.attributes["position"].count;
        var numberOfVertexData =
            (hasMorphNormals == true) ? 2 : 1; // (v,n) vs. (v)

        var width = numberOfVertices * numberOfVertexData;
        var height = 1;

        if (width > capabilities.maxTextureSize) {
          height = Math.ceil(width / capabilities.maxTextureSize);
          width = capabilities.maxTextureSize;
        }

        var buffer = new Float32List(width * height * 4 * numberOfMorphTargets);

        var texture = new DataTexture2DArray(buffer, width, height, numberOfMorphTargets);
        texture.format = RGBAFormat; // using RGBA since RGB might be emulated (and is thus slower)
        texture.type = FloatType;
        texture.needsUpdate = true;

        // fill buffer

        int vertexDataStride = numberOfVertexData * 4;

        for (var i = 0; i < numberOfMorphTargets; i++) {
          var morphTarget = morphTargets[i];

          var offset = width * height * 4 * i;

          for (var j = 0; j < morphTarget.count; j++) {
            morph.fromBufferAttribute(morphTarget, j);

            if (morphTarget.normalized == true) denormalize(morph, morphTarget);

            var stride = j * vertexDataStride;

            buffer[offset + stride + 0] = morph.x.toDouble();
            buffer[offset + stride + 1] = morph.y.toDouble();
            buffer[offset + stride + 2] = morph.z.toDouble();
            buffer[offset + stride + 3] = 0;

            if (hasMorphNormals == true) {
              var morphNormal = morphNormals[i];

              morph.fromBufferAttribute(morphNormal, j);

              if (morphNormal.normalized == true)
                denormalize(morph, morphNormal);

              buffer[offset + stride + 4] = morph.x.toDouble();
              buffer[offset + stride + 5] = morph.y.toDouble();
              buffer[offset + stride + 6] = morph.z.toDouble();
              buffer[offset + stride + 7] = 0;
            }
          }
        }

        entry = {
          "count": numberOfMorphTargets,
          "texture": texture,
          "size": new Vector2(width, height)
        };

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

      var morphBaseInfluence =
          geometry.morphTargetsRelative ? 1 : 1 - morphInfluencesSum;


      // print("morphTargetBaseInfluence: ${morphBaseInfluence} ");
      // print("morphTargetInfluences: ${objectInfluences} ");
      // print("morphTargetsTexture: ${entry["texture"].image.data} ");
      // print("morphTargetsTextureSize: ${entry["size"].toJSON()} ");


      program
          .getUniforms()
          .setValue(gl, 'morphTargetBaseInfluence', morphBaseInfluence);
      program
          .getUniforms()
          .setValue(gl, 'morphTargetInfluences', objectInfluences);

      program
          .getUniforms()
          .setValue(gl, 'morphTargetsTexture', entry["texture"], textures);
      program
          .getUniforms()
          .setValue(gl, 'morphTargetsTextureSize', entry["size"]);
    } else {
      // When object doesn't have morph target influences defined, we treat it as a 0-length array
      // This is important to make sure we set up morphTargetBaseInfluence / morphTargetInfluences

      var length = objectInfluences == undefined ? 0 : objectInfluences!.length;

      List<List<num>>? influences = influencesList[geometry.id];

      if (influences == undefined || influences!.length != length) {
        // initialise list

        influences = [];

        for (var i = 0; i < length; i++) {
          influences.add( [i, 0.0] );
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
        var index = influence[0];
        var value = influence[1];

        if (index != Math.MAX_SAFE_INTEGER && value != 0) {
          if (morphTargets != null &&
              geometry.getAttribute('morphTarget${i}') != morphTargets[index]) {
            geometry.setAttribute('morphTarget${i}', morphTargets[index]);
          }

          if (morphNormals != null &&
              geometry.getAttribute('morphNormal${i}') != morphNormals[index]) {
            geometry.setAttribute('morphNormal${i}', morphNormals[index]);
          }

          morphInfluences[i] = value.toDouble();
          morphInfluencesSum += value;
        } else {
          if (morphTargets != null &&
              geometry.hasAttribute('morphTarget${i}') == true) {
            geometry.deleteAttribute('morphTarget${i}');
          }

          if (morphNormals != null &&
              geometry.hasAttribute('morphNormal${i}') == true) {
            geometry.deleteAttribute('morphNormal${i}');
          }

          morphInfluences[i] = 0;
        }
      }

      // GLSL shader uses formula baseinfluence * base + sum(target * influence)
      // This allows us to switch between absolute morphs and relative morphs without changing shader code
      // When baseinfluence = 1 - sum(influence), the above is equivalent to sum((target - base) * influence)
      var morphBaseInfluence =
          geometry.morphTargetsRelative ? 1 : 1 - morphInfluencesSum;

      program
          .getUniforms()
          .setValue(gl, 'morphTargetBaseInfluence', morphBaseInfluence);
      program
          .getUniforms()
          .setValue(gl, 'morphTargetInfluences', morphInfluences);
    }
  }
}
