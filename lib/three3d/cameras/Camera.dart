part of three_camera;


class Camera extends Object3D {

  String type = "Camera";

  bool isCamera = true;
  bool isArrayCamera = false;
  bool isOrthographicCamera = false;
  bool isPerspectiveCamera = false;

  Matrix4 matrixWorldInverse = new Matrix4();

	Matrix4 projectionMatrix = new Matrix4();
	Matrix4 projectionMatrixInverse = new Matrix4();

  late num fov;
  double zoom = 1.0;
  late num near;
  late num far;
  num focus = 10;
  late num aspect;
  num filmGauge = 35; // width of the film (default in millimeters)
  num filmOffset = 0; // horizontal film offset (same unit as gauge)

  //OrthographicCamera
  late num left;
  late num right;
  late num top;
  late num bottom;

  Map<String, dynamic>? view;

  late Vector4 viewport;

  Camera() : super() {}

  Camera.fromJSON(Map<String, dynamic> json, Map<String, dynamic> rootJSON) : super.fromJSON(json, rootJSON) {
    
  }


  updateProjectionMatrix() {
    print(" Camera.updateProjectionMatrix ");
  }

	copy(Object3D source, bool recursive ) {
    super.copy(source, recursive);

    Camera source1 = source as Camera;

		this.matrixWorldInverse.copy( source1.matrixWorldInverse );

		this.projectionMatrix.copy( source1.projectionMatrix );
		this.projectionMatrixInverse.copy( source1.projectionMatrixInverse );

		return this;

	}

	getWorldDirection( Vector3 target ) {

		this.updateWorldMatrix( true, false );

		var e = this.matrixWorld.elements;

		return target.set( - e[ 8 ], - e[ 9 ], - e[ 10 ] ).normalize();

	}

	updateMatrixWorld( bool force ) {
    super.updateMatrixWorld(force);

		this.matrixWorldInverse.copy( this.matrixWorld ).invert();

	}

	updateWorldMatrix ( updateParents, updateChildren ) {

    super.updateWorldMatrix(updateParents, updateChildren);

		this.matrixWorldInverse.copy( this.matrixWorld ).invert();

	}

	clone ([bool recursive = false]) {

		return Camera().copy( this, false );

	}


}