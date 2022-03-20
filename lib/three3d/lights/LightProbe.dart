part of three_lights;

class LightProbe extends Light {
  LightProbe(sh, intensity) : super(null, intensity) {
    this.type = 'LightProbe';
    this.sh = (sh != null) ? sh : SphericalHarmonics3();
    this.isLightProbe = true;
  }

  copy(Object3D source, [bool? recursive]) {
    super.copy(source);

    LightProbe source1 = source as LightProbe;

    this.sh!.copy(source1.sh);

    return this;
  }

  fromJSON(json) {
    this.intensity = json.intensity; // TODO: Move this bit to Light.fromJSON();
    this.sh!.fromArray(json.sh);

    return this;
  }

  toJSON({Object3dMeta? meta}) {
    var data = super.toJSON(meta: meta);

    data.object.sh = this.sh!.toArray([]);

    return data;
  }
}
