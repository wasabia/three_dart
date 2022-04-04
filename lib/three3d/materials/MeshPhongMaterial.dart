part of three_materials;

class MeshPhongMaterial extends Material {
  MeshPhongMaterial([Map<String, dynamic>? parameters]) : super() {
    bumpScale = 1;
    shininess = 30;
    specular = Color(0.067, 0.067, 0.067);
    color = Color(1, 1, 1); // diffuse

    type = "MeshPhongMaterial";
    emissive = Color(0, 0, 0);
    normalMapType = TangentSpaceNormalMap;
    normalScale = Vector2(1, 1);

    map = null;

    lightMap = null;
    lightMapIntensity = 1.0;

    aoMap = null;
    aoMapIntensity = 1.0;

    emissiveIntensity = 1.0;
    emissiveMap = null;

    normalMap = null;

    displacementMap = null;
    displacementScale = 1;
    displacementBias = 0;

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

    setValues(parameters);
  }

  @override
  MeshPhongMaterial copy(Material source) {
    super.copy(source);

    color.copy(source.color);
    specular!.copy(source.specular!);
    shininess = source.shininess;

    map = source.map;

    lightMap = source.lightMap;
    lightMapIntensity = source.lightMapIntensity;

    aoMap = source.aoMap;
    aoMapIntensity = source.aoMapIntensity;

    emissive!.copy(source.emissive!);
    emissiveMap = source.emissiveMap;
    emissiveIntensity = source.emissiveIntensity;

    bumpMap = source.bumpMap;
    bumpScale = source.bumpScale;

    normalMap = source.normalMap;
    normalMapType = source.normalMapType;
    normalScale!.copy(source.normalScale!);

    displacementMap = source.displacementMap;
    displacementScale = source.displacementScale;
    displacementBias = source.displacementBias;

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
    flatShading = source.flatShading;

    return this;
  }
}
