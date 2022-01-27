part of three_materials;

/**
 * parameters = {
 *  clearcoat: <float>,
 *  clearcoatMap: new THREE.Texture( <Image> ),
 *  clearcoatRoughness: <float>,
 *  clearcoatRoughnessMap: new THREE.Texture( <Image> ),
 *  clearcoatNormalScale: <Vector2>,
 *  clearcoatNormalMap: new THREE.Texture( <Image> ),
 *
 *  ior: <float>,
 *  reflectivity: <float>,
 *
 *  sheenColor: <Color>,
 *
 *  transmission: <float>,
 *  transmissionMap: new THREE.Texture( <Image> ),
 *
 *  thickness: <float>,
 *  thicknessMap: new THREE.Texture( <Image> ),
 *  attenuationColor: <Color>
 *  attenuationDistance: <float>,
 * 
 *  specularIntensity: <float>,
 *  specularIntensityhMap: new THREE.Texture( <Image> ),
 *  specularColor: <Color>,
 *  specularColorMap: new THREE.Texture( <Image> )
 * }
 */

class MeshPhysicalMaterial extends MeshStandardMaterial {
  bool isMeshPhysicalMaterial = true;

  Texture? clearcoatMap;
  num? clearcoatRoughness = 0.0;
  String type = 'MeshPhysicalMaterial';
  Texture? clearcoatRoughnessMap;
  Vector2? clearcoatNormalScale = Vector2(1, 1);
  Texture? clearcoatNormalMap;

  // null will disable sheenColor bsdf
  Color? sheenColor;

  num? thickness = 0.01;

  Color? attenuationColor = new Color(1, 1, 1);
  num? attenuationDistance = 0.0;

  num? specularIntensity = 1.0;
  Texture? specularIntensityMap = null;
  Color? specularColor = new Color(1, 1, 1);
  Texture? specularColorMap = null;
  num? ior = 1.5;

  MeshPhysicalMaterial([parameters]) : super(parameters) {
    this.defines = {'STANDARD': '', 'PHYSICAL': ''};

    this.setValues(parameters);
  }

  num get reflectivity =>
      (MathUtils.clamp(2.5 * (this.ior! - 1) / (this.ior! + 1), 0, 1));
  set reflectivity(value) {
    this.ior = (1 + 0.4 * value) / (1 - 0.4 * value);
  }

  copy(source) {
    super.copy(source);

    this.defines = {'STANDARD': '', 'PHYSICAL': ''};

    this.clearcoat = source.clearcoat;
    this.clearcoatMap = source.clearcoatMap;
    this.clearcoatRoughness = source.clearcoatRoughness;
    this.clearcoatRoughnessMap = source.clearcoatRoughnessMap;
    this.clearcoatNormalMap = source.clearcoatNormalMap;
    this.clearcoatNormalScale!.copy(source.clearcoatNormalScale);

    this.ior = source.ior;

    if (source.sheenColor != null) {
      this.sheenColor =
          (this.sheenColor ?? new Color(0, 0, 0)).copy(source.sheen);
    } else {
      this.sheenColor = null;
    }

    this.sheenColorMap = source.sheenColorMap;
    this.sheenRoughness = source.sheenRoughness;
    this.sheenRoughnessMap = source.sheenRoughnessMap;

    this.transmission = source.transmission;
    this.transmissionMap = source.transmissionMap;

    this.thickness = source.thickness;
    this.thicknessMap = source.thicknessMap;

    this.attenuationColor!.copy(source.attenuationColor);
    this.attenuationDistance = source.attenuationDistance;

    this.specularIntensity = source.specularIntensity;
    this.specularIntensityMap = source.specularIntensityMap;
    this.specularColor!.copy(source.specularColor);
    this.specularColorMap = source.specularColorMap;

    return this;
  }
}
