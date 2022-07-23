part of three_materials;

class MeshStandardMaterial extends Material {
  MeshStandardMaterial([Map<String, dynamic>? parameters]) : super() {
    type = "MeshStandardMaterial";
    roughness = 1.0;
    metalness = 0.0;
    bumpScale = 1.0;
    normalScale = Vector2(1, 1);
    envMapIntensity = 1.0;

    defines = {'STANDARD': ''};

    color = Color.fromHex(0xffffff); // diffuse
    roughness = 1.0;
    metalness = 0.0;

    map = null;

    lightMap = null;
    lightMapIntensity = 1.0;

    aoMap = null;
    aoMapIntensity = 1.0;

    emissive = Color.fromHex(0x000000);
    emissiveIntensity = 1.0;
    emissiveMap = null;

    bumpMap = null;
    bumpScale = 1;

    normalMap = null;
    normalMapType = TangentSpaceNormalMap;
    normalScale = Vector2(1, 1);

    displacementMap = null;
    displacementScale = 1;
    displacementBias = 0;

    roughnessMap = null;

    metalnessMap = null;

    alphaMap = null;

    // this.envMap = null;
    envMapIntensity = 1.0;

    wireframe = false;
    wireframeLinewidth = 1;
    wireframeLinecap = 'round';
    wireframeLinejoin = 'round';

    fog = true;

    setValues(parameters);
  }

  @override
  MeshStandardMaterial clone() {
    return MeshStandardMaterial(<String, dynamic>{}).copy(this);
  }

  @override
  MeshStandardMaterial copy(Material source) {
    super.copy(source);

    defines = {'STANDARD': ''};

    color = source.color.clone();
    roughness = source.roughness;
    metalness = source.metalness;

    map = source.map;

    lightMap = source.lightMap;
    lightMapIntensity = source.lightMapIntensity;

    aoMap = source.aoMap;
    aoMapIntensity = source.aoMapIntensity;

    emissive = source.emissive?.clone();
    emissiveMap = source.emissiveMap;
    emissiveIntensity = source.emissiveIntensity;

    bumpMap = source.bumpMap;
    bumpScale = source.bumpScale;

    normalMap = source.normalMap;
    normalMapType = source.normalMapType;
    normalScale = source.normalScale?.clone();

    displacementMap = source.displacementMap;
    displacementScale = source.displacementScale;
    displacementBias = source.displacementBias;

    roughnessMap = source.roughnessMap;

    metalnessMap = source.metalnessMap;

    alphaMap = source.alphaMap;

    envMap = source.envMap;
    envMapIntensity = source.envMapIntensity;

    wireframe = source.wireframe;
    wireframeLinewidth = source.wireframeLinewidth;
    wireframeLinecap = source.wireframeLinecap;
    wireframeLinejoin = source.wireframeLinejoin;

    flatShading = source.flatShading;

    fog = source.fog;

    return this;
  }
}
