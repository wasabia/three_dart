
import 'package:three_dart/three3d/core/object_3d.dart';
import 'package:three_dart/three3d/lights/light.dart';
import 'package:three_dart/three3d/lights/point_light_shadow.dart';
import 'package:three_dart/three3d/math/math.dart';

class PointLight extends Light {
  @override
  String type = "PointLight";

  PointLight(color, [double? intensity, double? distance, double? decay])
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
