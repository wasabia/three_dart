part of three_core;

int _bufferGeometryId = 1; // BufferGeometry uses odd numbers as Id

var _bufferGeometrym1 = Matrix4();
var _bufferGeometryobj = Object3D();
var _bufferGeometryoffset = Vector3.init();
var _bufferGeometrybox = Box3(null, null);
var _bufferGeometryboxMorphTargets = Box3(null, null);
var _bufferGeometryvector = Vector3.init();

class BufferGeometry with EventDispatcher {

  int id = _bufferGeometryId += 2;
  String uuid = MathUtils.generateUUID();

  String type = "BufferGeometry";
  bool isBufferGeometry = true;
  Box3? boundingBox;
  String name = "";
  Map<String, dynamic> attributes = {};
  Map<String, List<BufferAttribute>> morphAttributes = {};
  bool morphTargetsRelative = false;
  Sphere? boundingSphere;
  Map<String, int> drawRange = { "start": 0, "count": 99999999999 };
  Map<String, dynamic> userData = {};
  List<Map<String, dynamic>> groups = [];
  BufferAttribute? index;

  late var morphTargets;
  late var directGeometry;

  bool elementsNeedUpdate = false;
  bool verticesNeedUpdate = false;
  bool uvsNeedUpdate = false;
  bool normalsNeedUpdate = false;
  bool colorsNeedUpdate = false;
  bool lineDistancesNeedUpdate = false;
  bool groupsNeedUpdate = false;
  bool isInstancedBufferGeometry = false;

  late List<double> vertices;
  late List<int> indices;
  late List<double> normals;
  late List<double> uvs;

  late List<Color> colors;
  bool isGeometry = false;
  late List<num> lineDistances;

  late List<Face3> faces;
  late List faceVertexUvs;

  Map<String, dynamic> parameters = {};

  late num curveSegments;
  late List<Shape> shapes;

  int? maxInstanceCount;
  int? instanceCount;

  BufferGeometry() {

  }

  BufferGeometry.fromJSON(Map<String, dynamic> json, Map<String, dynamic> rootJSON) {
    uuid = json["uuid"];
    type = json["type"];


  }

  static castJSON(Map<String, dynamic> json, Map<String, dynamic> rootJSON) {
    String _type = json["type"];

    if(_type == "BufferGeometry") {
      return BufferGeometry.fromJSON(json, rootJSON);
    } else if(_type == "ShapeBufferGeometry") {
      return ShapeBufferGeometry.fromJSON(json, rootJSON);
    } else if(_type == "ExtrudeBufferGeometry") {
      return ExtrudeBufferGeometry.fromJSON(json, rootJSON);
    } else {
      throw(" BufferGeometry castJSON _type: ${_type} is not support yet ");
    }
  }

  getIndex() {

		return this.index;

	}

	setIndex( index ) {

		// if ( Array.isArray( index ) ) {

		// 	this.index = new ( arrayMax( index ) > 65535 ? Uint32BufferAttribute : Uint16BufferAttribute )( index, 1 );

		// } else {

			// this.index = index;

		// }

    if( index is List ) {
      if( arrayMax( index ) > 65535 ) {
        this.index = Uint32BufferAttribute(Uint32Array(index.length).set(index), 1, false);
      } else {
        this.index = Uint16BufferAttribute(Uint16Array(index.length).set(index), 1, false);
      }
    } else {
      this.index = index;
    }
    
	}

	getAttribute(String name ) {

		return this.attributes[ name ];

	}

	setAttribute(String name, attribute ) {

		this.attributes[ name ] = attribute;


		return this;

	}

	deleteAttribute(String name ) {

    this.attributes.remove(name);

		return this;

	}

	hasAttribute(String name ) {

		return this.attributes[ name ] != null;

	}

	addGroup( int start, int count, {int materialIndex = 0} ) {

		this.groups.add( {

			"start": start,
			"count": count,
			"materialIndex": materialIndex

		} );

	}

