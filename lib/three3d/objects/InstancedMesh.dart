part of three_objects;



var _instanceLocalMatrix = new Matrix4();
var _instanceWorldMatrix = new Matrix4();

List<Intersection> _instanceIntersects = [];

var _mesh = Mesh(BufferGeometry(), Material());

class InstancedMesh extends Mesh {

  late BufferAttribute instanceMatrix;
  late BufferAttribute? instanceColor;
 

  bool isInstancedMesh = true;

  InstancedMesh( geometry, material, count ) : super(geometry, material) {
    var dl = Float32Array( count * 16 );
    this.instanceMatrix = new BufferAttribute( dl, 16, false );
    this.instanceColor = null;

    this.count = count;

    this.frustumCulled = false;
  }


  copy ( Object3D source, recursive ) {

		super.copy(source, recursive);

    InstancedMesh source1 = source as InstancedMesh;


		this.instanceMatrix.copy( source1.instanceMatrix );

    if ( source.instanceColor != null ) this.instanceColor = source.instanceColor!.clone();

		this.count = source1.count;

		return this;

	}

	getColorAt ( index, color ) {

		color.fromArray( this.instanceColor!.array, index * 3 );

	}

	getMatrixAt ( index, matrix ) {

		matrix.fromArray( this.instanceMatrix.array, index * 16 );

	}

	raycast ( raycaster, intersects ) {

		var matrixWorld = this.matrixWorld;
		var raycastTimes = this.count;

		_mesh.geometry = this.geometry;
		_mesh.material = this.material;

		if ( _mesh.material == null ) return;

		for ( var instanceId = 0; instanceId < raycastTimes!; instanceId ++ ) {

			// calculate the world matrix for each instance

			this.getMatrixAt( instanceId, _instanceLocalMatrix );

			_instanceWorldMatrix.multiplyMatrices( matrixWorld, _instanceLocalMatrix );

			// the mesh represents this single instance

			_mesh.matrixWorld = _instanceWorldMatrix;

			_mesh.raycast( raycaster, _instanceIntersects );

			// process the result of raycast

			for ( var i = 0, l = _instanceIntersects.length; i < l; i ++ ) {

				var intersect = _instanceIntersects[ i ];
				intersect.instanceId = instanceId;
				intersect.object = this;
				intersects.add( intersect );

			}

			_instanceIntersects.length = 0;

		}

	}

	setColorAt ( index, color ) {

		if ( this.instanceColor == null ) {

			this.instanceColor = new BufferAttribute( Float32Array( (this.instanceMatrix.count * 3).toInt() ), 3, false );

		}

		color.toArray( this.instanceColor!.array, index * 3 );

	}

	setMatrixAt ( index, matrix ) {

		matrix.toArray( this.instanceMatrix.array, index * 16 );

	}

	updateMorphTargets () {

	}

	dispose () {

		this.dispatchEvent( Event({"type": "dispose"}) );

	}

}
