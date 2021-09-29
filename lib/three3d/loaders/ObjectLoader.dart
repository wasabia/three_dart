part of three_loaders;



class ObjectLoader extends Loader {

	ObjectLoader( manager ) : super(manager) {

	}

	load( url, onLoad, onProgress, onError ) {

		var scope = this;

		var path = ( this.path == '' ) ? LoaderUtils.extractUrlBase( url ) : this.path;
		this.resourcePath = this.resourcePath ?? path;

		var loader = new FileLoader( this.manager );
		loader.setPath( this.path );
		loader.setRequestHeader( this.requestHeader );
		loader.setWithCredentials( this.withCredentials );
		loader.load( url, ( text ) {

			var json = null;

			try {

				json = convert.jsonDecode( text );

			} catch ( error ) {

				if ( onError != null ) onError( error );

				print( 'THREE:ObjectLoader: Can\'t parse ' + url + '.${error}' );

				return;

			}

			var metadata = json.metadata;

			if ( metadata == null || metadata.type == null || metadata.type.toLowerCase() == 'geometry' ) {

				print( 'THREE.ObjectLoader: Can\'t load ' + url );
				return;

			}

			scope.parse( json, onLoad: onLoad );

		}, onProgress, onError );

	}

	loadAsync( url, onProgress ) async {

		var scope = this;

		var path = ( this.path == '' ) ? LoaderUtils.extractUrlBase( url ) : this.path;
		this.resourcePath = this.resourcePath ?? path;

		var loader = new FileLoader( this.manager );
		loader.setPath( this.path );
		loader.setRequestHeader( this.requestHeader );
		loader.setWithCredentials( this.withCredentials );

		var text = await loader.loadAsync( url, onProgress );

		var json = convert.jsonDecode( text );

		var metadata = json.metadata;

		if ( metadata == null || metadata.type == null || metadata.type.toLowerCase() == 'geometry' ) {

			throw( 'THREE.ObjectLoader: Can\'t load ' + url );

		}

		return await scope.parseAsync( json );

	}

	parse( json, {String? path, Function? onLoad, Function? onError} ) {

		var animations = this.parseAnimations( json.animations );
		var shapes = this.parseShapes( json.shapes );
		var geometries = this.parseGeometries( json.geometries, shapes );

    print(" ObjectLoader parse parseImages TODO ");
		var images = this.parseImages( json.images, () {

			// if ( onLoad != null ) onLoad( object );

		} );

		var textures = this.parseTextures( json.textures, images );
		var materials = this.parseMaterials( json.materials, textures );

		var object = this.parseObject( json.object, geometries, materials, textures, animations );
		var skeletons = this.parseSkeletons( json.skeletons, object );

		this.bindSkeletons( object, skeletons );

		//

		if ( onLoad != null ) {

			var hasImages = false;

			for ( var uuid in images ) {

        print(" ObjectLoader .....TODO image ");
				// if ( images[ uuid ] is HTMLImageElement ) {

				// 	hasImages = true;
				// 	break;

				// }

			}

			if ( hasImages == false ) onLoad( object );

		}

		return object;

	}

	parseAsync( Map<String, dynamic> json ) async {

		var animations = this.parseAnimations( json["animations"] );
		var shapes = this.parseShapes( json["shapes"] );
		var geometries = this.parseGeometries( json["geometries"], shapes );

		var images = await this.parseImagesAsync( json["images"] );

		var textures = this.parseTextures( json["textures"], images );
		var materials = this.parseMaterials( json["materials"], textures );

		var object = this.parseObject( json["object"], geometries, materials, textures, animations );

		// var skeletons = this.parseSkeletons( json.skeletons, object );
		// this.bindSkeletons( object, skeletons );

		return object;

	}

	parseShapes( json ) {

		var shapes = {};

		if ( json != null ) {

			for ( var i = 0, l = json.length; i < l; i ++ ) {

				var shape = new Shape(null).fromJSON( json[ i ] );

				shapes[ shape.uuid ] = shape;

			}

		}

		return shapes;

	}

