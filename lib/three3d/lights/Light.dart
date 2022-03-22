part of three_lights;

class Light extends Object3D {
  late num intensity;
  Color? color;
  num? distance;
  LightShadow? shadow;
  SphericalHarmonics3? sh;

  num? angle;
  num? decay;

  Object3D? target;
  num? penumbra;

  num? width;
  num? height;

  bool isRectAreaLight = false;
  bool isHemisphereLightProbe = false;
  bool isHemisphereLight = false;

  Color? groundColor;

  @override
  String type = "Light";

  Light(color, num? intensity) : super() {
    if (color is Color) {
      this.color = color;
    } else if (color is int) {
      this.color = Color.fromHex(color);
    } else {
      throw ("Light init color type is not support $color ");
    }

    this.intensity = intensity ?? 1.0;
  }

  Light.fromJSON(Map<String, dynamic> json, Map<String, dynamic> rootJSON)
      : super.fromJSON(json, rootJSON) {
    if (json["color"] != null) {
      color = Color(0, 0, 0).setHex(json["color"]);
    }
    intensity = json["intensity"] ?? 1;
  }

  @override
  copy(Object3D source, [bool? recursive]) {
    super.copy(source, false);

    Light source1 = source as Light;

    color!.copy(source1.color!);
    intensity = source1.intensity;

    return this;
  }

  @override
  Map<String, dynamic> toJSON({Object3dMeta? meta}) {
    var data = super.toJSON(meta: meta);

    data["object"]["color"] = color!.getHex();
    data["object"]["intensity"] = intensity;

    if (groundColor != null) {
      data["object"]["groundColor"] = groundColor!.getHex();
    }

    if (distance != null) {
      data["object"]["distance"] = distance;
    }
    if (angle != null) {
      data["object"]["angle"] = angle;
    }
    if (decay != null) {
      data["object"]["decay"] = decay;
    }
    if (penumbra != null) {
      data["object"]["penumbra"] = penumbra;
    }

    if (shadow != null) {
      data["object"]["shadow"] = shadow!.toJSON();
    }

    return data;
  }

  @override
  dispose() {
    // Empty here in base class; some subclasses override.
  }

  @override
  getProperty(propertyName) {
    if (propertyName == "color") {
      return color;
    } else if (propertyName == "intensity") {
      return intensity;
    } else {
      return super.getProperty(propertyName);
    }
  }

  @override
  setProperty(String propertyName, value) {
    if (propertyName == "intensity") {
      intensity = value;
    } else {
      super.setProperty(propertyName, value);
    }

    return this;
  }
}
