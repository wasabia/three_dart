part of three_lights;

class DirectionalLight extends Light {

  String type = "DirectionalLight";
  bool isDirectionalLight = true;

  DirectionalLight( color, intensity ) : super(color, intensity) {

    this.position.copy( Object3D.DefaultUp );
    this.updateMatrix();

    this.target = Object3D();

    this.shadow = DirectionalLightShadow();
  }


  copy ( Object3D source, bool recursive ) {

		super.copy(source, false );

    DirectionalLight source1 = source as DirectionalLight;

		this.target = source1.target!.clone(false);

		this.shadow = source1.shadow!.clone();

		return this;

	}

  dispose() {

		this.shadow!.dispose();

	}


}


