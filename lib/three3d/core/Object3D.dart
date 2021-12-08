part of three_core;

int _object3DId = 0;

Vector3 _v1 = new Vector3.init();
Quaternion _q1 = new Quaternion();
Matrix4 _m1 = new Matrix4();
Vector3 _target = new Vector3.init();

Vector3 _position = new Vector3.init();
Vector3 _scale = new Vector3.init();
Quaternion _quaternion = new Quaternion();

Vector3 _xAxis = new Vector3( 1, 0, 0 );
Vector3 _yAxis = new Vector3( 0, 1, 0 );
Vector3 _zAxis = new Vector3( 0, 0, 1 );

Event _addedEvent = Event({"type": "added"});
Event _removedEvent = Event({"type": "removed"});

class Object3D with EventDispatcher {

  static Vector3 DefaultUp = Vector3( 0.0, 1.0, 0.0 );
  static bool DefaultMatrixAutoUpdate = true;

  int id = _object3DId ++;

	String uuid = MathUtils.generateUUID();

  String? tag;
  
	String name = '';
	String type = 'Object3D';

	Object3D? parent;
	List<Object3D> children = [];

  bool castShadow = false;

  bool isMesh = false;
  bool isLine = false;
  bool isPoints = false;
  bool isSkinnedMesh = false;
  bool isBone = false;
  bool isInstancedMesh = false;
  bool isCamera = false;
  bool isLight = false;
  bool isLineSegments = false;
  bool isLineLoop = false;
  bool isScene = false;

  bool autoUpdate = false; // checked by the renderer


	Matrix4 matrix = Matrix4();
  Matrix4 matrixWorld = Matrix4();

	bool matrixAutoUpdate = Object3D.DefaultMatrixAutoUpdate;
	bool matrixWorldNeedsUpdate = false;

	Layers layers = Layers();
	bool visible = true;
	bool receiveShadow = false;

	bool frustumCulled = true;
	num renderOrder = 0;

	// List<AnimationClip> animations = [];

  bool isImmediateRenderObject = false;

	Map<String, dynamic> userData = {};

  Map<String, dynamic> extra = {};

	bool isObject3D = true;
  BufferGeometry? geometry;

	Vector3 up = Object3D.DefaultUp.clone();

  Vector3 position = Vector3.init();
  Euler rotation = Euler.init();
  Quaternion quaternion = Quaternion();
  Vector3 scale = Vector3( 1, 1, 1 );
  Matrix4 modelViewMatrix = Matrix4();
  Matrix3 normalMatrix = Matrix3();

  dynamic? material;

  List<num>? morphTargetInfluences;
  Map<String, dynamic>? morphTargetDictionary;

  // InstancedMesh
  int? count;

  Matrix4? bindMatrix;
  Skeleton? skeleton;

  Material? overrideMaterial;
  Material? customDistanceMaterial;

  /**
	 * Custom depth material to be used when rendering to the depth map. Can only be used in context of meshes.
	 * When shadow-casting with a DirectionalLight or SpotLight, if you are (a) modifying vertex positions in
	 * the vertex shader, (b) using a displacement map, (c) using an alpha map with alphaTest, or (d) using a
	 * transparent texture with alphaTest, you must specify a customDepthMaterial for proper shadows.
	 */
	Material? customDepthMaterial;

  // onBeforeRender({WebGLRenderer? renderer, scene, Camera? camera, RenderTarget? renderTarget, dynamic? geometry, Material? material, dynamic group}) {
    // print(" Object3D.onBeforeRender ${type} ${id} ");
  // }
  Function? onBeforeRender;


  dynamic? background;
  Texture? environment;


  Object3D() {
    init();
  }

