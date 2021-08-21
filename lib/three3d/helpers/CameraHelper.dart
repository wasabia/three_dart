part of three_helpers;

var _vector = /*@__PURE__*/ new Vector3.init();
var _camera = /*@__PURE__*/ new Camera();

/**
 *	- shows frustum, line of sight and up of the camera
 *	- suitable for fast updates
 * 	- based on frustum visualization in lightgl.js shadowmap example
 *		http://evanw.github.com/lightgl.js/tests/shadowmap.html
 */

class CameraHelper extends LineSegments {

  String type = "CameraHelper";
  late Camera camera;
  late Map<String, dynamic> pointMap;

  CameraHelper.create(geometry, material) : super(geometry, material) {

  }

	factory CameraHelper( camera ) {

		var geometry = new BufferGeometry();
		var material = new LineBasicMaterial( { "color": 0xffffff, "vertexColors": true, "toneMapped": false } );

		List<num> vertices = [];
		List<num> colors = [];

		Map<String, dynamic> pointMap = {};

		// colors

		var colorFrustum = Color.fromHex( 0xffaa00 );
		var colorCone = Color.fromHex( 0xff0000 );
		var colorUp = Color.fromHex( 0x00aaff );
		var colorTarget = Color.fromHex( 0xffffff );
		var colorCross = Color.fromHex( 0x333333 );


    Function addPoint = ( id, color ) {

			vertices.addAll( [0, 0, 0] );
			colors.addAll( [color.r, color.g, color.b] );

			if ( pointMap[ id ] == null ) {
				pointMap[ id ] = [];
			}

			pointMap[ id ].add( ( vertices.length / 3.0 ).toInt() - 1 );

		};

    Function addLine = ( a, b, color ) {

			addPoint( a, color );
			addPoint( b, color );

		};

		

		// near

		addLine( 'n1', 'n2', colorFrustum );
		addLine( 'n2', 'n4', colorFrustum );
		addLine( 'n4', 'n3', colorFrustum );
		addLine( 'n3', 'n1', colorFrustum );

		// far

		addLine( 'f1', 'f2', colorFrustum );
		addLine( 'f2', 'f4', colorFrustum );
		addLine( 'f4', 'f3', colorFrustum );
		addLine( 'f3', 'f1', colorFrustum );

		// sides

		addLine( 'n1', 'f1', colorFrustum );
		addLine( 'n2', 'f2', colorFrustum );
		addLine( 'n3', 'f3', colorFrustum );
		addLine( 'n4', 'f4', colorFrustum );

		// cone

		addLine( 'p', 'n1', colorCone );
		addLine( 'p', 'n2', colorCone );
		addLine( 'p', 'n3', colorCone );
		addLine( 'p', 'n4', colorCone );

		// up

		addLine( 'u1', 'u2', colorUp );
		addLine( 'u2', 'u3', colorUp );
		addLine( 'u3', 'u1', colorUp );

		// target

		addLine( 'c', 't', colorTarget );
		addLine( 'p', 'c', colorCross );

		// cross

		addLine( 'cn1', 'cn2', colorCross );
		addLine( 'cn3', 'cn4', colorCross );

		addLine( 'cf1', 'cf2', colorCross );
		addLine( 'cf3', 'cf4', colorCross );

	

		geometry.setAttribute( 'position', new Float32BufferAttribute( vertices, 3, false ) );
		geometry.setAttribute( 'color', new Float32BufferAttribute( colors, 3, false ) );

		CameraHelper cameraHelper = CameraHelper.create( geometry, material );
		cameraHelper.camera = camera;

		if ( cameraHelper.camera.updateProjectionMatrix != null ) {
      cameraHelper.camera.updateProjectionMatrix();
    }

		cameraHelper.matrix = camera.matrixWorld;
		cameraHelper.matrixAutoUpdate = false;

		cameraHelper.pointMap = pointMap;

		cameraHelper.update();

    return cameraHelper;
	}

	update() {

		var geometry = this.geometry;
		var pointMap = this.pointMap;

		var w = 1, h = 1;

		// we need just camera projection matrix inverse
		// world matrix must be identity

		_camera.projectionMatrixInverse.copy( this.camera.projectionMatrixInverse );

		// center / target

		setPoint( 'c', pointMap, geometry, _camera, 0, 0, - 1 );
		setPoint( 't', pointMap, geometry, _camera, 0, 0, 1 );

		// near

		setPoint( 'n1', pointMap, geometry, _camera, - w, - h, - 1 );
		setPoint( 'n2', pointMap, geometry, _camera, w, - h, - 1 );
		setPoint( 'n3', pointMap, geometry, _camera, - w, h, - 1 );
		setPoint( 'n4', pointMap, geometry, _camera, w, h, - 1 );

		// far

		setPoint( 'f1', pointMap, geometry, _camera, - w, - h, 1 );
		setPoint( 'f2', pointMap, geometry, _camera, w, - h, 1 );
		setPoint( 'f3', pointMap, geometry, _camera, - w, h, 1 );
		setPoint( 'f4', pointMap, geometry, _camera, w, h, 1 );

		// up

		setPoint( 'u1', pointMap, geometry, _camera, w * 0.7, h * 1.1, - 1 );
		setPoint( 'u2', pointMap, geometry, _camera, - w * 0.7, h * 1.1, - 1 );
		setPoint( 'u3', pointMap, geometry, _camera, 0, h * 2, - 1 );

		// cross

		setPoint( 'cf1', pointMap, geometry, _camera, - w, 0, 1 );
		setPoint( 'cf2', pointMap, geometry, _camera, w, 0, 1 );
		setPoint( 'cf3', pointMap, geometry, _camera, 0, - h, 1 );
		setPoint( 'cf4', pointMap, geometry, _camera, 0, h, 1 );

		setPoint( 'cn1', pointMap, geometry, _camera, - w, 0, - 1 );
		setPoint( 'cn2', pointMap, geometry, _camera, w, 0, - 1 );
		setPoint( 'cn3', pointMap, geometry, _camera, 0, - h, - 1 );
		setPoint( 'cn4', pointMap, geometry, _camera, 0, h, - 1 );

		geometry.getAttribute( 'position' ).needsUpdate = true;

	}

  dispose() {

		this.geometry.dispose();
		this.material.dispose();

	}

}


setPoint( point, pointMap, geometry, camera, x, y, z ) {

	_vector.set( x, y, z ).unproject( camera );

	var points = pointMap[ point ];

	if ( points != null ) {

		var position = geometry.getAttribute( 'position' );

		for ( var i = 0, l = points.length; i < l; i ++ ) {

			position.setXYZ( points[ i ], _vector.x, _vector.y, _vector.z );

		}

	}

}