	clearGroups() {

		this.groups = [];

	}

	setDrawRange(int start, int count ) {

		this.drawRange["start"] = start;
		this.drawRange["count"] = count;

	}

	applyMatrix4( Matrix4 matrix ) {


		var position = this.attributes["position"];
		if ( position != null ) {
			position.applyMatrix4( matrix );
			position.needsUpdate = true;
		}


		var normal = this.attributes["normal"];



		if ( normal != null ) {

			var normalMatrix = new Matrix3().getNormalMatrix( matrix );

			normal.applyNormalMatrix( normalMatrix );

			normal.needsUpdate = true;

		}

		var tangent = this.attributes["tangent"];


		if ( tangent != null ) {

			tangent.transformDirection( matrix );

			tangent.needsUpdate = true;

		}


    

		if ( this.boundingBox != null ) {

			this.computeBoundingBox();

		}

		if ( this.boundingSphere != null ) {

			this.computeBoundingSphere();

		}

	}

	rotateX( num angle ) {

		// rotate geometry around world x-axis

		_bufferGeometrym1.makeRotationX( angle );

		this.applyMatrix4( _bufferGeometrym1 );

		return this;

	}

	rotateY( num angle ) {

		// rotate geometry around world y-axis

		_bufferGeometrym1.makeRotationY( angle );

		this.applyMatrix4( _bufferGeometrym1 );

		return this;

	}

	rotateZ( num angle ) {

		// rotate geometry around world z-axis

		_bufferGeometrym1.makeRotationZ( angle );

		this.applyMatrix4( _bufferGeometrym1 );

		return this;

	}

	translate( num x, num y, num z ) {

		// translate geometry

		_bufferGeometrym1.makeTranslation( x, y, z );
		this.applyMatrix4( _bufferGeometrym1 );

    return this;
	}

	scale( num x, num y, num z ) {

		// scale geometry

		_bufferGeometrym1.makeScale( x, y, z );

		this.applyMatrix4( _bufferGeometrym1 );

		return this;

	}

	lookAt( Vector3 vector ) {

		_bufferGeometryobj.lookAt( vector );

		_bufferGeometryobj.updateMatrix();

		this.applyMatrix4( _bufferGeometryobj.matrix );

		return this;

	}

	center() {

		this.computeBoundingBox();

		this.boundingBox!.getCenter( _bufferGeometryoffset );
    _bufferGeometryoffset.negate();


		this.translate( _bufferGeometryoffset.x, _bufferGeometryoffset.y, _bufferGeometryoffset.z );
	}

	setFromObject( Object3D object ) {


		var geometry = object.geometry;

		if ( object.type == "Points" || object.type == "Line" ) {

			var positions = new Float32BufferAttribute( geometry.vertices.length * 3, 3, false );
			var colors = new Float32BufferAttribute( geometry.colors.length * 3, 3, false );

			this.setAttribute( 'position', positions.copyVector3sArray( geometry.vertices ) );
			this.setAttribute( 'color', colors.copyColorsArray( geometry.colors ) );

			if ( geometry.lineDistances != null && geometry.lineDistances.length == geometry.vertices.length ) {

				var lineDistances = new Float32BufferAttribute( geometry.lineDistances.length, 1, false );

				this.setAttribute( 'lineDistance', lineDistances.copyArray( geometry.lineDistances ) );

			}

			if ( geometry.boundingSphere != null ) {

				this.boundingSphere = geometry.boundingSphere!.clone();

			}

			if ( geometry.boundingBox != null ) {

				this.boundingBox = geometry.boundingBox!.clone();

			}

		} else if ( object.type == "Mesh" ) {

			if ( geometry != null && geometry.isGeometry ) {

				// this.fromGeometry( geometry );
        throw(" BufferGeometry  setFromObject todo" );

			}

		}

		return this;

	}