	parseSkeletons( json, object ) {

		var skeletons = {};
		var bones = {};

		// generate bone lookup table

		object.traverse( ( child ) {

			if ( child.isBone ) bones[ child.uuid ] = child;

		} );

		// create skeletons

		if ( json != null ) {

			for ( var i = 0, l = json.length; i < l; i ++ ) {

				var skeleton = new Skeleton().fromJSON( json[ i ], bones );

				skeletons[ skeleton.uuid ] = skeleton;

			}

		}

		return skeletons;

	}

	parseGeometries(json, shapes ) {

		var geometries = {};

		if ( json != null ) {

			var bufferGeometryLoader = new BufferGeometryLoader(null);

			for ( var i = 0, l = json.length; i < l; i ++ ) {

				var geometry;
				Map<String, dynamic> data = json[ i ];

				switch ( data["type"] ) {

					case 'BufferGeometry':
					case 'InstancedBufferGeometry':

						geometry = bufferGeometryLoader.parse( data );

						break;

					case 'Geometry':

						print( 'THREE.ObjectLoader: The legacy Geometry type is no longer supported.' );

						break;

					default:

						if ( data["type"] == "PlaneGeometry" ) {
							geometry = PlaneGeometry.fromJSON( data );
            } else if( data["type"] == "BoxGeometry" ) {
              geometry = BoxGeometry.fromJSON( data );
            } else if( data["type"] == "CylinderGeometry") {
              geometry = CylinderGeometry.fromJSON(data);  
						} else {

							throw( "THREE.ObjectLoader: Unsupported geometry type ${ data["type"] }" );

						}

				}

				geometry.uuid = data["uuid"];

				if ( data["name"] != null ) geometry.name = data["name"];
				if ( geometry.isBufferGeometry == true && data["userData"] != null ) geometry.userData = data["userData"];

				geometries[ data["uuid"] ] = geometry;

			}

		}

		return geometries;

	}

	parseMaterials( json, textures ) {

		var cache = {}; // MultiMaterial
		var materials = {};

		if ( json != null ) {

			var loader = new MaterialLoader(null);
			loader.setTextures( textures );

			for ( var i = 0, l = json.length; i < l; i ++ ) {

				Map<String, dynamic> data = json[ i ];

				if ( data["type"] == 'MultiMaterial' ) {

					// Deprecated

					var array = [];

					for ( var j = 0; j < data["materials"].length; j ++ ) {

						var material = data["materials"][ j ];

						if ( cache[ material.uuid ] == null ) {

							cache[ material.uuid ] = loader.parse( material );

						}

						array.add( cache[ material.uuid ] );

					}

					materials[ data["uuid"] ] = array;

				} else {

					if ( cache[ data["uuid"] ] == null ) {

						cache[ data["uuid"] ] = loader.parse( data );

					}

					materials[ data["uuid"] ] = cache[ data["uuid"] ];

				}

			}

		}

		return materials;

	}

	parseAnimations( json ) {

		var animations = {};

		if ( json != null ) {

			for ( var i = 0; i < json.length; i ++ ) {

				var data = json[ i ];

				var clip = AnimationClip.parse( data );

				animations[ clip.uuid ] = clip;

			}

		}

		return animations;

	}

