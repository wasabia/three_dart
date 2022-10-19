import 'package:three_dart/three3d/constants.dart';
import 'package:three_dart/three3d/materials/material.dart';
import 'package:three_dart/three3d/math/color.dart';

class MeshLambertMaterial extends Material {
  MeshLambertMaterial([parameters]) : super() {
    type = "MeshLambertMaterial";

    color = Color(0, 0, 0).setHex(0xffffff); // diffuse

    map = null;

    lightMap = null;
    lightMapIntensity = 1.0;

    aoMap = null;
    aoMapIntensity = 1.0;

    emissive = Color(0, 0, 0);
    emissiveIntensity = 1.0;
    emissiveMap = null;

    specularMap = null;

    alphaMap = null;

    // this.envMap = null;
    combine = MultiplyOperation;
    reflectivity = 1;
    refractionRatio = 0.98;

    wireframe = false;
    wireframeLinewidth = 1;
    wireframeLinecap = 'round';
    wireframeLinejoin = 'round';

    fog = true;

    setValues(parameters);
  }

  @override
  MeshLambertMaterial copy(Material source) {
    super.copy(source);
    color.copy(source.color);
    map = source.map;
    lightMap = source.lightMap;
    lightMapIntensity = source.lightMapIntensity;
    aoMap = source.aoMap;
    aoMapIntensity = source.aoMapIntensity;
    emissive!.copy(source.emissive!);
    emissiveMap = source.emissiveMap;
    emissiveIntensity = source.emissiveIntensity;
    specularMap = source.specularMap;
    alphaMap = source.alphaMap;
    envMap = source.envMap;
    combine = source.combine;
    reflectivity = source.reflectivity;
    refractionRatio = source.refractionRatio;
    wireframe = source.wireframe;
    wireframeLinewidth = source.wireframeLinewidth;
    wireframeLinecap = source.wireframeLinecap;
    wireframeLinejoin = source.wireframeLinejoin;

    fog = source.fog;

    return this;
  }
}