	setFromPoints( points ) {

		List<num> position = [];

		for ( var i = 0, l = points.length; i < l; i ++ ) {

			var point = points[ i ];

      if(point.type == "Vector2") {
        position.addAll( [point.x, point.y, 0.0] );
      } else {
        position.addAll( [point.x, point.y, point.z ?? 0] );
      }


		}

		this.setAttribute( 'position', new Float32BufferAttribute( position, 3, false ) );

		return this;

	}

	updateFromObject( object ) {

		var geometry = object.geometry;

		if ( object.isMesh ) {

			var direct = geometry.directGeometry;

			if ( geometry.elementsNeedUpdate == true ) {

				direct = null;
				geometry.elementsNeedUpdate = false;

			}

			if ( direct == null ) {

				return this.fromGeometry( geometry );

			}

			direct.verticesNeedUpdate = geometry.verticesNeedUpdate;
			direct.normalsNeedUpdate = geometry.normalsNeedUpdate;
			direct.colorsNeedUpdate = geometry.colorsNeedUpdate;
			direct.uvsNeedUpdate = geometry.uvsNeedUpdate;
			direct.groupsNeedUpdate = geometry.groupsNeedUpdate;

			geometry.verticesNeedUpdate = false;
			geometry.normalsNeedUpdate = false;
			geometry.colorsNeedUpdate = false;
			geometry.uvsNeedUpdate = false;
			geometry.groupsNeedUpdate = false;

			geometry = direct;

		}

		if ( geometry.verticesNeedUpdate == true ) {

			var attribute = this.attributes["position"];

			if ( attribute != null ) {

				attribute.copyVector3sArray( geometry.vertices );
				attribute.needsUpdate = true;

			}

			geometry.verticesNeedUpdate = false;

		}

		if ( geometry.normalsNeedUpdate == true ) {

			var attribute = this.attributes["normal"];

			if ( attribute != null ) {

				attribute.copyVector3sArray( geometry.normals );
				attribute.needsUpdate = true;

			}

			geometry.normalsNeedUpdate = false;

		}

		if ( geometry.colorsNeedUpdate == true ) {

			var attribute = this.attributes["color"];

			if ( attribute != null ) {

				attribute.copyColorsArray( geometry.colors );
				attribute.needsUpdate = true;

			}

			geometry.colorsNeedUpdate = false;

		}

		if ( geometry.uvsNeedUpdate ) {

			var attribute = this.attributes["uv"];

			if ( attribute != null ) {

				attribute.copyVector2sArray( geometry.uvs );
				attribute.needsUpdate = true;

			}

			geometry.uvsNeedUpdate = false;

		}

		if ( geometry.lineDistancesNeedUpdate ) {

			var attribute = this.attributes["lineDistance"];

			if ( attribute != null ) {

				attribute.copyArray( geometry.lineDistances );
				attribute.needsUpdate = true;

			}

			geometry.lineDistancesNeedUpdate = false;

		}

		if ( geometry.groupsNeedUpdate ) {

			geometry.computeGroups( object.geometry );
			this.groups = geometry.groups;

			geometry.groupsNeedUpdate = false;

		}

		return this;

	}

	fromGeometry( Geometry geometry ) {

		geometry.directGeometry = new DirectGeometry().fromGeometry( geometry );

		return this.fromDirectGeometry( geometry.directGeometry! );

	}

