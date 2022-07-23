part of three_materials;

class MeshDepthMaterial extends Material {
  MeshDepthMaterial([Map<String, dynamic>? parameters]) : super() {
    type = "MeshDepthMaterial";
    depthPacking = BasicDepthPacking;
    displacementScale = 1.0;
    displacementBias = 0;
    wireframe = false;
    wireframeLinewidth = 1;

    displacementMap = null;

    setValues(parameters);
  }

  @override
  MeshDepthMaterial copy(Material source) {
    super.copy(source);

    depthPacking = source.depthPacking;

    map = source.map;

    alphaMap = source.alphaMap;

    displacementMap = source.displacementMap;
    displacementScale = source.displacementScale;
    displacementBias = source.displacementBias;

    wireframe = source.wireframe;
    wireframeLinewidth = source.wireframeLinewidth;

    return this;
  }

  @override
  MeshDepthMaterial clone() {
    return MeshDepthMaterial().copy(this);
  }
}
