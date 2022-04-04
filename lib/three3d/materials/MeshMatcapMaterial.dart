part of three_materials;

class MeshMatcapMaterial extends Material {
  MeshMatcapMaterial([Map<String, dynamic>? parameters]) : super() {
    defines = {'MATCAP': ''};

    type = 'MeshMatcapMaterial';

    color = Color.fromHex(0xffffff); // diffuse

    matcap = null;

    map = null;

    bumpMap = null;
    bumpScale = 1;

    normalMap = null;
    normalMapType = TangentSpaceNormalMap;
    normalScale = Vector2(1, 1);

    displacementMap = null;
    displacementScale = 1;
    displacementBias = 0;

    alphaMap = null;

    flatShading = false;

    setValues(parameters);
  }

  @override
  MeshMatcapMaterial copy(Material source) {
    super.copy(source);

    defines = {'MATCAP': ''};

    color.copy(source.color);

    matcap = source.matcap;

    map = source.map;

    bumpMap = source.bumpMap;
    bumpScale = source.bumpScale;

    normalMap = source.normalMap;
    normalMapType = source.normalMapType;
    normalScale!.copy(source.normalScale!);

    displacementMap = source.displacementMap;
    displacementScale = source.displacementScale;
    displacementBias = source.displacementBias;

    alphaMap = source.alphaMap;

    flatShading = source.flatShading;

    return this;
  }
}
