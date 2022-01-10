part of three_lights;


class Light extends Object3D {

  bool isLight = true;
  late num intensity;
  Color? color;
  num? distance;
  LightShadow? shadow;
  SphericalHarmonics3? sh;
  
  bool isLightProbe = false;
  bool isSpotLight = false;
  bool isPointLight = false;


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

  String type = "Light";

  Light( color, num? intensity) : super() {
    if(color is Color) {
      this.color = color;
    } else if (color is int) {
      this.color = Color.fromHex(color);
    } else {
      throw("Light init color type is not support ${color} ");
    }
    
    this.intensity = intensity ?? 1.0;
  }


  Light.fromJSON(Map<String, dynamic> json, Map<String, dynamic> rootJSON) : super.fromJSON(json, rootJSON) {
    if(json["color"] != null) {
      this.color = Color(0,0,0).setHex(json["color"]);
    }
    intensity = json["intensity"] ?? 1;

  }

  copy ( Object3D source, [bool? recursive] ) {

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

  dispose() {

		// Empty here in base class; some subclasses override.

	}

  getProperty(propertyName) {
    if(propertyName == "color") {
      return this.color;
    } else if(propertyName == "intensity") {
      return this.intensity;  
    } else {
      return super.getProperty(propertyName);
    }
  }

  setProperty(String propertyName, value) {
    if(propertyName == "intensity") {
      this.intensity = value;
    } else {
      super.setProperty(propertyName, value);
    }

    return this;
  }

}