	fromDirectGeometry( DirectGeometry geometry ) {

		var positions = List<num>.filled( geometry.vertices.length * 3, 0 );
		this.setAttribute( 'position', Float32BufferAttribute( positions, 3, false ).copyVector3sArray( geometry.vertices ) );

		if ( geometry.normals.length > 0 ) {

			var normals = List<num>.filled( geometry.normals.length * 3, 0 );
			this.setAttribute( 'normal', Float32BufferAttribute( normals, 3, false ).copyVector3sArray( geometry.normals ) );

		}

		if ( geometry.colors.length > 0 ) {

			var colors = List<num>.filled( geometry.colors.length * 3, 0 );
			this.setAttribute( 'color', Float32BufferAttribute( colors, 3, false ).copyColorsArray( geometry.colors ) );

		}

		if ( geometry.uvs.length > 0 ) {

			var uvs = List<num>.filled( geometry.uvs.length * 2, 0 );
			this.setAttribute( 'uv', Float32BufferAttribute( uvs, 2, false ).copyVector2sArray( geometry.uvs ) );

		}

		if ( geometry.uvs2.length > 0 ) {

			var uvs2 = List<num>.filled( geometry.uvs2.length * 2, 0 );
			this.setAttribute( 'uv2', Float32BufferAttribute( uvs2, 2, false ).copyVector2sArray( geometry.uvs2 ) );

		}

		// groups

		this.groups = geometry.groups;

		// morphs

		geometry.morphTargets.keys.forEach(( name ) {

			List<BufferAttribute> array = [];
			var morphTargets = geometry.morphTargets[ name ];

			for ( var i = 0, l = morphTargets.length; i < l; i ++ ) {

				var morphTarget = morphTargets[ i ];

        List<num> _lvs = List<num>.filled(morphTarget["data"].length * 3, 0);
				var attribute = new Float32BufferAttribute( _lvs, 3, false );
				attribute.name = morphTarget["name"];

				array.add( attribute.copyVector3sArray( morphTarget["data"] ) );

			}

			this.morphAttributes[ name ] = array;

		});

		// skinning

		if ( geometry.skinIndices.length > 0 ) {

      List<num> _lvs = List<num>.filled(geometry.skinIndices.length * 4, 0);

			var skinIndices = Float32BufferAttribute( _lvs, 4, false );
			this.setAttribute( 'skinIndex', skinIndices.copyVector4sArray( geometry.skinIndices ) );

		}

		if ( geometry.skinWeights.length > 0 ) {
      List<num> _lvs = List<num>.filled(geometry.skinWeights.length * 4, 0);

			var skinWeights = Float32BufferAttribute( _lvs, 4, false );
			this.setAttribute( 'skinWeight', skinWeights.copyVector4sArray( geometry.skinWeights ) );

		}

		//

		if ( geometry.boundingSphere != null ) {

			this.boundingSphere = geometry.boundingSphere!.clone();

		}

		if ( geometry.boundingBox != null ) {

			this.boundingBox = geometry.boundingBox!.clone();

		}

		return this;

	}

	computeBoundingBox() {

		if ( this.boundingBox == null ) {

			this.boundingBox = new Box3(null, null);

		}

		var position = this.attributes["position"];
		var morphAttributesPosition = this.morphAttributes["position"];

		if ( position != null && position.isGLBufferAttribute ) {

			print( 'THREE.BufferGeometry.computeBoundingBox(): GLBufferAttribute requires a manual bounding box. Alternatively set "mesh.frustumCulled" to "false". ${this}' );

      double Infinity = 9999999999.0;

			this.boundingBox!.set(
				new Vector3( - Infinity, - Infinity, - Infinity ),
				new Vector3( Infinity, Infinity, Infinity )
			);

			return;

		}

		if ( position != null ) {

			this.boundingBox!.setFromBufferAttribute( position );

			// process morph attributes if present

			if ( morphAttributesPosition != null ) {

				for ( var i = 0, il = morphAttributesPosition.length; i < il; i ++ ) {

					var morphAttribute = morphAttributesPosition[ i ];
					_bufferGeometrybox.setFromBufferAttribute( morphAttribute );

					if ( this.morphTargetsRelative ) {

						_bufferGeometryvector.addVectors( this.boundingBox!.min, _bufferGeometrybox.min );
						this.boundingBox!.expandByPoint( _bufferGeometryvector );

						_bufferGeometryvector.addVectors( this.boundingBox!.max, _bufferGeometrybox.max );
						this.boundingBox!.expandByPoint( _bufferGeometryvector );

					} else {

						this.boundingBox!.expandByPoint( _bufferGeometrybox.min );
						this.boundingBox!.expandByPoint( _bufferGeometrybox.max );

					}

				}

			}

		} else {

			this.boundingBox!.makeEmpty();

		}

		if ( this.boundingBox!.min.x == null || this.boundingBox!.min.y == null || this.boundingBox!.min.z == null ) {

			print( 'THREE.BufferGeometry.computeBoundingBox(): Computed min/max have NaN values. The "position" attribute is likely to have NaN values. ${this}' );

		}


	}

