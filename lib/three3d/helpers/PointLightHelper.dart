part of three_helpers;

class PointLightHelper extends Mesh {

  String type = "PointLightHelper";
  late PointLight light;
  Color? color;

  PointLightHelper.create(geometry, material) : super(geometry, material) {
  }

	factory PointLightHelper( light, sphereSize, color ) {

		var geometry = SphereGeometry( radius: sphereSize, widthSegments: 4, heightSegments: 2 );
		var material = new MeshBasicMaterial( {
      "wireframe": true,
      "fog": false,
      "toneMapped": false
    } );

		var _plh = PointLightHelper.create( geometry, material );

		_plh.light = light;
		_plh.light.updateMatrixWorld(false);

		_plh.color = color;
		_plh.matrix = _plh.light.matrixWorld;
		_plh.matrixAutoUpdate = false;

		_plh.update();
    return _plh;

		/*
	// TODO: delete this comment?
	const distanceGeometry = new THREE.IcosahedronBufferGeometry( 1, 2 );
	const distanceMaterial = new THREE.MeshBasicMaterial( { color: hexColor, fog: false, wireframe: true, opacity: 0.1, transparent: true } );

	this.lightSphere = new THREE.Mesh( bulbGeometry, bulbMaterial );
	this.lightDistance = new THREE.Mesh( distanceGeometry, distanceMaterial );

	const d = light.distance;

	if ( d === 0.0 ) {

		this.lightDistance.visible = false;

	} else {

		this.lightDistance.scale.set( d, d, d );

	}

	this.add( this.lightDistance );
	*/

	}

	dispose() {

		this.geometry!.dispose();
		this.material.dispose();

	}

	update() {

		if ( this.color != null ) {

			this.material.color.set( this.color );

		} else {

			this.material.color.copy( this.light.color );

		}

		/*
		const d = this.light.distance;

		if ( d === 0.0 ) {

			this.lightDistance.visible = false;

		} else {

			this.lightDistance.visible = true;
			this.lightDistance.scale.set( d, d, d );

		}
		*/

	}

}