  Object3D.fromJSON(Map<String, dynamic> json, Map<String, dynamic> rootJSON) {
    uuid = json["uuid"];
    if(json["name"] != null) {
      name = json["name"]!;
    }
    type = json["type"];
    layers.mask = json["layers"];

    this.position = Vector3.fromJSON(json["position"]);
    this.quaternion = Quaternion.fromJSON(json["quaternion"]);
    this.scale = Vector3.fromJSON(json["scale"]);

    if(json["geometry"] != null) {

      List<BufferGeometry> geometries = rootJSON["geometries"];

      if(geometries != null) {
        BufferGeometry _geometry = geometries.firstWhere((element) => element.uuid == json["geometry"]);
        this.geometry = _geometry;
      }
    
    }

    if(json["material"] != null) {
      List<Material> materials = rootJSON["materials"];

      if(materials != null) {
        Material _material = materials.firstWhere((element) => element.uuid == json["material"]);
        this.material = _material;
      }

    }

    init();

    if(json["children"] != null) {
      List<Map<String, dynamic>> _children = json["children"];
      _children.forEach((_child) {
        this.children.add(Object3D.castJSON(_child, rootJSON));
      });
    }

  }

  init() {
    // TODO
    rotation.onChange(onRotationChange);
	  quaternion.onChange(onQuaternionChange);

  }


  static castJSON(Map<String, dynamic> json, Map<String, dynamic> rootJSON) {
    String _type = json["type"];

    if(_type == null) {
      Map<String, dynamic> _object = json["object"];
      if(_object != null) {
        _type = _object["type"];
        json = _object;
        print(" object is not null use object as json type: ${_type} ");
      }
    }


    if(_type == "Camera") {
      return Camera.fromJSON(json, rootJSON);
    } else if(_type == "PerspectiveCamera") {
      return PerspectiveCamera.fromJSON(json, rootJSON);
    } else if(_type == "Scene") {
      return Scene.fromJSON(json, rootJSON);
    } else if(_type == "PointLight") {
      return PointLight.fromJSON(json, rootJSON);
    } else if(_type == "Group") {
      return Group.fromJSON(json, rootJSON);
    } else if(_type == "Mesh") {
      return Mesh.fromJSON(json, rootJSON);
    } else if(_type == "Line") {
      return Line.fromJSON(json, rootJSON);
    } else if(_type == "Points") {
      return Points.fromJSON(json, rootJSON);
    } else if(_type == "AmbientLight") {
      return AmbientLight.fromJSON(json, rootJSON);
    } else if(_type == "Sprite") {
      return Sprite.fromJSON(json, rootJSON);
    } else if(_type == "SpriteMaterial") {
      return SpriteMaterial.fromJSON(json, rootJSON);
    } else if(_type == "ShapeGeometry") {
      return ShapeGeometry.fromJSON(json, rootJSON);
    } else {
      throw " type: ${_type} Object3D.castJSON is not support yet... ";
    }
  }



	onRotationChange() {
		quaternion.setFromEuler( rotation, false );
	}

	onQuaternionChange() {

		rotation.setFromQuaternion( quaternion, null, false );

	}


	applyMatrix4( matrix ) {

		if ( this.matrixAutoUpdate ) this.updateMatrix();

		this.matrix.premultiply( matrix );

		this.matrix.decompose( this.position, this.quaternion, this.scale );

	}

	applyQuaternion( q ) {

		this.quaternion.premultiply( q );

		return this;

	}

	setRotationFromAxisAngle ( axis, angle ) {

		// assumes axis is normalized

		this.quaternion.setFromAxisAngle( axis, angle );

	}

	setRotationFromEuler( euler ) {

		this.quaternion.setFromEuler( euler, true );

	}

	setRotationFromMatrix ( m ) {

		// assumes the upper 3x3 of m is a pure rotation matrix (i.e, unscaled)

		this.quaternion.setFromRotationMatrix( m );

	}

	setRotationFromQuaternion ( q ) {

		// assumes q is normalized

		this.quaternion.copy( q );

	}

	rotateOnAxis ( axis, angle ) {

		// rotate object on axis in object space
		// axis is assumed to be normalized

		_q1.setFromAxisAngle( axis, angle );

		this.quaternion.multiply( _q1 );

		return this;

	}

	rotateOnWorldAxis ( axis, angle ) {

		// rotate object on axis in world space
		// axis is assumed to be normalized
		// method assumes no rotated parent

		_q1.setFromAxisAngle( axis, angle );

		this.quaternion.premultiply( _q1 );

		return this;

	}

	rotateX ( angle ) {

		return this.rotateOnAxis( _xAxis, angle );

	}

	rotateY ( angle ) {

		return this.rotateOnAxis( _yAxis, angle );

	}