	computeBoundingSphere() {

		if ( this.boundingSphere == null ) {

			this.boundingSphere = new Sphere(null, null);

		}

		var position = this.attributes["position"];
		var morphAttributesPosition = this.morphAttributes["position"];

		if ( position != null && position.isGLBufferAttribute ) {


			this.boundingSphere!.set( new Vector3.init(), 99999999999 );

			return;

		}

		if ( position != null ) {

			// first, find the center of the bounding sphere

			var center = this.boundingSphere!.center;

			_bufferGeometrybox.setFromBufferAttribute( position );

			// process morph attributes if present

			if ( morphAttributesPosition != null ) {

				for ( var i = 0, il = morphAttributesPosition.length; i < il; i ++ ) {

					var morphAttribute = morphAttributesPosition[ i ];
					_bufferGeometryboxMorphTargets.setFromBufferAttribute( morphAttribute );

					if ( this.morphTargetsRelative ) {

						_bufferGeometryvector.addVectors( _bufferGeometrybox.min, _bufferGeometryboxMorphTargets.min );
						_bufferGeometrybox.expandByPoint( _bufferGeometryvector );

						_bufferGeometryvector.addVectors( _bufferGeometrybox.max, _bufferGeometryboxMorphTargets.max );
						_bufferGeometrybox.expandByPoint( _bufferGeometryvector );

					} else {

						_bufferGeometrybox.expandByPoint( _bufferGeometryboxMorphTargets.min );
						_bufferGeometrybox.expandByPoint( _bufferGeometryboxMorphTargets.max );

					}

				}

			}

			_bufferGeometrybox.getCenter( center );

			// second, try to find a boundingSphere with a radius smaller than the
			// boundingSphere of the boundingBox: sqrt(3) smaller in the best case

			double maxRadiusSq = 0;


 
			for ( var i = 0, il = position.count; i < il; i ++ ) {

				_bufferGeometryvector.fromBufferAttribute( position, i );

				maxRadiusSq = Math.max( maxRadiusSq, center.distanceToSquared( _bufferGeometryvector ) );

			}


   
			// process morph attributes if present

			if ( morphAttributesPosition != null ) {

				for ( var i = 0, il = morphAttributesPosition.length; i < il; i ++ ) {

					var morphAttribute = morphAttributesPosition[ i ];
					var morphTargetsRelative = this.morphTargetsRelative;

					for ( var j = 0, jl = morphAttribute.count; j < jl; j ++ ) {

						_bufferGeometryvector.fromBufferAttribute( morphAttribute, j);

						if ( morphTargetsRelative ) {

							_bufferGeometryoffset.fromBufferAttribute( position, j);
							_bufferGeometryvector.add( _bufferGeometryoffset );

						}

						maxRadiusSq = Math.max( maxRadiusSq, center.distanceToSquared( _bufferGeometryvector ) );

					}

				}

			}

			this.boundingSphere!.radius = Math.sqrt( maxRadiusSq );

      

			if (  this.boundingSphere!.radius == null ) {

				print( 'THREE.BufferGeometry.computeBoundingSphere(): Computed radius is NaN. The "position" attribute is likely to have NaN values. ${this}' );

			}

		}


	}

	computeFaceNormals() {

		// backwards compatibility

	}

