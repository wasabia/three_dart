import 'package:three_dart/three_dart.dart';
import 'package:three_bas/three_bas.dart' as THREE_BAS;



class Slide {

  late num totalDuration;
  late Mesh mesh;

  Slide(width, height, animationPhase) {
    // create a geometry that will be used by BAS.ModelBufferGeometry
    // its a plane with a bunch of segments
    var _plane = PlaneBufferGeometry(
      width: width, 
      height: height, 
      widthSegments: width * 2,
      heightSegments: height * 2);
    var plane = Geometry().fromBufferGeometry(_plane);

    // var plane = PlaneGeometry(width, height, width * 2, height * 2);
    // duplicate some vertices so that each face becomes a separate triangle.
    // this is the same as the THREE.ExplodeModifier
    THREE_BAS.Utils.separateFaces(plane);

    // create a ModelBufferGeometry based on the geometry created above
    // ModelBufferGeometry makes it easier to create animations based on faces of a geometry
    // it is similar to the PrefabBufferGeometry where the prefab is a face (triangle)
    var geometry = new THREE_BAS.ModelBufferGeometry(plane, {
      // setting this to true will store the vertex positions relative to the face they are in
      // this way it's easier to rotate and scale faces around their own center
      "localizeFaces": true,
      // setting this to true will store a centroid for each face in an array
      "computeCentroids": true
    });

    // buffer UVs so the textures are mapped correctly
    geometry.bufferUvs();

    var j, centroid;

    // ANIMATION

    var aDelayDuration = geometry.createAttribute('aDelayDuration', 2, null);
    // these will be used to calculate the animation delay and duration for each face
    var minDuration = 0.8;
    var maxDuration = 1.2;
    var maxDelayX = 0.9;
    var maxDelayY = 0.125;
    var stretch = 0.11;

    this.totalDuration = maxDuration + maxDelayX + maxDelayY + stretch;


    var i = 0;
    var offset = 0;
    while ( i < geometry.faceCount) {
      centroid = geometry.centroids![i];

      var duration = MathUtils.randFloat(minDuration, maxDuration);
      // delay is based on the position of each face within the original plane geometry
      // because the faces are localized, this position is available in the centroids array
      var delayX = MathUtils.mapLinear(centroid.x, -width * 0.5, width * 0.5, 0.0, maxDelayX);
      var delayY;

      // create a different delayY mapping based on the animation phase (in or out)
      if (animationPhase == 'in') {
        delayY = MathUtils.mapLinear(Math.abs(centroid.y), 0, height * 0.5, 0.0, maxDelayY);
      }
      else {
        delayY = MathUtils.mapLinear(Math.abs(centroid.y), 0, height * 0.5, maxDelayY, 0.0);
      }

      // store the delay and duration FOR EACH VERTEX of the face
      for (j = 0; j < 3; j++) {
        // by giving each VERTEX a different delay value the face will be 'stretched' in time
        aDelayDuration.array[offset]     = delayX + delayY + (Math.random() * stretch * duration);
        aDelayDuration.array[offset + 1] = duration;

        offset += 2;
      }

      i++;
    }

    // POSITIONS

    // the transitions will begin and end on the same position
    var aStartPosition = geometry.createAttribute('aStartPosition', 3, (data, i, faceCount) {
      geometry.centroids![i].toArray(data);
    });
    var aEndPosition = geometry.createAttribute('aEndPosition', 3, (data, i, faceCount) {
      geometry.centroids![i].toArray(data);
    });

    // CONTROL POINTS

    // each face will follow a bezier path
    // since all paths begin and end on the position (the centroid), the control points will determine how the animation looks
    var aControl0 = geometry.createAttribute('aControl0', 3, null);
    var aControl1 = geometry.createAttribute('aControl1', 3, null);

    var control0 = Vector3.init();
    var control1 = Vector3.init();
    List<num> data = List<num>.filled(3, 0);

    i = 0;
    offset = 0;

    while (i < geometry.faceCount) {
      centroid = geometry.centroids![i];

      // the logic to determine the control points is completely arbitrary
      var signY = Math.sign(centroid.y);

      control0.x = MathUtils.randFloat(0.1, 0.3) * 50;
      control0.y = signY * MathUtils.randFloat(0.1, 0.3) * 70;
      control0.z = MathUtils.randFloatSpread(20);

      control1.x = MathUtils.randFloat(0.3, 0.6) * 50;
      control1.y = -signY * MathUtils.randFloat(0.3, 0.6) * 70;
      control1.z = MathUtils.randFloatSpread(20);

      if (animationPhase == 'in') {
        control0.subVectors(centroid, control0);
        control1.subVectors(centroid, control1);
      }
      else { // out
        control0.addVectors(centroid, control0);
        control1.addVectors(centroid, control1);
      }

      // store the control points per face
      // this is similar to THREE.PrefabBufferGeometry.setPrefabData
      geometry.setFaceData(aControl0, i, control0.toArray(data));
      geometry.setFaceData(aControl1, i, control1.toArray(data));

      i++;
    }

    var texture = Texture(null, null, null, null, null, null, null, null, null, null);
    texture.minFilter = NearestFilter;

    var material = new THREE_BAS.BasicAnimationMaterial({
      "flatShading": true,
      "side": DoubleSide,
      "uniforms": {
        "uTime": {"value": 0}
      },
      "map": texture,
      "vertexFunctions": [
        THREE_BAS.ShaderChunk['cubic_bezier'],
        THREE_BAS.ShaderChunk['ease_cubic_in_out'],
        THREE_BAS.ShaderChunk['quaternion_rotation']
      ],
      "vertexParameters": [
        'uniform float uTime;',
        'attribute vec2 aDelayDuration;',
        'attribute vec3 aStartPosition;',
        'attribute vec3 aControl0;',
        'attribute vec3 aControl1;',
        'attribute vec3 aEndPosition;'
      ],
      "vertexInit": [
        'float tProgress = clamp(uTime - aDelayDuration.x, 0.0, aDelayDuration.y) / aDelayDuration.y;'
      ],
      "vertexPosition": [
        // this scales each face
        // for the in animation, we want to go from 0.0 to 1.0
        // for the out animation, we want to go from 1.0 to 0.0
        (animationPhase == 'in' ? 'transformed *= tProgress;' : 'transformed *= 1.0 - tProgress;'),
        // translation based on the bezier curve defined by the attributes
        'transformed += cubicBezier(aStartPosition, aControl0, aControl1, aEndPosition, tProgress);'
      ]
    });



    this.mesh = new Mesh(geometry, material);
    this.mesh.frustumCulled = false;
  }

  setImage(image) {
    this.mesh.material.map.image = image;
    this.mesh.material.map.needsUpdate = true;
  }
  
}
