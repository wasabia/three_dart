part of three_helpers;


var _vectorHemisphereLightHelper = /*@__PURE__*/ new Vector3.init();
var _color1 = /*@__PURE__*/ new Color(0, 0, 0);
var _color2 = /*@__PURE__*/ new Color(0, 0, 0);

class HemisphereLightHelper extends Object3D {

  Color? color;
  late Light light;

	HemisphereLightHelper( light, size, color ) : super() {


		this.light = light;
		this.light.updateMatrixWorld(false);

		this.matrix = light.matrixWorld;
		this.matrixAutoUpdate = false;

		this.color = color;

		var geometry = new OctahedronGeometry( size );
		geometry.rotateY( Math.PI * 0.5 );

		this.material = new MeshBasicMaterial( { "wireframe": true, "fog": false, "toneMapped": false } );
		if ( this.color == null ) this.material.vertexColors = true;

		var position = geometry.getAttribute( 'position' );
		var colors = new Float32Array( position.count * 3 );

		geometry.setAttribute( 'color', new Float32BufferAttribute( colors, 3, false ) );

		this.add( new Mesh( geometry, this.material ) );

		this.update();

	}

	dispose() {

		this.children[ 0 ].geometry!.dispose();
		this.children[ 0 ].material.dispose();

	}

	update() {

		var mesh = this.children[ 0 ];

		if ( this.color != null ) {

			this.material.color.copy( this.color );

		} else {

			var colors = mesh.geometry!.getAttribute( 'color' );

			_color1.copy( this.light.color );
			_color2.copy( this.light.groundColor );

			for ( var i = 0, l = colors.count; i < l; i ++ ) {

				var color = ( i < ( l / 2 ) ) ? _color1 : _color2;

				colors.setXYZ( i, color.r, color.g, color.b );

			}

			colors.needsUpdate = true;

		}

		mesh.lookAt( _vectorHemisphereLightHelper.setFromMatrixPosition( this.light.matrixWorld ).negate() );

	}

}