	rotateZ ( angle ) {

		return this.rotateOnAxis( _zAxis, angle );

	}

	translateOnAxis ( axis, distance ) {

		// translate object by distance along axis in object space
		// axis is assumed to be normalized

		_v1.copy( axis ).applyQuaternion( this.quaternion );

		this.position.add( _v1.multiplyScalar( distance ) );

		return this;

	}

	translateX ( distance ) {

		return this.translateOnAxis( _xAxis, distance );

	}

	translateY ( distance ) {

		return this.translateOnAxis( _yAxis, distance );

	}

	translateZ ( distance ) {

		return this.translateOnAxis( _zAxis, distance );

	}

	localToWorld ( vector ) {

		return vector.applyMatrix4( this.matrixWorld );

	}

	worldToLocal ( vector ) {

		return vector.applyMatrix4( _m1.copy( this.matrixWorld ).invert() );

	}

	lookAt ( Vector3 position ) {

		// This method does not support objects having non-uniformly-scaled parent(s)

		_target.copy(position);

		var parent = this.parent;

		this.updateWorldMatrix( true, false );

		_position.setFromMatrixPosition( this.matrixWorld );

    
    // TODO
		if ( this.isCamera || this.isLight ) {

			_m1.lookAt( _position, _target, this.up );

		} else {

			_m1.lookAt( _target, _position, this.up );

		}

 

		this.quaternion.setFromRotationMatrix( _m1 );

		if ( parent != null ) {

			_m1.extractRotation( parent.matrixWorld );
			_q1.setFromRotationMatrix( _m1 );
			this.quaternion.premultiply( _q1.invert() );

		}

	}

  addAll(List<Object3D> objects) {
    for ( var i = 0; i < objects.length; i ++ ) {

      this.add( objects[ i ] );

    }

    return this;
  }

	add ( Object3D object ) {

		if ( object == this ) {

			print( 'THREE.Object3D.add: object can\'t be added as a child of itself. ${object}' );
			return this;

		}

		if ( object != null && object.isObject3D ) {

			if ( object.parent != null ) {

				object.parent!.remove( object );

			}

			object.parent = this;
			this.children.add( object );

			object.dispatchEvent( _addedEvent );

		} else {

			print( 'THREE.Object3D.add: object not an instance of THREE.Object3D. ${object}' );

		}

		return this;

	}

  removeList ( List<Object3D> objects ) {
    	for ( var i = 0; i < objects.length; i ++ ) {

				this.remove( objects[ i ] );

			}

			return this;
  }

	remove ( Object3D object ) {

		var index = this.children.indexOf( object );

		if ( index != - 1 ) {

			object.parent = null;
			this.children.removeAt(index);

			object.dispatchEvent( _removedEvent );

		}

		return this;

	}

  removeFromParent() {

		var parent = this.parent;

		if ( parent != null ) {

			parent.remove( this );

		}

		return this;

	}

	clear () {

		for ( var i = 0; i < this.children.length; i ++ ) {

			var object = this.children[ i ];

			object.parent = null;

			object.dispatchEvent( _removedEvent );

		}

		this.children.length = 0;

		return this;


	}

	attach ( Object3D object ) {

		// adds object as a child of this, while maintaining the object's world transform

		this.updateWorldMatrix( true, false );

		_m1.copy( this.matrixWorld ).invert();

		if ( object.parent != null ) {

			object.parent!.updateWorldMatrix( true, false );

			_m1.multiply( object.parent!.matrixWorld );

		}

		object.applyMatrix4( _m1 );

		this.add( object );
    object.updateWorldMatrix( false, false );

		return this;

	}

	getObjectById ( id ) {
		return this.getObjectByProperty( 'id', id );
	}

	getObjectByName ( name ) {
		return this.getObjectByProperty( 'name', name );
	}

  // TODO
	getObjectByProperty (String name, String value ) {

		if ( this.getProperty(name) == value ) return this;

		for ( var i = 0, l = this.children.length; i < l; i ++ ) {

			var child = this.children[ i ];
			var object = child.getObjectByProperty( name, value );

			if ( object != null ) {

				return object;

			}

		}

		return null;

	}