	parseImages( json, onLoad ) {

		var scope = this;
		var images = {};

		var loader;

		Function loadImage = ( url ) {

			scope.manager.itemStart( url );

			return loader.load( url, () {

				scope.manager.itemEnd( url );

			}, null, () {

				scope.manager.itemError( url );
				scope.manager.itemEnd( url );

			} );

		};

		Function deserializeImage = ( image ) {

			if ( image is String ) {

				var url = image;

				var path = RegExp("^(\/\/)|([a-z]+:(\/\/)?)", caseSensitive: false).hasMatch( url ) ? url : scope.resourcePath! + url;

				return loadImage( path );

			} else {

				if ( image.data ) {

					return {
						"data": getTypedArray( image.type, image.data ),
						"width": image.width,
						"height": image.height
					};

				} else {

					return null;

				}

			}

		};

		if ( json != null && json.length > 0 ) {

			var manager = new LoadingManager( onLoad, null, null );

			loader = new ImageLoader( manager );
			loader.setCrossOrigin( this.crossOrigin );

			for ( var i = 0, il = json.length; i < il; i ++ ) {

				var image = json[ i ];
				var url = image.url;

				if ( url is List ) {

					// load array of images e.g CubeTexture

					images[ image.uuid ] = [];

					for ( var j = 0, jl = url.length; j < jl; j ++ ) {

						var currentUrl = url[ j ];

						var deserializedImage = deserializeImage( currentUrl );

						if ( deserializedImage != null ) {
              

              print(" ObjectLoader  deserializedImage TODO ");

							// if ( deserializedImage is HTMLImageElement ) {

							// 	images[ image.uuid ].push( deserializedImage );

							// } else {

							// 	// special case: handle array of data textures for cube textures

							// 	images[ image.uuid ].push( new DataTexture( deserializedImage.data, deserializedImage.width, deserializedImage.height ) );

							// }

						}

					}

				} else {

					// load single image

					var deserializedImage = deserializeImage( image.url );

					if ( deserializedImage != null ) {

						images[ image.uuid ] = deserializedImage;

					}

				}

			}

		}

		return images;

	}

	parseImagesAsync( json ) async {

		var scope = this;
		var images = {};

		var loader;

		Function deserializeImage = ( image ) async {

			if ( image is String ) {

				var url = image;

				var path = RegExp("^(\/\/)|([a-z]+:(\/\/)?)").hasMatch( url ) ? url : scope.resourcePath! + url;

				return await loader.loadAsync( path );

			} else {

				if ( image.data ) {

					return {
						"data": getTypedArray( image.type, image.data ),
						"width": image.width,
						"height": image.height
					};

				} else {

					return null;

				}

			}

		};

		if ( json != null && json.length > 0 ) {

			loader = new ImageLoader( this.manager );
			loader.setCrossOrigin( this.crossOrigin );

			for ( var i = 0, il = json.length; i < il; i ++ ) {

				var image = json[ i ];
				var url = image.url;

				if ( url is List ) {

					// load array of images e.g CubeTexture

					images[ image.uuid ] = [];

					for ( var j = 0, jl = url.length; j < jl; j ++ ) {

						var currentUrl = url[ j ];

						var deserializedImage = await deserializeImage( currentUrl );

						if ( deserializedImage != null ) {

              print(" ObjectLoader TODO deserializedImage ");

							// if ( deserializedImage is HTMLImageElement ) {

							// 	images[ image.uuid ].add( deserializedImage );

							// } else {

							// 	// special case: handle array of data textures for cube textures

							// 	images[ image.uuid ].add( new DataTexture( deserializedImage.data, deserializedImage.width, deserializedImage.height ) );

							// }

						}

					}

				} else {

					// load single image

					var deserializedImage = await deserializeImage( image.url );

					if ( deserializedImage != null ) {

						images[ image.uuid ] = deserializedImage;

					}

				}

			}

		}

		return images;

	}

