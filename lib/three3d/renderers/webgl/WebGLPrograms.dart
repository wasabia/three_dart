part of three_webgl;

class WebGLPrograms {

  var shaderIDs = {
		"MeshDepthMaterial": 'depth',
		"MeshDistanceMaterial": 'distanceRGBA',
		"MeshNormalMaterial": 'normal',
		"MeshBasicMaterial": 'basic',
		"MeshLambertMaterial": 'lambert',
		"MeshPhongMaterial": 'phong',
		"MeshToonMaterial": 'toon',
		"MeshStandardMaterial": 'physical',
		"MeshPhysicalMaterial": 'physical',
		"MeshMatcapMaterial": 'matcap',
		"LineBasicMaterial": 'basic',
		"LineDashedMaterial": 'dashed',
		"PointsMaterial": 'points',
		"ShadowMaterial": 'shadow',
		"SpriteMaterial": 'sprite'
	};

	var parameterNames = [
		'precision', 'isWebGL2', 'supportsVertexTextures', 'outputEncoding', 'instancing', 'instancingColor',
		'map', 'mapEncoding', 'matcap', 'matcapEncoding', 'envMap', 'envMapMode', 'envMapEncoding', 'envMapCubeUV',
		'lightMap', 'lightMapEncoding', 'aoMap', 'emissiveMap', 'emissiveMapEncoding', 'bumpMap', 'normalMap', 'objectSpaceNormalMap', 'tangentSpaceNormalMap', 'clearcoatMap', 'clearcoatRoughnessMap', 'clearcoatNormalMap', 'displacementMap', 'specularMap',
		'roughnessMap', 'metalnessMap', 'gradientMap',
		'alphaMap', 'combine', 'vertexColors', 'vertexTangents', 'vertexUvs', 'uvsVertexOnly', 'fog', 'useFog', 'fogExp2',
		'flatShading', 'sizeAttenuation', 'logarithmicDepthBuffer', 'skinning',
		'maxBones', 'useVertexTexture', 'morphTargets', 'morphNormals',
		'maxMorphTargets', 'maxMorphNormals', 'premultipliedAlpha',
		'numDirLights', 'numPointLights', 'numSpotLights', 'numHemiLights', 'numRectAreaLights',
		'numDirLightShadows', 'numPointLightShadows', 'numSpotLightShadows',
		'shadowMapEnabled', 'shadowMapType', 'toneMapping', 'physicallyCorrectLights',
		'alphaTest', 'doubleSided', 'flipSided', 'numClippingPlanes', 'numClipIntersection', 'depthPacking', 'dithering',
		'sheen', 'transmissionMap'
	];

  WebGLRenderer renderer;
  WebGLCubeMaps cubemaps;
  WebGLExtensions extensions;
  WebGLCapabilities capabilities;
  WebGLBindingStates bindingStates;
  WebGLClipping clipping;

  List<WebGLProgram> programs = [];
  bool isWebGL2 = true;

  late bool logarithmicDepthBuffer;
  late bool floatVertexTextures;
  late int maxVertexUniforms;
  late bool vertexTextures;
  late String precision;

  WebGLPrograms(this.renderer, this.cubemaps, this.extensions, this.capabilities, this.bindingStates, this.clipping ) {
  
    this.isWebGL2 = capabilities.isWebGL2;

	  logarithmicDepthBuffer = capabilities.logarithmicDepthBuffer;
	  floatVertexTextures = capabilities.floatVertexTextures;
    maxVertexUniforms = capabilities.maxVertexUniforms;
    vertexTextures = capabilities.vertexTextures;

    precision = capabilities.precision;
  }

	


	

	getMaxBones( object ) {

		var skeleton = object.skeleton;
		var bones = skeleton.bones;

		if ( floatVertexTextures ) {

			return 1024;

		} else {

			// default for when object is not specified
			// ( for example when prebuilding shader to be used with multiple objects )
			//
			//  - leave some extra space for other uniforms
			//  - limit here is ANGLE's 254 max uniform vectors
			//    (up to 54 should be safe)

			var nVertexUniforms = maxVertexUniforms;
			var nVertexMatrices = Math.floor( ( nVertexUniforms - 20 ) / 4 );

			var maxBones = Math.min( nVertexMatrices, bones.length );

			if ( maxBones < bones.length ) {

				print( 'THREE.WebGLRenderer: Skeleton has ${bones.length} bones. This GPU supports ${maxBones} .' );
				return 0;

			}

			return maxBones;

		}

	}

	getTextureEncodingFromMap( map ) {

		var encoding;

		if ( map != null && map.isTexture ) {

			encoding = map.encoding;

		} else if ( map != null && map.isWebGLRenderTarget ) {

			print( 'THREE.WebGLPrograms.getTextureEncodingFromMap: don\'t use render targets as textures. Use their .texture property instead.' );
			encoding = map.texture.encoding;

		} else {

			encoding = LinearEncoding;

		}

		return encoding;

	}