	getWorldPosition ( Vector3 target ) {

		if ( target == null ) {

			print( 'THREE.Object3D: .getWorldPosition() target is now required' );
			target = new Vector3.init();

		}

		this.updateWorldMatrix( true, false );

		return target.setFromMatrixPosition( this.matrixWorld );

	}

	getWorldQuaternion ( Quaternion target ) {

		this.updateWorldMatrix( true, false );

		this.matrixWorld.decompose( _position, target, _scale );

		return target;

	}

	getWorldScale (Vector3 target ) {

		this.updateWorldMatrix( true, false );

		this.matrixWorld.decompose( _position, _quaternion, target );

		return target;

	}

	getWorldDirection ( Vector3 target ) {

		this.updateWorldMatrix( true, false );

		var e = this.matrixWorld.elements;

		return target.set( e[ 8 ], e[ 9 ], e[ 10 ] ).normalize();

	}

  raycast( Raycaster raycaster, List<Intersection> intersects ) {
    print("Object3D raycast todo ");
  }
  
	traverse ( callback ) {

		callback( this );

		var children = this.children;

		for ( var i = 0, l = children.length; i < l; i ++ ) {

			children[ i ].traverse( callback );

		}

	}

	traverseVisible ( callback ) {

		if ( this.visible == false ) return;

		callback( this );

		var children = this.children;

		for ( var i = 0, l = children.length; i < l; i ++ ) {

			children[ i ].traverseVisible( callback );

		}

	}

	traverseAncestors ( callback ) {

		var parent = this.parent;

		if ( parent != null ) {

			callback( parent );

			parent.traverseAncestors( callback );

		}

	}

	updateMatrix() {
		this.matrix.compose( this.position, this.quaternion, this.scale );
		this.matrixWorldNeedsUpdate = true;
	}

	updateMatrixWorld( bool force ) {

		if ( this.matrixAutoUpdate ) this.updateMatrix();

		if ( this.matrixWorldNeedsUpdate || force ) {

			if ( this.parent == null ) {

				this.matrixWorld.copy( this.matrix );

			} else {

				this.matrixWorld.multiplyMatrices( this.parent!.matrixWorld, this.matrix );

			}

			this.matrixWorldNeedsUpdate = false;

			force = true;

		}

		// update children

		List<Object3D> children = this.children;

		for ( var i = 0, l = children.length; i < l; i ++ ) {

			children[ i ].updateMatrixWorld( force );

		}

	}

	updateWorldMatrix(bool updateParents, bool updateChildren ) {

		var parent = this.parent;

		if ( updateParents == true && parent != null ) {

			parent.updateWorldMatrix( true, false );

		}

		if ( this.matrixAutoUpdate ) this.updateMatrix();

		if ( this.parent == null ) {

			this.matrixWorld.copy( this.matrix );

		} else {

			this.matrixWorld.multiplyMatrices( this.parent!.matrixWorld, this.matrix );

		}

		// update children

		if ( updateChildren == true ) {

			var children = this.children;

			for ( var i = 0, l = children.length; i < l; i ++ ) {

				children[ i ].updateWorldMatrix( false, true );

			}

		}

	}