	parseTextures( json, images ) {

		Function parseConstant = ( value, type ) {

			if ( value is num ) return value;

			print( 'THREE.ObjectLoader.parseTexture: Constant should be in numeric form. ${value}' );

			return type[ value ];

		};

		var textures = {};

		if ( json != null ) {

			for ( var i = 0, l = json.length; i < l; i ++ ) {

				var data = json[ i ];

				if ( data.image == null ) {

					print( 'THREE.ObjectLoader: No "image" specified for ${data.uuid}' );

				}

				if ( images[ data.image ] == null ) {

					print( 'THREE.ObjectLoader: Undefined image ${data.image}' );

				}

				var texture;
				var image = images[ data.image ];


        print("1 ObjectLoader Image TODO ");
				// if ( image is List ) {

				// 	texture = new CubeTexture( image );

				// 	if ( image.length == 6 ) texture.needsUpdate = true;

				// } else {

				// 	if ( image && image.data ) {

				// 		texture = new DataTexture( image.data, image.width, image.height );

				// 	} else {

				// 		texture = new Texture( image );

				// 	}

				// 	if ( image ) texture.needsUpdate = true; // textures can have null image data

				// }

				texture.uuid = data.uuid;

				if ( data.name != null ) texture.name = data.name;

				if ( data.mapping != null ) texture.mapping = parseConstant( data.mapping, TEXTURE_MAPPING );

				if ( data.offset != null ) texture.offset.fromArray( data.offset );
				if ( data.repeat != null ) texture.repeat.fromArray( data.repeat );
				if ( data.center != null ) texture.center.fromArray( data.center );
				if ( data.rotation != null ) texture.rotation = data.rotation;

				if ( data.wrap != null ) {

					texture.wrapS = parseConstant( data.wrap[ 0 ], TEXTURE_WRAPPING );
					texture.wrapT = parseConstant( data.wrap[ 1 ], TEXTURE_WRAPPING );

				}

				if ( data.format != null ) texture.format = data.format;
				if ( data.type != null ) texture.type = data.type;
				if ( data.encoding != null ) texture.encoding = data.encoding;

				if ( data.minFilter != null ) texture.minFilter = parseConstant( data.minFilter, TEXTURE_FILTER );
				if ( data.magFilter != null ) texture.magFilter = parseConstant( data.magFilter, TEXTURE_FILTER );
				if ( data.anisotropy != null ) texture.anisotropy = data.anisotropy;

				if ( data.flipY != null ) texture.flipY = data.flipY;

				if ( data.premultiplyAlpha != null ) texture.premultiplyAlpha = data.premultiplyAlpha;
				if ( data.unpackAlignment != null ) texture.unpackAlignment = data.unpackAlignment;

				textures[ data.uuid ] = texture;

			}

		}

		return textures;

	}