	computeVertexNormals() {

		var index = this.index;
		var positionAttribute = this.getAttribute( 'position' );

		if ( positionAttribute != null ) {

			var normalAttribute = this.getAttribute( 'normal' );

			if ( normalAttribute == null ) {

				normalAttribute = new Float32BufferAttribute( List<num>.filled( positionAttribute.count * 3, 0 ), 3, false );
				this.setAttribute( 'normal', normalAttribute );

			} else {

				// reset existing normals to zero

				for ( var i = 0, il = normalAttribute.count; i < il; i ++ ) {

					normalAttribute.setXYZ( i, 0, 0, 0 );

				}

			}

			var pA = new Vector3.init(), pB = new Vector3.init(), pC = new Vector3.init();
			var nA = new Vector3.init(), nB = new Vector3.init(), nC = new Vector3.init();
			var cb = new Vector3.init(), ab = new Vector3.init();

			// indexed elements

			if ( index != null ) {

				for ( var i = 0, il = index.count; i < il; i += 3 ) {

					var vA = index.getX( i + 0 );
					var vB = index.getX( i + 1 );
					var vC = index.getX( i + 2 );

					pA.fromBufferAttribute( positionAttribute, vA );
					pB.fromBufferAttribute( positionAttribute, vB );
					pC.fromBufferAttribute( positionAttribute, vC );

					cb.subVectors( pC, pB );
					ab.subVectors( pA, pB );
					cb.cross( ab );

					nA.fromBufferAttribute( normalAttribute, vA );
					nB.fromBufferAttribute( normalAttribute, vB );
					nC.fromBufferAttribute( normalAttribute, vC );

					nA.add( cb );
					nB.add( cb );
					nC.add( cb );

					normalAttribute.setXYZ( vA, nA.x, nA.y, nA.z );
					normalAttribute.setXYZ( vB, nB.x, nB.y, nB.z );
					normalAttribute.setXYZ( vC, nC.x, nC.y, nC.z );

				}

			} else {

				// non-indexed elements (unconnected triangle soup)

				for ( var i = 0, il = positionAttribute.count; i < il; i += 3 ) {

					pA.fromBufferAttribute( positionAttribute, i + 0 );
					pB.fromBufferAttribute( positionAttribute, i + 1 );
					pC.fromBufferAttribute( positionAttribute, i + 2 );

					cb.subVectors( pC, pB );
					ab.subVectors( pA, pB );
					cb.cross( ab );

					normalAttribute.setXYZ( i + 0, cb.x, cb.y, cb.z );
					normalAttribute.setXYZ( i + 1, cb.x, cb.y, cb.z );
					normalAttribute.setXYZ( i + 2, cb.x, cb.y, cb.z );

				}

			}

			this.normalizeNormals();

			normalAttribute.needsUpdate = true;

		}

	}

	merge( geometry, offset ) {

		if ( ! ( geometry && geometry.isBufferGeometry ) ) {

			print( 'THREE.BufferGeometry.merge(): geometry not an instance of THREE.BufferGeometry. ${geometry}' );
			return;

		}

		if ( offset == null ) {

			offset = 0;

			print(
				'THREE.BufferGeometry.merge(): Overwriting original geometry, starting at offset=0. '
				+ 'Use BufferGeometryUtils.mergeBufferGeometries() for lossless merge.'
			);

		}

		var attributes = this.attributes;


    attributes.keys.forEach((key) {

			if ( geometry.attributes[ key ] != null ) {
        var attribute1 = attributes[ key ];
        var attributeArray1 = attribute1.array;

        var attribute2 = geometry.attributes[ key ];
        var attributeArray2 = attribute2.array;

        var attributeOffset = attribute2.itemSize * offset;
        var length = Math.min( attributeArray2.length, attributeArray1.length - attributeOffset );

        for ( var i = 0, j = attributeOffset; i < length; i ++, j ++ ) {

          attributeArray1[ j ] = attributeArray2[ i ];

        }
      }

		});

		return this;

	}

	normalizeNormals() {

		var normals = this.attributes["normal"];

		for ( var i = 0, il = normals.count; i < il; i ++ ) {

			_bufferGeometryvector.fromBufferAttribute( normals, i);

			_bufferGeometryvector.normalize();

			normals.setXYZ( i, _bufferGeometryvector.x, _bufferGeometryvector.y, _bufferGeometryvector.z );

		}

	}

