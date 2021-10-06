part of three_loaders;


class MaterialLoader extends Loader {

  late Map textures;

	MaterialLoader( manager ) : super( manager ) {
		this.textures = {};
	}

	load( url, onLoad, onProgress, onError ) {

		var scope = this;

		var loader = new FileLoader( scope.manager );
		loader.setPath( scope.path );
		loader.setRequestHeader( scope.requestHeader );
		loader.setWithCredentials( scope.withCredentials );
		loader.load( url, ( text ) {

			try {

				onLoad!( scope.parse( convert.jsonDecode( text ) ) );

			} catch ( e ) {

				if ( onError != null ) {

					onError( e );

				} else {

					print( e );

				}

				scope.manager.itemError( url );

			}

		}, onProgress, onError );

	}

	parse( json, {String? path, Function? onLoad, Function? onError} ) {

		var textures = this.textures;

		Function getTexture = ( name ) {

			if ( textures[ name ] == null ) {

				print( 'THREE.MaterialLoader: Undefined texture ${name}' );

			}

			return textures[ name ];

		};

    var material;

    if(json["type"] == "MeshBasicMaterial") {
      material = MeshBasicMaterial();
    } else if(json["type"] == "MeshLambertMaterial") {
      material = MeshLambertMaterial();
    } else if(json["type"] == "MeshPhongMaterial") {
      material = MeshPhongMaterial();
    } else if(json["type"] == "MeshMatcapMaterial") {
      material = MeshMatcapMaterial();  
    } else {
      throw(" MaterialLoader ${json["type"]} is not support  ");
    }

		// var material = new Materials[ json.type ]();

		if ( json["uuid"] != null ) material.uuid = json["uuid"];
		if ( json["name"] != null ) material.name = json["name"];
		if ( json["color"] != null && material.color != null ) material.color.setHex( json["color"] );
		if ( json["roughness"] != null ) material.roughness = json["roughness"];
		if ( json["metalness"] != null ) material.metalness = json["metalness"];
		if ( json["sheen"] != null ) material.sheen = json["sheen"];
		if ( json["sheenTint"] != null ) material.sheenTint = new Color(0,0,0).setHex( json["sheenTint"] );
		if ( json["sheenRoughness"] != null ) material.sheenRoughness = json["sheenRoughness"];
		if ( json["emissive"] != null && material.emissive != null ) material.emissive.setHex( json["emissive"] );
		if ( json["specular"] != null && material.specular != null ) material.specular.setHex( json["specular"] );
		if ( json["specularIntensity"] != null ) material.specularIntensity = json["specularIntensity"];
		if ( json["specularTint"] != null && material.specularTint != null ) material.specularTint.setHex( json["specularTint"] );
		if ( json["shininess"] != null ) material.shininess = json["shininess"];
		if ( json["clearcoat"] != null ) material.clearcoat = json["clearcoat"];
		if ( json["clearcoatRoughness"] != null ) material.clearcoatRoughness = json["clearcoatRoughness"];
		if ( json["transmission"] != null ) material.transmission = json["transmission"];
		if ( json["thickness"] != null ) material.thickness = json["thickness"];
		if ( json["attenuationDistance"] != null ) material.attenuationDistance = json["attenuationDistance"];
		if ( json["attenuationTint"] != null && material.attenuationTint != null ) material.attenuationTint.setHex( json["attenuationTint"] );
		if ( json["fog"] != null ) material.fog = json["fog"];
		if ( json["flatShading"] != null ) material.flatShading = json["flatShading"];
		if ( json["blending"] != null ) material.blending = json["blending"];
		if ( json["combine"] != null ) material.combine = json["combine"];
		if ( json["side"] != null ) material.side = json["side"];
		if ( json["shadowSide"] != null ) material.shadowSide = json["shadowSide"];
		if ( json["opacity"] != null ) material.opacity = json["opacity"];
		if ( json["format"] != null ) material.format = json["format"];
		if ( json["transparent"] != null ) material.transparent = json["transparent"];
		if ( json["alphaTest"] != null ) material.alphaTest = json["alphaTest"];
		if ( json["depthTest"] != null ) material.depthTest = json["depthTest"];
		if ( json["depthWrite"] != null ) material.depthWrite = json["depthWrite"];
		if ( json["colorWrite"] != null ) material.colorWrite = json["colorWrite"];

		if ( json["stencilWrite"] != null ) material.stencilWrite = json["stencilWrite"];
		if ( json["stencilWriteMask"] != null ) material.stencilWriteMask = json["stencilWriteMask"];
		if ( json["stencilFunc"] != null ) material.stencilFunc = json["stencilFunc"];
		if ( json["stencilRef"] != null ) material.stencilRef = json["stencilRef"];
		if ( json["stencilFuncMask"] != null ) material.stencilFuncMask = json["stencilFuncMask"];
		if ( json["stencilFail"] != null ) material.stencilFail = json["stencilFail"];
		if ( json["stencilZFail"] != null ) material.stencilZFail = json["stencilZFail"];
		if ( json["stencilZPass"] != null ) material.stencilZPass = json["stencilZPass"];

		if ( json["wireframe"] != null ) material.wireframe = json["wireframe"];
		if ( json["wireframeLinewidth"] != null ) material.wireframeLinewidth = json["wireframeLinewidth"];
		if ( json["wireframeLinecap"] != null ) material.wireframeLinecap = json["wireframeLinecap"];
		if ( json["wireframeLinejoin"] != null ) material.wireframeLinejoin = json["wireframeLinejoin"];

		if ( json["rotation"] != null ) material.rotation = json["rotation"];

		if ( json["linewidth"] != 1 ) material.linewidth = json["linewidth"];
		if ( json["dashSize"] != null ) material.dashSize = json["dashSize"];
		if ( json["gapSize"] != null ) material.gapSize = json["gapSize"];
		if ( json["scale"] != null ) material.scale = json["scale"];

		if ( json["polygonOffset"] != null ) material.polygonOffset = json["polygonOffset"];
		if ( json["polygonOffsetFactor"] != null ) material.polygonOffsetFactor = json["polygonOffsetFactor"];
		if ( json["polygonOffsetUnits"] != null ) material.polygonOffsetUnits = json["polygonOffsetUnits"];

		if ( json["dithering"] != null ) material.dithering = json["dithering"];

		if ( json["alphaToCoverage"] != null ) material.alphaToCoverage = json["alphaToCoverage"];
		if ( json["premultipliedAlpha"] != null ) material.premultipliedAlpha = json["premultipliedAlpha"];

		if ( json["visible"] != null ) material.visible = json["visible"];

		if ( json["toneMapped"] != null ) material.toneMapped = json["toneMapped"];

		if ( json["userData"] != null ) material.userData = json["userData"];

		if ( json["vertexColors"] != null ) {

			if ( json["vertexColors"] is num ) {

				material.vertexColors = ( json["vertexColors"] > 0 ) ? true : false;

			} else {

				material.vertexColors = json["vertexColors"];

			}

		}

		// Shader Material

		if ( json["uniforms"] != null ) {

			for ( var name in json["uniforms"] ) {

				var uniform = json["uniforms"][ name ];

				material.uniforms[ name ] = {};

				switch ( uniform.type ) {

					case 't':
						material.uniforms[ name ].value = getTexture( uniform.value );
						break;

					case 'c':
						material.uniforms[ name ].value = new Color(0, 0, 0).setHex( uniform.value );
						break;

					case 'v2':
						material.uniforms[ name ].value = new Vector2(0, 0).fromArray( uniform.value );
						break;

					case 'v3':
						material.uniforms[ name ].value = new Vector3(0, 0, 0 ).fromArray( uniform.value );
						break;

					case 'v4':
						material.uniforms[ name ].value = new Vector4(0,0,0,0).fromArray( uniform.value );
						break;

					case 'm3':
						material.uniforms[ name ].value = new Matrix3().fromArray( uniform.value );
						break;

					case 'm4':
						material.uniforms[ name ].value = new Matrix4().fromArray( uniform.value );
						break;

					default:
						material.uniforms[ name ].value = uniform.value;

				}

			}

		}

		if ( json["defines"] != null ) material.defines = json["defines"];
		if ( json["vertexShader"] != null ) material.vertexShader = json["vertexShader"];
		if ( json["fragmentShader"] != null ) material.fragmentShader = json["fragmentShader"];

		if ( json["extensions"] != null ) {

			for ( var key in json["extensions"] ) {

				material.extensions[ key ] = json["extensions"][ key ];

			}

		}

		// Deprecated

		if ( json["shading"] != null ) material.flatShading = json["shading"] == 1; // THREE.FlatShading

		// for PointsMaterial

		if ( json["size"] != null ) material.size = json["size"];
		if ( json["sizeAttenuation"] != null ) material.sizeAttenuation = json["sizeAttenuation"];

		// maps

		if ( json["map"] != null ) material.map = getTexture( json["map"] );
		if ( json["matcap"] != null ) material.matcap = getTexture( json["matcap"] );

		if ( json["alphaMap"] != null ) material.alphaMap = getTexture( json["alphaMap"] );

		if ( json["bumpMap"] != null ) material.bumpMap = getTexture( json["bumpMap"] );
		if ( json["bumpScale"] != null ) material.bumpScale = json["bumpScale"];

		if ( json["normalMap"] != null ) material.normalMap = getTexture( json["normalMap"] );
		if ( json["normalMapType"] != null ) material.normalMapType = json["normalMapType"];
		if ( json["normalScale"] != null ) {

			var normalScale = json["normalScale"];

			if ( !(normalScale is List) ) {

				// Blender exporter used to export a scalar. See #7459

				normalScale = [ normalScale, normalScale ];

			}

			material.normalScale = new Vector2(0, 0 ).fromArray( normalScale );

		}

		if ( json["displacementMap"] != null ) material.displacementMap = getTexture( json["displacementMap"] );
		if ( json["displacementScale"] != null ) material.displacementScale = json["displacementScale"];
		if ( json["displacementBias"] != null ) material.displacementBias = json["displacementBias"];

		if ( json["roughnessMap"] != null ) material.roughnessMap = getTexture( json["roughnessMap"] );
		if ( json["metalnessMap"] != null ) material.metalnessMap = getTexture( json["metalnessMap"] );

		if ( json["emissiveMap"] != null ) material.emissiveMap = getTexture( json["emissiveMap"] );
		if ( json["emissiveIntensity"] != null ) material.emissiveIntensity = json["emissiveIntensity"];

		if ( json["specularMap"] != null ) material.specularMap = getTexture( json["specularMap"] );
		if ( json["specularIntensityMap"] != null ) material.specularIntensityMap = getTexture( json["specularIntensityMap"] );
		if ( json["specularTintMap"] != null ) material.specularTintMap = getTexture( json["specularTintMap"] );

		if ( json["envMap"] != null ) material.envMap = getTexture( json["envMap"] );
		if ( json["envMapIntensity"] != null ) material.envMapIntensity = json["envMapIntensity"];

		if ( json["reflectivity"] != null ) material.reflectivity = json["reflectivity"];
		if ( json["refractionRatio"] != null ) material.refractionRatio = json["refractionRatio"];

		if ( json["lightMap"] != null ) material.lightMap = getTexture( json["lightMap"] );
		if ( json["lightMapIntensity"] != null ) material.lightMapIntensity = json["lightMapIntensity"];

		if ( json["aoMap"] != null ) material.aoMap = getTexture( json["aoMap"] );
		if ( json["aoMapIntensity"] != null ) material.aoMapIntensity = json["aoMapIntensity"];

		if ( json["gradientMap"] != null ) material.gradientMap = getTexture( json["gradientMap"] );

		if ( json["clearcoatMap"] != null ) material.clearcoatMap = getTexture( json["clearcoatMap"] );
		if ( json["clearcoatRoughnessMap"] != null ) material.clearcoatRoughnessMap = getTexture( json["clearcoatRoughnessMap"] );
		if ( json["clearcoatNormalMap"] != null ) material.clearcoatNormalMap = getTexture( json["clearcoatNormalMap"] );
		if ( json["clearcoatNormalScale"] != null ) material.clearcoatNormalScale = new Vector2(0, 0).fromArray( json["clearcoatNormalScale"] );

		if ( json["transmissionMap"] != null ) material.transmissionMap = getTexture( json["transmissionMap"] );
		if ( json["thicknessMap"] != null ) material.thicknessMap = getTexture( json["thicknessMap"] );

		return material;

	}

	setTextures( value ) {

		this.textures = value;
		return this;

	}

}