	parseObject( Map<String, dynamic> data, geometries, materials, textures, animations ) {

		var object;

		Function getGeometry = ( name ) {

			if ( geometries[ name ] == null ) {

				print( 'THREE.ObjectLoader: Undefined geometry ${name}' );

			}

			return geometries[ name ];

		};

		Function getMaterial = ( name ) {

			if ( name == null ) return null;

			if ( name is List ) {

				var array = [];

				for ( var i = 0, l = name.length; i < l; i ++ ) {

					var uuid = name[ i ];

					if ( materials[ uuid ] == null ) {

						print( 'THREE.ObjectLoader: Undefined material ${uuid}' );

					}

					array.add( materials[ uuid ] );

				}

				return array;

			}

			if ( materials[ name ] == null ) {

				print( 'THREE.ObjectLoader: Undefined material ${name}' );

			}

			return materials[ name ];

		};

		Function getTexture = ( uuid ) {

			if ( textures[ uuid ] == null ) {

				print( 'THREE.ObjectLoader: Undefined texture ${uuid}' );

			}

			return textures[ uuid ];

		};

		var geometry, material;

		switch ( data["type"] ) {

			case 'Scene':

				object = new Scene();

				if ( data["background"] != null ) {

					if ( data["background"] is int ) {

						object.background = Color.fromHex( data["background"] );

					} else {

						object.background = getTexture( data["background"] );

					}

				}

				if ( data["environment"] != null ) {

					object.environment = getTexture( data["environment"] );

				}

				if ( data["fog"] != null ) {

					if ( data["fog"]["type"] == 'Fog' ) {

						object.fog = new Fog( data["fog"]["color"], data["fog"]["near"], data["fog"]["far"] );

					} else if ( data["fog"]["type"] == 'FogExp2' ) {

						object.fog = new FogExp2( data["fog"]["color"], data["fog"]["density"] );

					}

				}

				break;

			case 'PerspectiveCamera':

				object = new PerspectiveCamera( data["fov"], data["aspect"], data["near"], data["far"] );

				if ( data["focus"] != null ) object.focus = data["focus"];
				if ( data["zoom"] != null ) object.zoom = data["zoom"];
				if ( data["filmGauge"] != null ) object.filmGauge = data["filmGauge"];
				if ( data["filmOffset"] != null ) object.filmOffset = data["filmOffset"];
				if ( data["view"] != null ) object.view = convert.jsonDecode( convert.jsonEncode(data["view"]) );

				break;

			case 'OrthographicCamera':

				object = new OrthographicCamera( data["left"], data["right"], data["top"], data["bottom"], data["near"], data["far"] );

				if ( data["zoom"] != null ) object.zoom = data["zoom"];
				if ( data["view"] != null ) object.view = convert.jsonDecode( convert.jsonEncode( data["view"] ) );

				break;

			case 'AmbientLight':
				object = new AmbientLight( data["color"], data["intensity"] );

				break;

			case 'DirectionalLight':

				object = new DirectionalLight( data["color"], data["intensity"] );

				break;

			case 'PointLight':

				object = new PointLight( data["color"], data["intensity"], data["distance"], data["decay"] );

				break;

			case 'RectAreaLight':

				object = new RectAreaLight( data["color"], data["intensity"], data["width"], data["height"] );

				break;

			case 'SpotLight':

				object = new SpotLight( data["color"], data["intensity"], data["distance"], data["angle"], data["penumbra"], data["decay"] );

				break;

			case 'HemisphereLight':

				object = new HemisphereLight( data["color"], data["groundColor"], data["intensity"] );

				break;

			case 'LightProbe':

				object = new LightProbe(null, null).fromJSON( data );

				break;

			case 'SkinnedMesh':

				geometry = getGeometry( data["geometry"] );
			 	material = getMaterial( data["material"] );

				object = new SkinnedMesh( geometry, material );

				if ( data["bindMode"] != null ) object.bindMode = data["bindMode"];
				if ( data["bindMatrix"] != null ) object.bindMatrix.fromArray( data["bindMatrix"] );
				if ( data["skeleton"] != null ) object.skeleton = data["skeleton"];

				break;

			case 'Mesh':

				geometry = getGeometry( data["geometry"] );
				material = getMaterial( data["material"] );

				object = new Mesh( geometry, material );

				break;

			case 'InstancedMesh':

				geometry = getGeometry( data["geometry"] );
				material = getMaterial( data["material"] );
				var count = data["count"];
				var instanceMatrix = data["instanceMatrix"];
				var instanceColor = data["instanceColor"];

				object = new InstancedMesh( geometry, material, count );
				object.instanceMatrix = new InstancedBufferAttribute( new Float32Array( instanceMatrix.array ), 16, false );
				if ( instanceColor != null ) object.instanceColor = new InstancedBufferAttribute( new Float32Array( instanceColor.array ), instanceColor.itemSize, false );

				break;

			// case 'LOD':

			// 	object = new LOD();

			// 	break;

			case 'Line':

				object = new Line( getGeometry( data["geometry"] ), getMaterial( data["material"] ) );

				break;

			case 'LineLoop':

				object = new LineLoop( getGeometry( data["geometry"] ), getMaterial( data["material"] ) );

				break;

			case 'LineSegments':

				object = new LineSegments( getGeometry( data["geometry"] ), getMaterial( data["material"] ) );

				break;

			case 'PointCloud':
			case 'Points':

				object = new Points( getGeometry( data["geometry"] ), getMaterial( data["material"] ) );

				break;

			case 'Sprite':

				object = new Sprite( getMaterial( data["material"] ) );

				break;

			case 'Group':

				object = new Group();

				break;

			case 'Bone':

				object = new Bone();

				break;

			default:

				object = new Object3D();

		}

		object.uuid = data["uuid"];

		if ( data["name"] != null ) object.name = data["name"];

		if ( data["matrix"] != null ) {

			object.matrix.fromArray( data["matrix"] );

			if ( data["matrixAutoUpdate"] != null ) object.matrixAutoUpdate = data["matrixAutoUpdate"];
			if ( object.matrixAutoUpdate ) object.matrix.decompose( object.position, object.quaternion, object.scale );

		} else {

			if ( data["position"] != null ) object.position.fromArray( data["position"] );
			if ( data["rotation"] != null ) object.rotation.fromArray( data["rotation"] );
			if ( data["quaternion"] != null ) object.quaternion.fromArray( data["quaternion"] );
			if ( data["scale"] != null ) object.scale.fromArray( data["scale"] );

		}

		if ( data["castShadow"] != null ) object.castShadow = data["castShadow"];
		if ( data["receiveShadow"] != null ) object.receiveShadow = data["receiveShadow"];

		if ( data["shadow"] != null ) {

			if ( data["shadow"]["bias"] != null ) object.shadow.bias = data["shadow"]["bias"];
			if ( data["shadow"]["normalBias"] != null ) object.shadow.normalBias = data["shadow"]["normalBias"];
			if ( data["shadow"]["radius"] != null ) object.shadow.radius = data["shadow"]["radius"];
			if ( data["shadow"]["mapSize"] != null ) object.shadow.mapSize.fromArray( data["shadow"]["mapSize"] );
			if ( data["shadow"]["camera"] != null ) object.shadow.camera = this.parseObject( data["shadow"]["camera"], null, null, null, null );

		}

		if ( data["visible"] != null ) object.visible = data["visible"];
		if ( data["frustumCulled"] != null ) object.frustumCulled = data["frustumCulled"];
		if ( data["renderOrder"] != null ) object.renderOrder = data["renderOrder"];
		if ( data["userData"] != null ) object.userData = data["userData"];
		if ( data["layers"] != null ) object.layers.mask = data["layers"];

		if ( data["children"] != null ) {

			var children = data["children"];

			for ( var i = 0; i < children.length; i ++ ) {

				object.add( this.parseObject( children[ i ], geometries, materials, textures, animations ) );

			}

		}

		if ( data["animations"] != null ) {

			var objectAnimations = data["animations"];

			for ( var i = 0; i < objectAnimations.length; i ++ ) {

				var uuid = objectAnimations[ i ];

				object.animations.push( animations[ uuid ] );

			}

		}

		if ( data["type"] == 'LOD' ) {

			if ( data["autoUpdate"] != null ) object.autoUpdate = data["autoUpdate"];

			var levels = data["levels"];

			for ( var l = 0; l < levels.length; l ++ ) {

				var level = levels[ l ];
				var child = object.getObjectByProperty( 'uuid', level.object );

				if ( child != null ) {

					object.addLevel( child, level.distance );

				}

			}

		}

		return object;

	}

