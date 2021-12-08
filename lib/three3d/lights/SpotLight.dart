part of three_lights;

class SpotLight extends Light {

  String type = "SpotLight";
  bool isSpotLight = true;

  SpotLight( color, [intensity, distance, angle, penumbra, decay] ) : super(color, intensity) {
    this.position.copy( Object3D.DefaultUp );
    this.updateMatrix();

    this.target = new Object3D();


    this.distance = distance ?? 0;
    this.angle = angle ?? Math.PI / 3;
    this.penumbra = penumbra ?? 0;
    this.decay = decay ?? 1;	// for physically correct lights, should be 2.

    this.shadow = new SpotLightShadow();
  }


  get power {
    return this.intensity * Math.PI;
  }

  set power(value) {
    this.intensity = value / Math.PI;
  }

  copy ( Object3D source, bool recursive ) {

	  super.copy(source, false );

    SpotLight source1 = source as SpotLight;

		this.distance = source1.distance;
		this.angle = source1.angle;
		this.penumbra = source1.penumbra;
		this.decay = source1.decay;

		this.target = source1.target!.clone(false);

		this.shadow = source1.shadow!.clone();

		return this;

	}

  dispose() {

		this.shadow!.dispose();

	}

}