	toJSON( {Object3dMeta? meta} ) {
		// meta is a string when called from JSON.stringify
		var isRootObject = ( meta == null || meta is String );

		Map<String, dynamic> output = Map<String, dynamic>();

		// meta is a hash used to collect geometries, materials.
		// not providing it implies that this is the root object
		// being serialized.
		if ( isRootObject ) {

			// initialize meta obj
			meta = Object3dMeta();

			output["metadata"] = {
				"version": 4.5,
				"type": 'Object',
				"generator": 'Object3D.toJSON'
			};

		}

		// standard Object3D serialization

		Map<String, dynamic> object = Map<String, dynamic>();

		object["uuid"] = uuid;
		object["type"] = type;

		if ( name != "" ) object["name"] = name;
		if ( castShadow == true ) object["castShadow"] = true;
		if ( receiveShadow == true ) object["receiveShadow"] = true;
		if ( visible == false ) object["visible"] = false;
		if ( this.frustumCulled == false ) object["frustumCulled"] = false;
		if ( this.renderOrder != 0 ) object["renderOrder"] = this.renderOrder;
		if ( this.userData.keys.length > 0 ) object["userData"] = this.userData;

		object["layers"] = layers.mask;
		object["matrix"] = this.matrix.toArray(List<num>.filled(16, 0.0));

		if ( this.matrixAutoUpdate == false ) object["matrixAutoUpdate"] = false;

		// object specific properties

		if ( this.type == "InstancedMesh" ) {
      InstancedMesh _instanceMesh = this as InstancedMesh;

			object["type"] = 'InstancedMesh';
			object["count"] = _instanceMesh.count;
			object["instanceMatrix"] = _instanceMesh.instanceMatrix.toJSON();

      if ( _instanceMesh.instanceColor != null ) object["instanceColor"] = _instanceMesh.instanceColor!.toJSON();
		}


		if ( this.isScene ) {
			if ( this.background != null ) {

				if ( this.background.isColor ) {

					object["background"] = this.background!.getHex();

				} else if ( this.background.isTexture ) {

					object["background"] = this.background.toJSON( meta ).uuid;

				}

			}

			if ( this.environment != null && this.environment!.isTexture ) {

				object["environment"] = this.environment!.toJSON( meta ).uuid;

			}

		} else if ( this.isMesh || this.isLine || this.isPoints ) {

			object["geometry"] = serialize( meta!.geometries, this.geometry, meta );

			var parameters = this.geometry!.parameters;

			if ( parameters != null && parameters["shapes"] != null ) {

				var shapes = parameters["shapes"];

				if ( shapes is List ) {

					for ( var i = 0, l = shapes.length; i < l; i ++ ) {

						var shape = shapes[ i ];

						serialize( meta.shapes, shape, meta );

					}

				} else {

					serialize( meta.shapes, shapes, meta );

				}

			}

		}

    // TODO
		// if ( this.type == "SkinnedMesh" ) {

    //   SkinnedMesh _skinnedMesh = this;

		// 	object["bindMode"] = _skinnedMesh.bindMode;
		// 	object["bindMatrix"] = _skinnedMesh.bindMatrix.toArray();

		// 	if ( _skinnedMesh.skeleton != null ) {

		// 		serialize( meta.skeletons, _skinnedMesh.skeleton );

		// 		object.skeleton = _skinnedMesh.skeleton.uuid;

		// 	}

		// }


		if ( this.material != null ) {

			List<String> uuids = [];

      if(this.material is List) {
        for ( var i = 0, l = this.material.length; i < l; i ++ ) {
          uuids.add( serialize( meta!.materials, this.material[ i ], meta ) );
        }

        object["material"] = uuids;
      } else {
        object["material"] = serialize( meta!.materials, this.material, meta );
      }
      
		}


		if ( this.children.length > 0 ) {

			List<Map<String, dynamic>> _childrenJSON = [];

			for ( var i = 0; i < this.children.length; i ++ ) {

  
				_childrenJSON.add( this.children[ i ].toJSON( meta: meta )["object"] );

			}

      object["children"] = _childrenJSON;

		}

		// //
    // TODO
		// if ( this.animations.length > 0 ) {

		// 	List<Map<String, dynamic>> _animationJSON = [];

		// 	for ( var i = 0; i < this.animations.length; i ++ ) {

		// 		const animation = this.animations[ i ];

		// 		_animationJSON.add( serialize( meta.animations, animation ) );

		// 	}

    //   object["animations"] = _animationJSON;

		// }

		if ( isRootObject ) {

			var geometries = extractFromCache( meta!.geometries );
			var materials = extractFromCache( meta.materials );
			var textures = extractFromCache( meta.textures );
			var images = extractFromCache( meta.images );
			var shapes = extractFromCache( meta.shapes );
			var skeletons = extractFromCache( meta.skeletons );
			var animations = extractFromCache( meta.animations );


      print( textures );
      print(" isRootObject: ${isRootObject} ");

			if ( geometries.length > 0 ) output["geometries"] = geometries;
			if ( materials.length > 0 ) output["materials"] = materials;
			if ( textures.length > 0 ) output["textures"] = textures;
			if ( images.length > 0 ) output["images"] = images;
			if ( shapes.length > 0 ) output["shapes"] = shapes;
			if ( skeletons.length > 0 ) output["skeletons"] = skeletons;
			if ( animations.length > 0 ) output["animations"] = animations;

		}

		output["object"] = object;

		return output;
	}

