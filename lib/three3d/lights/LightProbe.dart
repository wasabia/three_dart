part of three_lights;

class LightProbe extends Light {
  LightProbe(sh, intensity) : super(null, intensity) {
    type = 'LightProbe';
    this.sh = (sh != null) ? sh : SphericalHarmonics3();
    isLightProbe = true;
  }

  @override
  copy(Object3D source, [bool? recursive]) {
    super.copy(source);

    LightProbe source1 = source as LightProbe;

    sh!.copy(source1.sh!);

    return this;
  }

  fromJSON(json) {
    intensity = json.intensity; // TODO: Move this bit to Light.fromJSON();
    sh!.fromArray(json.sh);

    return this;
  }

  @override
  Map<String, dynamic> toJSON({Object3dMeta? meta}) {
    var data = super.toJSON(meta: meta);

    data["object"]['sh'] = sh!.toArray([]);

    return data;
  }
}
