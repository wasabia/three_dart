part of three_helpers;

var _shvector = /*@__PURE__*/ new Vector3.init();
var _boneMatrix = /*@__PURE__*/ new Matrix4();
var _matrixWorldInv = /*@__PURE__*/ new Matrix4();


class SkeletonHelper extends LineSegments {
  String type = 'SkeletonHelper';
  bool isSkeletonHelper = true;
  bool matrixAutoUpdate = false;
  late dynamic root;
  late dynamic bones;

  SkeletonHelper.create(geometry, material) : super(geometry, material) {}

	factory SkeletonHelper( object ) {

		var bones = getBoneList( object );

		var geometry = new BufferGeometry();

		List<num> vertices = [];
		List<num> colors = [];

		var color1 = new Color( 0, 0, 1 );
		var color2 = new Color( 0, 1, 0 );

		for ( var i = 0; i < bones.length; i ++ ) {

			var bone = bones[ i ];

			if ( bone.parent != null && bone.parent.type == "Bone" ) {

				vertices.addAll( [0, 0, 0] );
				vertices.addAll( [0, 0, 0] );
				colors.addAll( [color1.r, color1.g, color1.b] );
				colors.addAll( [color2.r, color2.g, color2.b] );

			}

		}

		geometry.setAttribute( 'position', new Float32BufferAttribute( vertices, 3, false ) );
		geometry.setAttribute( 'color', new Float32BufferAttribute( colors, 3, false ) );

		var material = new LineBasicMaterial( { "vertexColors": true, "depthTest": false, "depthWrite": false, "toneMapped": false, "transparent": true } );

		var keletonHelper = SkeletonHelper.create( geometry, material );


		keletonHelper.root = object;
		keletonHelper.bones = bones;

		keletonHelper.matrix = object.matrixWorld;
		

    return keletonHelper;

	}

	updateMatrixWorld( force ) {

		var bones = this.bones;

		var geometry = this.geometry;
		var position = geometry.getAttribute( 'position' );

		_matrixWorldInv.copy( this.root.matrixWorld ).invert();

		for ( var i = 0, j = 0; i < bones.length; i ++ ) {

			var bone = bones[ i ];

			if ( bone.parent != null && bone.parent.type == "Bone" ) {

				_boneMatrix.multiplyMatrices( _matrixWorldInv, bone.matrixWorld );
				_shvector.setFromMatrixPosition( _boneMatrix );
				position.setXYZ( j, _shvector.x, _shvector.y, _shvector.z );

				_boneMatrix.multiplyMatrices( _matrixWorldInv, bone.parent.matrixWorld );
				_shvector.setFromMatrixPosition( _boneMatrix );
				position.setXYZ( j + 1, _shvector.x, _shvector.y, _shvector.z );

				j += 2;

			}

		}

		geometry.getAttribute( 'position' ).needsUpdate = true;

		super.updateMatrixWorld( force );

	}


  



}


Function getBoneList = ( object ) {

    List<Bone> boneList = [];

    if ( object != null && object.type == "Bone" ) {
      boneList.add( object );
    }

    for ( var i = 0; i < object.children.length; i ++ ) {
      boneList.addAll(getBoneList( object.children[ i ] ));
    }

    return boneList;

};