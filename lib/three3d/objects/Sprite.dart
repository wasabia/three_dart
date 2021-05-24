
part of three_objects;

var _geometry;

var _intersectPoint = new Vector3.init();
var _worldScale = new Vector3.init();
var _mvPosition = new Vector3.init();

var _alignedPosition = new Vector2(null,null);
var _rotatedPosition = new Vector2(null,null);
var _viewWorldMatrix = new Matrix4();

var _spritevA = new Vector3.init();
var _spritevB = new Vector3.init();
var _spritevC = new Vector3.init();

var _spriteuvA = new Vector2(null,null);
var _spriteuvB = new Vector2(null,null);
var _spriteuvC = new Vector2(null,null);

class Sprite extends Object3D {

  Vector2 center = new Vector2( 0.5, 0.5 );

  bool isSprite = true;

  Sprite( material ) : super() {
    this.type = 'Sprite';

    if ( _geometry == null ) {

      _geometry = new BufferGeometry();

      var float32Array = [
        - 0.5, - 0.5, 0, 0, 0,
        0.5, - 0.5, 0, 1, 0,
        0.5, 0.5, 0, 1, 1,
        - 0.5, 0.5, 0, 0, 1
      ];

      var interleavedBuffer = new InterleavedBuffer( float32Array, 5 );

      _geometry.setIndex( [ 0, 1, 2,	0, 2, 3 ] );
      _geometry.setAttribute( 'position', new InterleavedBufferAttribute( interleavedBuffer, 3, 0, false ) );
      _geometry.setAttribute( 'uv', new InterleavedBufferAttribute( interleavedBuffer, 2, 3, false ) );

    }

    this.geometry = _geometry;
    this.material = ( material != null ) ? material : new SpriteMaterial(null);
  }

	
  Sprite.fromJSON(Map<String, dynamic> json, Map<String, dynamic> rootJSON) : super.fromJSON(json, rootJSON) {
   
  }


	raycast ( raycaster, intersects ) {

		if ( raycaster.camera == null ) {

			print( 'THREE.Sprite: "Raycaster.camera" needs to be set in order to raycast against sprites.' );

		}

		_worldScale.setFromMatrixScale( this.matrixWorld );

		_viewWorldMatrix.copy( raycaster.camera.matrixWorld );
		this.modelViewMatrix.multiplyMatrices( raycaster.camera.matrixWorldInverse, this.matrixWorld );

		_mvPosition.setFromMatrixPosition( this.modelViewMatrix );

		if ( raycaster.camera.type == "PerspectiveCamera" && this.material.sizeAttenuation == false ) {

			_worldScale.multiplyScalar( - _mvPosition.z );

		}

		var rotation = this.material.rotation;
		var sin, cos;

		if ( rotation != 0 ) {

			cos = Math.cos( rotation );
			sin = Math.sin( rotation );

		}

		var center = this.center;

		transformVertex( _spritevA.set( - 0.5, - 0.5, 0 ), _mvPosition, center, _worldScale, sin, cos );
		transformVertex( _spritevB.set( 0.5, - 0.5, 0 ), _mvPosition, center, _worldScale, sin, cos );
		transformVertex( _spritevC.set( 0.5, 0.5, 0 ), _mvPosition, center, _worldScale, sin, cos );

		_spriteuvA.set( 0, 0 );
		_spriteuvB.set( 1, 0 );
		_spriteuvC.set( 1, 1 );

		// check first triangle
		var intersect = raycaster.ray.intersectTriangle( _spritevA, _spritevB, _spritevC, false, _intersectPoint );

		if ( intersect == null ) {

			// check second triangle
			transformVertex( _spritevB.set( - 0.5, 0.5, 0 ), _mvPosition, center, _worldScale, sin, cos );
			_spriteuvB.set( 0, 1 );

			intersect = raycaster.ray.intersectTriangle( _spritevA, _spritevC, _spritevB, false, _intersectPoint );
			if ( intersect == null ) {

				return;

			}

		}

		var distance = raycaster.ray.origin.distanceTo( _intersectPoint );

		if ( distance < raycaster.near || distance > raycaster.far ) return;

		intersects.add( Intersection({

			"distance": distance,
			"point": _intersectPoint.clone(),
			"uv": Triangle.static_getUV( _intersectPoint, _spritevA, _spritevB, _spritevC, _spriteuvA, _spriteuvB, _spriteuvC, new Vector2(null,null) ),
			"face": null,
			"object": this

		}) );

	}

	copy ( Object3D source, bool recursive ) {

	  super.copy( source, recursive );

    Sprite source1 = source as Sprite;

		if ( source1.center != null ) this.center.copy( source1.center );

		this.material = source1.material;

		return this;

	}

}



transformVertex( vertexPosition, mvPosition, center, scale, sin, cos ) {

	// compute position in camera space
	_alignedPosition.subVectors( vertexPosition, center ).addScalar( 0.5 ).multiply( scale );

	// to check if rotation is not zero
	if ( sin != null ) {

		_rotatedPosition.x = ( cos * _alignedPosition.x ) - ( sin * _alignedPosition.y );
		_rotatedPosition.y = ( sin * _alignedPosition.x ) + ( cos * _alignedPosition.y );

	} else {

		_rotatedPosition.copy( _alignedPosition );

	}


	vertexPosition.copy( mvPosition );
	vertexPosition.x += _rotatedPosition.x;
	vertexPosition.y += _rotatedPosition.y;

	// transform to world space
	vertexPosition.applyMatrix4( _viewWorldMatrix );

}
