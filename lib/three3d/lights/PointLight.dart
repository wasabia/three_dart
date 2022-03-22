part of three_lights;

class PointLight extends Light {
  @override
  String type = "PointLight";

  PointLight(color, [num? intensity, num? distance, num? decay])
      : super(color, intensity) {
    // remove default 0  for js 0 is false  but for dart 0 is not.
    // PointLightShadow.updateMatrices  far value
    this.distance = distance;
    this.decay = decay ?? 1; // for physically correct lights, should be 2.

    shadow = PointLightShadow();
  }

  PointLight.fromJSON(Map<String, dynamic> json, Map<String, dynamic> rootJSON)
      : super.fromJSON(json, rootJSON) {
    distance = json["distance"];
    decay = json["decay"] ?? 1;
    shadow = PointLightShadow.fromJSON(json["shadow"], rootJSON);
  }

  get power {
    return intensity * 4 * Math.PI;
  }

  set power(value) {
    intensity = value / (4 * Math.PI);
  }

  @override
  copy(Object3D source, [bool? recursive]) {
    super.copy.call(source);

    PointLight source1 = source as PointLight;

    distance = source1.distance;
    decay = source1.decay;

    shadow = source1.shadow!.clone();

    return this;
  }

  @override
  dispose() {
    shadow?.dispose();
  }
}
