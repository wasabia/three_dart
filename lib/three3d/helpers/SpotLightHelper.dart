part of three_helpers;


var _SpotLightHelpervector = /*@__PURE__*/ new Vector3.init();

class SpotLightHelper extends Object3D {

  late Light light;
	late Matrix4 matrix;

	/**
	 * @default false
	 */
	bool matrixAutoUpdate = false;

	late Color? color;
	late LineSegments cone;


	SpotLightHelper( light, color ) : super() {


		this.light = light;
		this.light.updateMatrixWorld(false);

		this.matrix = light.matrixWorld;

		this.color = color;

		var geometry = new BufferGeometry();

		List<num> positions = [
			0, 0, 0, 	0, 0, 1,
			0, 0, 0, 	1, 0, 1,
			0, 0, 0,	- 1, 0, 1,
			0, 0, 0, 	0, 1, 1,
			0, 0, 0, 	0, - 1, 1
		];

		for ( var i = 0, j = 1, l = 32; i < l; i ++, j ++ ) {

			var p1 = ( i / l ) * Math.PI * 2;
			var p2 = ( j / l ) * Math.PI * 2;

			positions.addAll([
          Math.cos( p1 ), Math.sin( p1 ), 1,
          Math.cos( p2 ), Math.sin( p2 ), 1
        ]
			);

		}

		geometry.setAttribute( 'position', new Float32BufferAttribute( positions, 3, false ) );

		var material = new LineBasicMaterial( { "fog": false, "toneMapped": false } );

		this.cone = new LineSegments( geometry, material );
		this.add( this.cone );

		this.update();

	}

	dispose() {

		this.cone.geometry!.dispose();
		this.cone.material.dispose();

	}

	update() {

		this.light.updateMatrixWorld(false);

		var coneLength = this.light.distance != null ? this.light.distance : 1000;
		var coneWidth = coneLength! * Math.tan( this.light.angle! );

		this.cone.scale.set( coneWidth, coneWidth, coneLength );

		_SpotLightHelpervector.setFromMatrixPosition( this.light.target!.matrixWorld );

		this.cone.lookAt( _SpotLightHelpervector );

		if ( this.color != null ) {

			this.cone.material.color.copy( this.color );

		} else {

			this.cone.material.color.copy( this.light.color );

		}

	}

}