	WebGLParameters getParameters(Material material, LightState lights, shadows, scene, object ) {

		var fog = scene.fog;
		var environment = material.isMeshStandardMaterial ? scene.environment : null;

		var envMap = cubemaps.get( material.envMap ?? environment );

		var shaderID = shaderIDs[ material.shaderID ];

		// heuristics to create shader parameters according to lights in the scene
		// (not to blow over maxLights budget)

		var maxBones = object.isSkinnedMesh ? getMaxBones( object ) : 0;


		if ( material.precision != null ) {

			precision = capabilities.getMaxPrecision( material.precision );

			if ( precision != material.precision ) {

				print( 'THREE.WebGLProgram.getParameters: ${material.precision} not supported, using ${precision} instead.' );

			}

		}

		var vertexShader, fragmentShader;

		if ( shaderID != null ) {
			var shader = ShaderLib[ shaderID ];
			vertexShader = shader["vertexShader"];
			fragmentShader = shader["fragmentShader"];
		} else {
			vertexShader = material.vertexShader;
			fragmentShader = material.fragmentShader;
		}

    // print(" WebGLPrograms material : ${material.type} ${material.shaderID} ${material.id} object: ${object.type} ${object.id} shaderID: ${shaderID} ");

		var currentRenderTarget = renderer.getRenderTarget();

		var parameters = WebGLParameters({

			"isWebGL2": isWebGL2,

			"shaderID": shaderID,
			"shaderName": material.type,

			"vertexShader": vertexShader,
			"fragmentShader": fragmentShader,
			"defines": material.defines,

			"isRawShaderMaterial": material.isRawShaderMaterial == true,
			"glslVersion": material.glslVersion,

			"precision": precision,

			"instancing": object.isInstancedMesh == true,
			"instancingColor": object.isInstancedMesh == true && object.instanceColor != null,

			"supportsVertexTextures": vertexTextures,
			"outputEncoding": ( currentRenderTarget != null ) ? getTextureEncodingFromMap( currentRenderTarget.texture ) : renderer.outputEncoding,
			"map": material.map != null,
			"mapEncoding": getTextureEncodingFromMap( material.map ),
			"matcap": material.matcap != null,
			"matcapEncoding": getTextureEncodingFromMap( material.matcap ),
			"envMap": envMap != null,
			"envMapMode": envMap != null && envMap.mapping,
			"envMapEncoding": getTextureEncodingFromMap( envMap ),
			"envMapCubeUV": ( envMap != null ) && ( ( envMap.mapping == CubeUVReflectionMapping ) || ( envMap.mapping == CubeUVRefractionMapping ) ),
			"lightMap": material.lightMap != null,
			"lightMapEncoding": getTextureEncodingFromMap( material.lightMap ),
			"aoMap": material.aoMap != null,
			"emissiveMap": material.emissiveMap != null,
			"emissiveMapEncoding": getTextureEncodingFromMap( material.emissiveMap ),
			"bumpMap": material.bumpMap != null,
			"normalMap": material.normalMap != null,
			"objectSpaceNormalMap": material.normalMapType == ObjectSpaceNormalMap,
			"tangentSpaceNormalMap": material.normalMapType == TangentSpaceNormalMap,
			"clearcoatMap": material.clearcoatMap != null,
			"clearcoatRoughnessMap": material.clearcoatRoughnessMap != null,
			"clearcoatNormalMap": material.clearcoatNormalMap != null,
			"displacementMap": material.displacementMap != null,
			"roughnessMap": material.roughnessMap != null,
			"metalnessMap": material.metalnessMap != null,
			"specularMap": material.specularMap != null,
			"alphaMap": material.alphaMap != null,

			"gradientMap": material.gradientMap != null,

			"sheen": material.sheen != null,

			"transmissionMap": material.transmissionMap != null,

			"combine": material.combine,

			"vertexTangents": ( material.normalMap != null && material.vertexTangents),
			"vertexColors": material.vertexColors,
			"vertexUvs":  material.map != null || material.bumpMap != null || material.normalMap != null || material.specularMap != null || material.alphaMap != null || material.emissiveMap != null || material.roughnessMap != null || material.metalnessMap != null || material.clearcoatMap != null || material.clearcoatRoughnessMap != null || material.clearcoatNormalMap != null || material.displacementMap != null || material.transmissionMap != null,
			"uvsVertexOnly": ! ( material.map != null || material.bumpMap != null || material.normalMap != null || material.specularMap != null || material.alphaMap != null || material.emissiveMap != null || material.roughnessMap != null || material.metalnessMap != null || material.clearcoatNormalMap != null || material.transmissionMap != null ) && material.displacementMap != null,

			"fog": fog != null,
			"useFog": material.fog,
			"fogExp2": ( fog != null && fog.isFogExp2 ),

			"flatShading": material.flatShading,

			"sizeAttenuation": material.sizeAttenuation,
			"logarithmicDepthBuffer": logarithmicDepthBuffer,

			"skinning": material.skinning == true && maxBones > 0,
			"maxBones": maxBones,
			"useVertexTexture": floatVertexTextures,

			"morphTargets": material.morphTargets,
			"morphNormals": material.morphNormals,
			"maxMorphTargets": renderer.maxMorphTargets,
			"maxMorphNormals": renderer.maxMorphNormals,

			"numDirLights": lights.directional.length,
			"numPointLights": lights.point.length,
			"numSpotLights": lights.spot.length,
			"numRectAreaLights": lights.rectArea.length,
			"numHemiLights": lights.hemi.length,

			"numDirLightShadows": lights.directionalShadowMap.length,
			"numPointLightShadows": lights.pointShadowMap.length,
			"numSpotLightShadows": lights.spotShadowMap.length,

			"numClippingPlanes": clipping.numPlanes,
			"numClipIntersection": clipping.numIntersection,

			"dithering": material.dithering,

			"shadowMapEnabled": renderer.shadowMap.enabled && shadows.length > 0,
			"shadowMapType": renderer.shadowMap.type,

			"toneMapping": material.toneMapped ? renderer.toneMapping : NoToneMapping,
			"physicallyCorrectLights": renderer.physicallyCorrectLights,

			"premultipliedAlpha": material.premultipliedAlpha,

			"alphaTest": material.alphaTest,
			"doubleSided": material.side == DoubleSide,
			"flipSided": material.side == BackSide,

			"depthPacking": ( material.depthPacking != null ) ? material.depthPacking : 0,

			"index0AttributeName": material.index0AttributeName,

			"extensionDerivatives": material.extensions != null && material.extensions!["derivatives"] != null,
			"extensionFragDepth": material.extensions != null && material.extensions!["fragDepth"] != null,
			"extensionDrawBuffers": material.extensions != null && material.extensions!["drawBuffers"] != null,
			"extensionShaderTextureLOD": material.extensions != null && material.extensions!["shaderTextureLOD"] != null,

			"rendererExtensionFragDepth": isWebGL2 ? isWebGL2 : extensions.has( 'EXT_frag_depth' ),
			"rendererExtensionDrawBuffers": isWebGL2 ? isWebGL2 : extensions.has( 'WEBGL_draw_buffers' ),
			"rendererExtensionShaderTextureLod": isWebGL2 ? isWebGL2 : extensions.has( 'EXT_shader_texture_lod' ),

			"customProgramCacheKey": material.customProgramCacheKey()

		});

		return parameters;

	}