  serialize( Map<String, dynamic> library, dynamic element, Object3dMeta? meta ) {

    if ( library[ element.uuid ] == null ) {

      library[ element.uuid ] = element.toJSON( meta: meta );

    }

    return element.uuid;

  }


  // extract data from the cache hash
  // remove metadata on each item
  // and return as array
  List<Map<String, dynamic>> extractFromCache( Map<String, dynamic> cache ) {

    List<Map<String, dynamic>> values = [];
    for ( var key in cache.keys ) {

      Map<String, dynamic> data = cache[ key ];
      data.remove("metadata");
      
      values.add( data );

    }

    return values;

  }

	clone( [bool recursive = false] ) {

		return Object3D().copy( this, recursive );

	}

	copy ( Object3D source, bool recursive ) {

		this.name = source.name;

		this.up.copy( source.up );

		this.position.copy( source.position );
		this.rotation.order = source.rotation.order;
		this.quaternion.copy( source.quaternion );
		this.scale.copy( source.scale );

		this.matrix.copy( source.matrix );
		this.matrixWorld.copy( source.matrixWorld );

		this.matrixAutoUpdate = source.matrixAutoUpdate;
		this.matrixWorldNeedsUpdate = source.matrixWorldNeedsUpdate;

		this.layers.mask = source.layers.mask;
		this.visible = source.visible;

		this.castShadow = source.castShadow;
		this.receiveShadow = source.receiveShadow;

		this.frustumCulled = source.frustumCulled;
		this.renderOrder = source.renderOrder;

		this.userData = json.decode( json.encode( source.userData ) );

		if ( recursive == true ) {

			for ( var i = 0; i < source.children.length; i ++ ) {

				var child = source.children[ i ];
				this.add( child.clone(false) );

			}

		}

		return this;

	}



  onAfterRender({WebGLRenderer? renderer, scene, Camera? camera, geometry, material, group}) {
    // print(" Object3D.onAfterRender ${type} ${id} ");
  }

  // 用于WebGLUniforms setOptional
  getValue(name) {
    if(name == "bindMatrix") {
      return this.bindMatrix;

    } else {
      throw("Object3D.getValue type: ${this.type} name: ${name} is not support .... ");
    }
  }


  getProperty(propertyName) {
    if(propertyName == "id") {
      return this.id;
    } else if(propertyName == "name") {
      return this.name;
    } else if(propertyName == "scale") {
      return this.scale;  
    } else if(propertyName == "position") {
      return this.position;
    } else if(propertyName == "quaternion") {
      return this.quaternion;
    } else if(propertyName == "material") {
      return this.material;
    } else if(propertyName == "opacity") {
      // opacity 是别的对象的属性 Object3d 直接返回null
      return null; 
    } else if(propertyName == "morphTargetInfluences") {
      return this.morphTargetInfluences;
    } else if(propertyName == "castShadow") {
      return this.castShadow;
    } else if(propertyName == "receiveShadow") {
      return this.receiveShadow;
    } else if(propertyName == "visible") {
      return this.visible;
      
    } else {
      throw("Object3D.getProperty type: ${type} propertyName: ${propertyName} is not support ");
    }
  }

  setProperty(String propertyName, value) {
    if(propertyName == "id") {
      this.id = value;
  
    } else if(propertyName == "castShadow") {
      this.castShadow = value;
    } else if(propertyName == "receiveShadow") {
      this.receiveShadow = value;
    } else if(propertyName == "visible") {
      this.visible = value;
    
    } else {
      throw("Object3D.setProperty type: ${type} propertyName: ${propertyName} is not support ");
    }

    return this;
  }

  dispose() {
    
  }

}


class Object3dMeta {
  Map<String, dynamic> geometries = Map<String, dynamic>();
  Map<String, dynamic> materials = Map<String, dynamic>();
  Map<String, dynamic> textures = Map<String, dynamic>();
  Map<String, dynamic> images = Map<String, dynamic>();
  Map<String, dynamic> shapes = Map<String, dynamic>();
  Map<String, dynamic> skeletons = Map<String, dynamic>();
  Map<String, dynamic> animations = Map<String, dynamic>();
}