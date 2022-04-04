part of three_materials;

class MeshPhysicalMaterial extends MeshStandardMaterial {
  MeshPhysicalMaterial([parameters]) : super(parameters) {
    clearcoatRoughness = 0.0;
    type = 'MeshPhysicalMaterial';
    clearcoatNormalScale = Vector2(1, 1);
    thickness = 0.0;
    attenuationColor = Color(1, 1, 1);
    attenuationDistance = 0.0;
    specularIntensity = 1.0;
    specularColor = Color(1, 1, 1);
    ior = 1.5;

    defines = {'STANDARD': '', 'PHYSICAL': ''};

    setValues(parameters);
  }

  @override
  num get reflectivity {
    return (MathUtils.clamp(2.5 * (ior! - 1) / (ior! + 1), 0, 1));
  }

  @override
  set reflectivity(value) {
    ior = (1 + 0.4 * value) / (1 - 0.4 * value);
  }

  @override
  MeshPhysicalMaterial copy(Material source) {
    super.copy(source);

    defines = {'STANDARD': '', 'PHYSICAL': ''};

    clearcoat = source.clearcoat;
    clearcoatMap = source.clearcoatMap;
    clearcoatRoughness = source.clearcoatRoughness;
    clearcoatRoughnessMap = source.clearcoatRoughnessMap;
    clearcoatNormalMap = source.clearcoatNormalMap;
    clearcoatNormalScale!.copy(source.clearcoatNormalScale!);

    ior = source.ior;

    if (source.sheenColor != null) {
      sheenColor = (sheenColor ?? Color(0, 0, 0)).copy(source.sheenColor!);
    } else {
      sheenColor = null;
    }

    sheenColorMap = source.sheenColorMap;
    sheenRoughness = source.sheenRoughness;
    sheenRoughnessMap = source.sheenRoughnessMap;

    transmission = source.transmission;
    transmissionMap = source.transmissionMap;

    thickness = source.thickness;
    thicknessMap = source.thicknessMap;

    attenuationColor!.copy(source.attenuationColor!);
    attenuationDistance = source.attenuationDistance;

    specularIntensity = source.specularIntensity;
    specularIntensityMap = source.specularIntensityMap;
    specularColor!.copy(source.specularColor!);
    specularColorMap = source.specularColorMap;

    return this;
  }
}