	String getProgramCacheKey( WebGLParameters parameters ) {

		List<String> array = [];

		if ( parameters.shaderID != null ) {

			array.add( parameters.shaderID! );

		} else {

			array.add( parameters.fragmentShader );
			array.add( parameters.vertexShader );

		}

		if ( parameters.defines != null ) {

			for ( var name in parameters.defines!.keys ) {

				array.add( name );
				array.add( parameters.defines![ name ].toString() );

			}

		}

		if ( parameters.isRawShaderMaterial == false ) {

			for ( var i = 0; i < parameterNames.length; i ++ ) {

				array.add( parameters.getValue(parameterNames[ i ]).toString() );

			}

			array.add( renderer.outputEncoding.toString() );
			array.add( renderer.gammaFactor.toString() );

		}

		array.add( parameters.customProgramCacheKey );



    String _key = array.join();

		return _key;

	}

	Map<String, dynamic> getUniforms(Material material ) {

    // print("WebGLPrograms.getUniforms material: ${material.type} ");

		String? shaderID = shaderIDs[ material.shaderID ];
		Map<String, dynamic> uniforms;

 
		if ( shaderID != null ) {
 
			var shader = ShaderLib[ shaderID ];
			uniforms = cloneUniforms( shader["uniforms"] );

		} else {

			uniforms = material.uniforms!;

		}

		return uniforms;

	}

	acquireProgram( WebGLParameters parameters, String cacheKey ) {
		WebGLProgram? program;


		// Check if code has been already compiled
		for ( var p = 0, pl = programs.length; p < pl; p ++ ) {

			var preexistingProgram = programs[ p ];

			if ( preexistingProgram.cacheKey == cacheKey ) {

				program = preexistingProgram;
				++ program.usedTimes;

				break;

			}

		}

		if ( program == null ) {

  
			program = WebGLProgram( renderer, cacheKey, parameters, bindingStates );
			programs.add( program );

		}


		return program;

	}

	releaseProgram( program ) {

		if ( -- program.usedTimes == 0 ) {

			// Remove from unordered set
			var i = programs.indexOf( program );
			programs[ i ] = programs[ programs.length - 1 ];
			programs.removeLast();

			// Free WebGL resources
			program.destroy();

		}

	}

	
}