	bindSkeletons( object, skeletons ) {

		if ( skeletons.keys.length == 0 ) return;

		object.traverse( ( child ) {

			if ( child.isSkinnedMesh == true && child.skeleton != null ) {

				var skeleton = skeletons[ child.skeleton ];

				if ( skeleton == null ) {

					print( 'THREE.ObjectLoader: No skeleton found with UUID: ${child.skeleton}' );

				} else {

					child.bind( skeleton, child.bindMatrix );

				}

			}

		} );

	}

	/* DEPRECATED */

	setTexturePath( value ) {

		print( 'THREE.ObjectLoader: .setTexturePath() has been renamed to .setResourcePath().' );
		return this.setResourcePath( value );

	}

}

var TEXTURE_MAPPING = {
	"UVMapping": UVMapping,
	"CubeReflectionMapping": CubeReflectionMapping,
	"CubeRefractionMapping": CubeRefractionMapping,
	"EquirectangularReflectionMapping": EquirectangularReflectionMapping,
	"EquirectangularRefractionMapping": EquirectangularRefractionMapping,
	"CubeUVReflectionMapping": CubeUVReflectionMapping,
	"CubeUVRefractionMapping": CubeUVRefractionMapping
};

var TEXTURE_WRAPPING = {
	"RepeatWrapping": RepeatWrapping,
	"ClampToEdgeWrapping": ClampToEdgeWrapping,
	"MirroredRepeatWrapping": MirroredRepeatWrapping
};

var TEXTURE_FILTER = {
	"NearestFilter": NearestFilter,
	"NearestMipmapNearestFilter": NearestMipmapNearestFilter,
	"NearestMipmapLinearFilter": NearestMipmapLinearFilter,
	"LinearFilter": LinearFilter,
	"LinearMipmapNearestFilter": LinearMipmapNearestFilter,
	"LinearMipmapLinearFilter": LinearMipmapLinearFilter
};