	toNonIndexed() {

		convertBufferAttribute( attribute, indices ) {
      
      print("BufferGeometry.convertBufferAttribute todo  ");

			var array = attribute.array;
			var itemSize = attribute.itemSize;
			var normalized = attribute.normalized;

			var array2 = Float32Array( indices.length * itemSize);

			var index = 0, index2 = 0;

			for ( var i = 0, l = indices.length; i < l; i ++ ) {

				index = indices[ i ] * itemSize;

				for ( var j = 0; j < itemSize; j ++ ) {

					array2[ index2 ++ ] = array[ index ++ ];

				}

			}

			return new Float32BufferAttribute( array2, itemSize, normalized );

		}

		//

		if ( this.index == null ) {

			print( 'THREE.BufferGeometry.toNonIndexed(): Geometry is already non-indexed.' );
			return this;

		}

		var geometry2 = new BufferGeometry();

		var indices = this.index!.array;
		var attributes = this.attributes;

		// attributes

		attributes.keys.forEach((name) {

			var attribute = attributes[ name ];

			var newAttribute = convertBufferAttribute( attribute, indices );

			geometry2.setAttribute( name, newAttribute );

		});

		// morph attributes

		var morphAttributes = this.morphAttributes;

		morphAttributes.keys.forEach(( name ) {

			List<BufferAttribute> morphArray = [];
			List<BufferAttribute> morphAttribute = morphAttributes[ name ]!; // morphAttribute: array of Float32BufferAttributes

			for ( var i = 0, il = morphAttribute.length; i < il; i ++ ) {

				var attribute = morphAttribute[ i ];

				var newAttribute = convertBufferAttribute( attribute, indices );

				morphArray.add( newAttribute );

			}

			geometry2.morphAttributes[ name ] = morphArray;

		});

		geometry2.morphTargetsRelative = this.morphTargetsRelative;

		// groups

		var groups = this.groups;

		for ( var i = 0, l = groups.length; i < l; i ++ ) {

			var group = groups[ i ];
			geometry2.addGroup( group["start"], group["count"], materialIndex: group["materialIndex"] );

		}

		return geometry2;

	}

	toJSON({Object3dMeta? meta}) {

		Map<String, dynamic> data = {
			"metadata": {
				"version": 4.5,
				"type": 'BufferGeometry',
				"generator": 'BufferGeometry.toJSON'
			}
		};

		// standard BufferGeometry serialization

		data["uuid"] = this.uuid;
		data["type"] = this.type;
		if ( this.name != '' ) data["name"] = this.name;
		if ( this.userData.keys.length > 0 ) data["userData"] = this.userData;

		if ( this.parameters != null ) {


			parameters.keys.forEach(( key ) {

				if ( parameters[ key ] != null ) data[ key ] = parameters[ key ];

			});

			return data;

		}

		data["data"] = { "attributes": {} };

		var index = this.index;

		if ( index != null ) {

      // TODO
			data["data"]["index"] = {
				"type": "TODO",
				"array": index.array.sublist(0)
			};

		}

		var attributes = this.attributes;

		attributes.keys.forEach(( key ) {

			var attribute = attributes[ key ];

			var attributeData = attribute.toJSON( data["data"] );

			if ( attribute.name != '' ) attributeData["name"] = attribute.name;

			data["data"]["attributes"][ key ] = attributeData;

		});

		var morphAttributes = {};
		var hasMorphAttributes = false;

		morphAttributes.keys.forEach(( key ) {

			var attributeArray = this.morphAttributes[ key ]!;

			List<BufferAttribute> array = [];

			for ( var i = 0, il = attributeArray.length; i < il; i ++ ) {

				var attribute = attributeArray[ i ];

				var attributeData = attribute.toJSON();

				if ( attribute.name != '' ) attributeData.name = attribute.name;

				array.add( attributeData );

			}

			if ( array.length > 0 ) {

				morphAttributes[ key ] = array;

				hasMorphAttributes = true;

			}

		});

		if ( hasMorphAttributes ) {

			data["data"].morphAttributes = morphAttributes;
			data["data"].morphTargetsRelative = this.morphTargetsRelative;

		}

		var groups = this.groups;

		if ( groups.length > 0 ) {

			data["data"]["groups"] = json.decode( json.encode( groups ) );

		}

		var boundingSphere = this.boundingSphere;

		if ( boundingSphere != null ) {

			data["data"]["boundingSphere"] = {
				"center": boundingSphere.center.toArray(List.filled(3, 0)),
				"radius": boundingSphere.radius
			};

		}

		return data;

	}

