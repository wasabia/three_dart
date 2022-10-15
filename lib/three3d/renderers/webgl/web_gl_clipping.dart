
import 'package:three_dart/three3d/cameras/camera.dart';
import 'package:three_dart/three3d/materials/material.dart';
import 'package:three_dart/three3d/math/index.dart';
import 'package:three_dart/three3d/renderers/webgl/web_gl_properties.dart';

class WebGLClipping {
  WebGLProperties properties;

  Matrix3 viewNormalMatrix = Matrix3();
  Plane plane = Plane(null, null);
  num numGlobalPlanes = 0;

  bool localClippingEnabled = false;
  bool renderingShadows = false;

  var globalState;

  Map<String, dynamic> uniform = {"value": null, "needsUpdate": false};

  num numPlanes = 0;
  num numIntersection = 0;

  WebGLClipping(this.properties);

  init(List<Plane> planes, bool enableLocalClipping, Camera camera) {
    var enabled = planes.isNotEmpty ||
        enableLocalClipping ||
        // enable state of previous frame - the clipping code has to
        // run another frame in order to reset the state:
        numGlobalPlanes != 0 ||
        localClippingEnabled;

    localClippingEnabled = enableLocalClipping;

    globalState = projectPlanes(planes, camera, 0, null);
    numGlobalPlanes = planes.length;

    return enabled;
  }

  beginShadows() {
    renderingShadows = true;
    projectPlanes(null, null, null, null);
  }

  endShadows() {
    renderingShadows = false;
    resetGlobalState();
  }

  setState(Material material, Camera camera, bool useCache) {
    var planes = material.clippingPlanes;
    var clipIntersection = material.clipIntersection;
    var clipShadows = material.clipShadows;

    var materialProperties = properties.get(material);

    if (!localClippingEnabled ||
        planes == null ||
        planes.isEmpty ||
        renderingShadows && !clipShadows) {
      // there's no local clipping

      if (renderingShadows) {
        // there's no global clipping

        projectPlanes(null, null, null, null);
      } else {
        resetGlobalState();
      }
    } else {
      var nGlobal = renderingShadows ? 0 : numGlobalPlanes;
      var lGlobal = nGlobal * 4;

      var dstArray = materialProperties["clippingState"];

      uniform["value"] = dstArray; // ensure unique state

      dstArray = projectPlanes(planes, camera, lGlobal, useCache);

      for (var i = 0; i != lGlobal; ++i) {
        dstArray[i] = globalState[i];
      }

      materialProperties["clippingState"] = dstArray;
      numIntersection = clipIntersection ? numPlanes : 0;
      numPlanes += nGlobal;
    }
  }

  resetGlobalState() {
    if (uniform["value"] != globalState) {
      uniform["value"] = globalState;
      uniform["needsUpdate"] = numGlobalPlanes > 0;
    }

    numPlanes = numGlobalPlanes;
    numIntersection = 0;
  }

  projectPlanes(planes, camera, dstOffset, skipTransform) {
    var nPlanes = planes != null ? planes.length : 0;
    var dstArray;

    if (nPlanes != 0) {
      dstArray = uniform["value"];

      if (skipTransform != true || dstArray == null) {
        var flatSize = dstOffset + nPlanes * 4,
            viewMatrix = camera.matrixWorldInverse;

        viewNormalMatrix.getNormalMatrix(viewMatrix);

        if (dstArray == null || dstArray.length < flatSize) {
          dstArray = List<num>.filled(flatSize, 0.0);
        }

        for (var i = 0, i4 = dstOffset; i != nPlanes; ++i, i4 += 4) {
          plane.copy(planes[i]).applyMatrix4(viewMatrix, viewNormalMatrix);

          plane.normal.toArray(dstArray, i4);
          dstArray[i4 + 3] = plane.constant;
        }
      }

      uniform["value"] = dstArray;
      uniform["needsUpdate"] = true;
    }

    numPlanes = nPlanes;
    numIntersection = 0;

    return dstArray;
  }
}
