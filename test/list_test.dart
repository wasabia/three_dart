// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
<<<<<<< HEAD

void main() {
  group('list test', () {
    test('list test 0', () {});
  });
}
=======
import 'package:three_dart/three3d/renderers/webgl/index.dart';
import 'package:three_dart/three_dart.dart';

void main() {
  group('list test', () {
    test('list test 0', () {

      int t0 = DateTime.now().millisecondsSinceEpoch;

      final Map<String, dynamic> data = {"i": {"value": 1}};
      var material = MeshBasicMaterial();
      for(int i = 0; i < 3000; i++) {
        
        

        // var parameters = WebGLParameters({
        //   "isWebGL2": true,
        //   "shaderID": null,
        //   "shaderName": material.type + " - " + material.name,
        //   "vertexShader": "",
        //   "fragmentShader": "",
        //   "defines": material.defines,
        //   "customVertexShaderID": null,
        //   "customFragmentShaderID": null,
        //   "isRawShaderMaterial": material is RawShaderMaterial,
        //   "glslVersion": material.glslVersion,
        //   "precision": "",
        //   "instancing": false,
        //   "instancingColor": false,
        //   "supportsVertexTextures": false,
        //   "outputEncoding": LinearEncoding,
        //   "map": material.map != null,
        //   "matcap": material.matcap != null,
        //   "envMap": false,
        //   "envMapMode": 1,
        //   "cubeUVHeight": 1,
        //   "lightMap": material.lightMap != null,
        //   "aoMap": material.aoMap != null,
        //   "emissiveMap": material.emissiveMap != null,
        //   "bumpMap": material.bumpMap != null,
        //   "normalMap": material.normalMap != null,
        //   "objectSpaceNormalMap": material.normalMapType == ObjectSpaceNormalMap,
        //   "tangentSpaceNormalMap": material.normalMapType == TangentSpaceNormalMap,
        //   "decodeVideoTexture": material.map != null &&
        //       (material.map is VideoTexture) &&
        //       (material.map!.encoding == sRGBEncoding),
        //   "clearcoat": false,
        //   "clearcoatMap": false,
        //   "clearcoatRoughnessMap": false,
        //   "clearcoatNormalMap": false,
        //   "displacementMap": material.displacementMap != null,
        //   "roughnessMap": material.roughnessMap != null,
        //   "metalnessMap": material.metalnessMap != null,
        //   "specularMap": material.specularMap != null,
        //   "specularIntensityMap": material.specularIntensityMap != null,
        //   "specularColorMap": material.specularColorMap != null,
        //   "opaque": material.transparent == false && material.blending == NormalBlending,
        //   "alphaMap": material.alphaMap != null,
        //   "alphaTest": false,
        //   "gradientMap": material.gradientMap != null,
        //   "sheen": material.sheen > 0,
        //   "sheenColorMap": material.sheenColorMap != null,
        //   "sheenRoughnessMap": material.sheenRoughnessMap != null,
        //   "transmission": material.transmission > 0,
        //   "transmissionMap": material.transmissionMap != null,
        //   "thicknessMap": material.thicknessMap != null,
        //   "combine": material.combine,
        //   "vertexTangents": false,
        //   "vertexColors": material.vertexColors,
        //   "vertexAlphas": false,
        //   "vertexUvs": material.map != null ||
        //       material.bumpMap != null ||
        //       material.normalMap != null ||
        //       material.specularMap != null ||
        //       material.alphaMap != null ||
        //       material.emissiveMap != null ||
        //       material.roughnessMap != null ||
        //       material.metalnessMap != null ||
        //       material.clearcoatMap != null ||
        //       material.clearcoatRoughnessMap != null ||
        //       material.clearcoatNormalMap != null ||
        //       material.displacementMap != null ||
        //       material.transmissionMap != null ||
        //       material.thicknessMap != null ||
        //       material.specularIntensityMap != null ||
        //       material.specularColorMap != null ||
        //       material.sheenColorMap != null ||
        //       material.sheenRoughnessMap != null,
        //   "uvsVertexOnly": !(material.map != null ||
        //           material.bumpMap != null ||
        //           material.normalMap != null ||
        //           material.specularMap != null ||
        //           material.alphaMap != null ||
        //           material.emissiveMap != null ||
        //           material.roughnessMap != null ||
        //           material.metalnessMap != null ||
        //           material.clearcoatNormalMap != null ||
        //           material.transmission != null ||
        //           material.transmissionMap != null ||
        //           material.thicknessMap != null ||
        //           material.sheen > 0 ||
        //           material.sheenColorMap != null ||
        //           material.sheenRoughnessMap != null) &&
        //       material.displacementMap != null,
        //   "flipNormalScaleY": false,
        //   "fog": false,
        //   "useFog": material.fog,
        //   "fogExp2": false,
        //   "flatShading": material.flatShading,
        //   "sizeAttenuation": material.sizeAttenuation,
        //   "logarithmicDepthBuffer": false,
        //   "skinning": false,
        //   "morphTargets": false,
        //   "morphNormals": false,
        //   "morphColors": false,
        //   "morphTargetsCount": 0,
        //   "morphTextureStride": 0,
        //   "numDirLights": 0,
        //   "numPointLights": 0,
        //   "numSpotLights": 0,
        //   "numRectAreaLights": 0,
        //   "numHemiLights": 0,
        //   "numDirLightShadows": 0,
        //   "numPointLightShadows": 0,
        //   "numSpotLightShadows": 0,
        //   "numClippingPlanes": 0,
        //   "numClipIntersection":0,
        //   "dithering": material.dithering,
        //   "shadowMapEnabled": false,
        //   "shadowMapType": 0,
        //   "toneMapping": NoToneMapping,
        //   "physicallyCorrectLights": false,
        //   "premultipliedAlpha": material.premultipliedAlpha,
        //   "doubleSided": material.side == DoubleSide,
        //   "flipSided": material.side == BackSide,
        //   "useDepthPacking": material.depthPacking != null,
        //   "depthPacking": material.depthPacking ?? 0,
        //   "index0AttributeName": material.index0AttributeName,
        //   "extensionDerivatives": material.extensions != null &&
        //       material.extensions!["derivatives"] != null,
        //   "extensionFragDepth": material.extensions != null &&
        //       material.extensions!["fragDepth"] != null,
        //   "extensionDrawBuffers": material.extensions != null &&
        //       material.extensions!["drawBuffers"] != null,
        //   "extensionShaderTextureLOD": material.extensions != null &&
        //       material.extensions!["shaderTextureLOD"] != null,
        //   "rendererExtensionFragDepth": false,
        //   "rendererExtensionDrawBuffers": false,
        //   "rendererExtensionShaderTextureLod": false,
        //   // "customProgramCacheKey": material.customProgramCacheKey()
        // });
      }

      int t1 = DateTime.now().millisecondsSinceEpoch;

      print(" cost ${t1 - t0} ");

    });
  });
}

class Ddd {

  int data = 0;

}
>>>>>>> 823d557715dd7c957d14aa6d8325d85bdc2ae2ea