	clone() {

		/*
		 // Handle primitives

		 var parameters = this.parameters;

		 if ( parameters != null ) {

		 var values = [];

		 for ( var key in parameters ) {

		 values.push( parameters[ key ] );

		 }

		 var geometry = Object.create( this.constructor.prototype );
		 this.constructor.apply( geometry, values );
		 return geometry;

		 }

		 return new this.constructor().copy( this );
		 */

		return new BufferGeometry().copy( this );

	}

	copy( source ) {

		// reset

		// this.index = null;
		// this.attributes = {};
		// this.morphAttributes = {};
		// this.groups = [];
		// this.boundingBox = null;
		// this.boundingSphere = null;

		// used for storing cloned, shared data

		var data = {};

		// name

		this.name = source.name;

		// index

		var index = source.index;

		if ( index != null ) {

			this.setIndex( index.clone( data ) );

		}

		// attributes

		var attributes = source.attributes;

		for ( var name in attributes ) {

			var attribute = attributes[ name ];
			this.setAttribute( name, attribute.clone( data ) );

		}

		// morph attributes

		var morphAttributes = source.morphAttributes;

		for ( var name in morphAttributes ) {

			List<BufferAttribute> array = [];
			var morphAttribute = morphAttributes[ name ]; // morphAttribute: array of Float32BufferAttributes

			for ( var i = 0, l = morphAttribute.length; i < l; i ++ ) {

				array.add( morphAttribute[ i ].clone( data ) );

			}

			this.morphAttributes[ name ] = array;

		}

		this.morphTargetsRelative = source.morphTargetsRelative;

		// groups

		var groups = source.groups;

		for ( var i = 0, l = groups.length; i < l; i ++ ) {

			var group = groups[ i ];
			this.addGroup( group.start, group.count, materialIndex: group.materialIndex );

		}

		// bounding box

		var boundingBox = source.boundingBox;

		if ( boundingBox != null ) {

			this.boundingBox = boundingBox.clone();

		}

		// bounding sphere

		var boundingSphere = source.boundingSphere;

		if ( boundingSphere != null ) {

			this.boundingSphere = boundingSphere.clone();

		}

		// draw range

		this.drawRange["start"] = source.drawRange.start;
		this.drawRange["count"] = source.drawRange.count;

		// user data

		this.userData = source.userData;

		return this;

	}

	dispose() {
    print(" BufferGeometry dispose ........... ");

		this.dispatchEvent( Event({"type": "dispose"}) );

	}


}

class BufferGeometryParameters {
  late List<Shape> shapes;
  late num curveSegments;
  late Map<String, dynamic> options;
  late num steps;
  late num depth;
  late bool bevelEnabled;
  late num bevelThickness;
  late num bevelSize;
  late num bevelOffset;
  late num bevelSegments;
  late Curve extrudePath;
  late dynamic UVGenerator;
  late num amount;

  // UVGenerator

  BufferGeometryParameters(Map<String, dynamic> json) {
    shapes = json["shapes"];
    curveSegments = json["curveSegments"];
    options = json["options"];
    depth = json["depth"];

  }


  Map<String, dynamic> toJSON() {
    return {
      "curveSegments": curveSegments
    };
  }
  
}

