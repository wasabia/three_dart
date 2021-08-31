part of three_helpers;

var _v1 = /*@__PURE__*/ new Vector3.init();
var _v2 = /*@__PURE__*/ new Vector3.init();
var _v3 = /*@__PURE__*/ new Vector3.init();

class DirectionalLightHelper extends Object3D {

  late DirectionalLight light;
  late Line lightPlane;
  late Line targetLine;
  Color? color;

	DirectionalLightHelper( light, size, color ) : super() {

		this.light = light;
		this.light.updateMatrixWorld(false);

		this.matrix = light.matrixWorld;
		this.matrixAutoUpdate = false;

		this.color = color;

		if ( size == null ) size = 1;
		var geometry = new BufferGeometry();

    double _size = size.toDouble();

    List<double> _posData = [
			- _size, _size, 0.0,
			_size, _size, 0.0,
			_size, - _size, 0.0,
			- _size, - _size, 0.0,
			- _size, _size, 0.0
		];

		geometry.setAttribute( 'position', new Float32BufferAttribute(Float32Array.from(_posData), 3, false ) );

		var material = new LineBasicMaterial( { "fog": false, "toneMapped": false } );

		this.lightPlane = new Line( geometry, material );
		this.add( this.lightPlane );

		geometry = new BufferGeometry();
    List<double> _d2 = [ 0, 0, 0, 0, 0, 1 ];
		geometry.setAttribute( 'position', new Float32BufferAttribute( Float32Array.from(_d2), 3, false ) );

		this.targetLine = new Line( geometry, material );
		this.add( this.targetLine );

		this.update();

	}

	dispose() {

		this.lightPlane.geometry!.dispose();
		this.lightPlane.material.dispose();
		this.targetLine.geometry!.dispose();
		this.targetLine.material.dispose();

	}

	update() {

		_v1.setFromMatrixPosition( this.light.matrixWorld );
		_v2.setFromMatrixPosition( this.light.target!.matrixWorld );
		_v3.subVectors( _v2, _v1 );

		this.lightPlane.lookAt( _v2 );

		if ( this.color != null ) {

			this.lightPlane.material.color.set( this.color );
			this.targetLine.material.color.set( this.color );

		} else {

			this.lightPlane.material.color.copy( this.light.color );
			this.targetLine.material.color.copy( this.light.color );

		}

		this.targetLine.lookAt( _v2 );
		this.targetLine.scale.z = _v3.length();

	}

}

