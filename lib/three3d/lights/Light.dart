part of three_lights;


class Light extends Object3D {

  bool isLight = true;
  late num intensity;
  Color? color;
  double? distance;
  LightShadow? shadow;
  SphericalHarmonics3? sh;
  
  bool isLightProbe = false;
  bool isSpotLight = false;
  bool isPointLight = false;


  double? angle;
  double? decay;

  Object3D? target;
  double? penumbra;

  double? width;
  double? height;

  bool isRectAreaLight = false;
  bool isHemisphereLightProbe = false;
  bool isHemisphereLight = false;

  Color? groundColor;

  String type = "Light";

  Light( Color? color, num? intensity) : super() {
    this.color = color;
    this.intensity = intensity ?? 1;
  }


  Light.fromJSON(Map<String, dynamic> json, Map<String, dynamic> rootJSON) : super.fromJSON(json, rootJSON) {
    if(json["color"] != null) {
      this.color = Color(0,0,0).setHex(json["color"]);
    }
    intensity = json["intensity"] ?? 1;

  }

  copy ( Object3D source, bool recursive ) {

	  super.copy(source, false );

    Light source1 = source as Light;

		this.color!.copy( source1.color );
		this.intensity = source1.intensity;

		return this;

	}

	toJSON ( {Object3dMeta? meta} ) {

		var data = super.toJSON(meta: meta);

		data["object"]["color"] = this.color!.getHex();
		data["object"]["intensity"] = this.intensity;

		if ( this.groundColor != null ) {
      data["object"]["groundColor"] = this.groundColor!.getHex();
    }

		if ( this.distance != null ) {
      data["object"]["distance"] = this.distance;
    }
		if ( this.angle != null ) {
      data["object"]["angle"] = this.angle;
    }
		if ( this.decay != null ) {
      data["object"]["decay"] = this.decay;
    }
		if ( this.penumbra != null ) {
      data["object"]["penumbra"] = this.penumbra;
    }

		if ( this.shadow != null ) {
      data["object"]["shadow"] = this.shadow!.toJSON();
    }

		return data;

	}

}

