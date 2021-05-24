part of three_webgl;





class WebGLShadowMap {

  Frustum _frustum = Frustum(null, null,null, null,null, null);
  var _shadowMapSize = new Vector2(null, null);
  var _viewportSize = new Vector2(null, null);
  var _viewport = new Vector4.init();

  var shadowSide = { 0: BackSide, 1: FrontSide, 2: DoubleSide };

  HashMap<int, Material> _depthMaterials = HashMap<int, Material>();
  HashMap<int, Material> _distanceMaterials = HashMap<int, Material>();
  var _materialCache = {};

  late ShaderMaterial shadowMaterialVertical;
  late ShaderMaterial shadowMaterialHorizontal;
	

	BufferGeometry fullScreenTri = BufferGeometry();
	

	late Mesh fullScreenMesh;

	bool enabled = false;

	bool autoUpdate = true;
	bool needsUpdate = false;

  // int type = 0;
	int type = PCFShadowMap;
  // int type = PCFSoftShadowMap;

  late WebGLShadowMap scope;

  WebGLRenderer _renderer;
  WebGLObjects _objects;
  num maxTextureSize;

  WebGLShadowMap(this._renderer, this._objects, this.maxTextureSize ) {

    shadowMaterialVertical = ShaderMaterial( {

      "defines": {
        "SAMPLE_RATE": 2.0 / 8.0,
        "HALF_SAMPLE_RATE": 1.0 / 8.0
      },

      "uniforms": {
        "shadow_pass": { "value": null },
        "resolution": { "value": new Vector2(null, null) },
        "radius": { "value": 4.0 }
      },

      "vertexShader": vsm_vert,

      "fragmentShader": vsm_frag

    } );


    fullScreenTri.setAttribute(
      'position',
      BufferAttribute(
        [ - 1, - 1, 0.5, 3, - 1, 0.5, - 1, 3, 0.5 ],
        3,
        false
      )
    );
    
    fullScreenMesh = new Mesh( fullScreenTri, shadowMaterialVertical );

    shadowMaterialHorizontal = shadowMaterialVertical.clone();
    shadowMaterialHorizontal.defines!["HORIZONTAL_PASS"] = 1;

    scope = this;
  }


	render(List<Light> lights, scene, Camera camera ) {

 
		if ( scope.enabled == false ) return;
		if ( scope.autoUpdate == false && scope.needsUpdate == false ) return;

		if ( lights.length == 0 ) return;

		var currentRenderTarget = _renderer.getRenderTarget();
		var activeCubeFace = _renderer.getActiveCubeFace();
		var activeMipmapLevel = _renderer.getActiveMipmapLevel();


		var _state = _renderer.state;

		// Set GL state for depth map.
		_state.setBlending( NoBlending, null, null, null, null, null, null, null );
		_state.buffers["color"].setClear( 1, 1, 1, 1, false );
		_state.buffers["depth"].setTest( true );
		_state.setScissorTest( false );

		// render depth map

		for ( var i = 0, il = lights.length; i < il; i ++ ) {

			var light = lights[ i ];
			var shadow = light.shadow;

			if ( shadow == null ) {

				print( 'THREE.WebGLShadowMap: ${light} has no shadow.' );
				continue;

			}

			if ( shadow.autoUpdate == false && shadow.needsUpdate == false ) continue;

			_shadowMapSize.copy( shadow.mapSize );

			var shadowFrameExtents = shadow.getFrameExtents();
			_shadowMapSize.multiply( shadowFrameExtents );
			_viewportSize.copy( shadow.mapSize );

			if ( _shadowMapSize.x > maxTextureSize || _shadowMapSize.y > maxTextureSize ) {

				if ( _shadowMapSize.x > maxTextureSize ) {

					_viewportSize.x = Math.floor( maxTextureSize / shadowFrameExtents.x ).toDouble();
					_shadowMapSize.x = _viewportSize.x * shadowFrameExtents.x;
					shadow.mapSize.x = _viewportSize.x;

				}

				if ( _shadowMapSize.y > maxTextureSize ) {

					_viewportSize.y = Math.floor( maxTextureSize / shadowFrameExtents.y ).toDouble();
					_shadowMapSize.y = _viewportSize.y * shadowFrameExtents.y;
					shadow.mapSize.y = _viewportSize.y;

				}

			}

			if ( shadow.map == null && ! shadow.isPointLightShadow && this.type == VSMShadowMap ) {

				var pars = WebGLRenderTargetOptions({ "minFilter": LinearFilter, "magFilter": LinearFilter, "format": RGBAFormat });

				shadow.map = WebGLRenderTarget( _shadowMapSize.x.toInt(), _shadowMapSize.y.toInt(), pars );
				shadow.map!.texture.name = light.name + '.shadowMap';

				shadow.mapPass = WebGLRenderTarget( _shadowMapSize.x.toInt(), _shadowMapSize.y.toInt(), pars );

				shadow.camera!.updateProjectionMatrix();

			}

			if ( shadow.map == null ) {

				var pars = WebGLRenderTargetOptions({ "minFilter": NearestFilter, "magFilter": NearestFilter, "format": RGBAFormat });

				shadow.map = WebGLRenderTarget( _shadowMapSize.x.toInt(), _shadowMapSize.y.toInt(), pars );
				shadow.map!.texture.name = light.name + '.shadowMap';

				shadow.camera!.updateProjectionMatrix();

			}

			_renderer.setRenderTarget( shadow.map );
			_renderer.clear(null, null, null);

			var viewportCount = shadow.getViewportCount();

			for ( var vp = 0; vp < viewportCount; vp ++ ) {

				var viewport = shadow.getViewport( vp );

				_viewport.set(
					_viewportSize.x * viewport.x,
					_viewportSize.y * viewport.y,
					_viewportSize.x * viewport.z,
					_viewportSize.y * viewport.w
				);


				_state.viewport( _viewport );

				shadow.updateMatrices( light, viewportIndex: vp );

				_frustum = shadow.getFrustum();

 
				renderObject( scene, camera, shadow.camera, light, this.type );

			}

			// do blur pass for VSM

			if ( ! shadow.isPointLightShadow && this.type == VSMShadowMap ) {

				VSMPass( shadow, camera );

			}

			shadow.needsUpdate = false;

		}

		scope.needsUpdate = false;


		_renderer.setRenderTarget( currentRenderTarget, activeCubeFace: activeCubeFace, activeMipmapLevel: activeMipmapLevel );

	}


	VSMPass( shadow, camera ) {

		var geometry = _objects.update( fullScreenMesh );

		// vertical pass

		shadowMaterialVertical.uniforms!["shadow_pass"].value = shadow.map.texture;
		shadowMaterialVertical.uniforms!["resolution"].value = shadow.mapSize;
		shadowMaterialVertical.uniforms!["radius"].value = shadow.radius;
		_renderer.setRenderTarget( shadow.mapPass );
		_renderer.clear(null, null, null);
		_renderer.renderBufferDirect( camera, null, geometry, shadowMaterialVertical, fullScreenMesh, null );

		// horizontal pass

		shadowMaterialHorizontal.uniforms!["shadow_pass"].value = shadow.mapPass.texture;
		shadowMaterialHorizontal.uniforms!["resolution"].value = shadow.mapSize;
		shadowMaterialHorizontal.uniforms!["radius"].value = shadow.radius;
		_renderer.setRenderTarget( shadow.map );
		_renderer.clear(null, null, null);
		_renderer.renderBufferDirect( camera, null, geometry, shadowMaterialHorizontal, fullScreenMesh, null );

	}

	Material getDepthMaterialVariant( bool useMorphing, bool useSkinning, bool useInstancing ) {

  
		int index = (useMorphing ? 1 : 0) << 0 | (useSkinning ? 1 : 0) << 1 | (useInstancing ? 1 : 0) << 2;


		Material? material = _depthMaterials[ index ];

 
		if ( material == null ) {

    
			material = MeshDepthMaterial( {

				"depthPacking": RGBADepthPacking,

				"morphTargets": useMorphing,
				"skinning": useSkinning

			} );

     
			_depthMaterials[ index ] = material;

		}

  
		return material;

	}

	Material getDistanceMaterialVariant( bool useMorphing, bool useSkinning, bool useInstancing ) {

		var index = (useMorphing ? 1 : 0) << 0 | (useSkinning ? 1 : 0) << 1 | (useInstancing ? 1 : 0) << 2;

		var material = _distanceMaterials[ index ];

		if ( material == null ) {

			material = MeshDistanceMaterial( {

				"morphTargets": useMorphing,
				"skinning": useSkinning

			} );

			_distanceMaterials[ index ] = material;

		}

		return material;

	}

	getDepthMaterial( object, geometry, material, light, shadowCameraNear, shadowCameraFar, type ) {

		Material? result = null;

		var getMaterialVariant = getDepthMaterialVariant;
		var customMaterial = object.customDepthMaterial;

		if ( light.isPointLight == true ) {

			getMaterialVariant = getDistanceMaterialVariant;
			customMaterial = object.customDistanceMaterial;

		}

		if ( customMaterial == null ) {

			var useMorphing = false;

			if ( material.morphTargets == true ) {

				useMorphing = geometry.morphAttributes && geometry.morphAttributes.position && geometry.morphAttributes.position.length > 0;

			}

			var useSkinning = false;

			if ( object.isSkinnedMesh == true ) {

				if ( material.skinning == true ) {

					useSkinning = true;

				} else {

					print( 'THREE.WebGLShadowMap: THREE.SkinnedMesh with material.skinning set to false: ${object}' );

				}

			}

			var useInstancing = object.isInstancedMesh == true;

			result = getMaterialVariant( useMorphing, useSkinning, useInstancing );

		} else {

			result = customMaterial;

		}

		if ( _renderer.localClippingEnabled &&
				material.clipShadows == true &&
				material.clippingPlanes.length != 0 ) {

			// in this case we need a unique material instance reflecting the
			// appropriate state

			var keyA = result!.uuid;
      var keyB = material.uuid;

			var materialsForVariant = _materialCache[ keyA ];

			if ( materialsForVariant == null ) {

				materialsForVariant = {};
				_materialCache[ keyA ] = materialsForVariant;

			}

			var cachedMaterial = materialsForVariant[ keyB ];

			if ( cachedMaterial == null ) {

				cachedMaterial = result.clone();
				materialsForVariant[ keyB ] = cachedMaterial;

			}

			result = cachedMaterial;

		}

		result!.visible = material.visible;
		result.wireframe = material.wireframe;

		if ( type == VSMShadowMap ) {

			result.side = ( material.shadowSide != null ) ? material.shadowSide : material.side;

		} else {

			result.side = ( material.shadowSide != null ) ? material.shadowSide : shadowSide[ material.side ];

		}

		result.clipShadows = material.clipShadows;
		result.clippingPlanes = material.clippingPlanes;
		result.clipIntersection = material.clipIntersection;

		result.wireframeLinewidth = material.wireframeLinewidth;
		result.linewidth = material.linewidth;

		if ( light.isPointLight == true && result.isMeshDistanceMaterial ) {

      MeshDistanceMaterial result2 = result as MeshDistanceMaterial;

			result2.referencePosition.setFromMatrixPosition( light.matrixWorld );
			result2.nearDistance = shadowCameraNear;
			result2.farDistance = shadowCameraFar;

      return result2;
		} else {
		  return result;
    }

	}

	renderObject( object, camera, shadowCamera, light, type ) {

 
		if ( object.visible == false ) return;

		var visible = object.layers.test( camera.layers );

		if ( visible && ( object.isMesh || object.isLine || object.isPoints ) ) {

			if ( ( object.castShadow || ( object.receiveShadow && type == VSMShadowMap ) ) && ( ! object.frustumCulled || _frustum.intersectsObject( object ) ) ) {

				object.modelViewMatrix.multiplyMatrices( shadowCamera.matrixWorldInverse, object.matrixWorld );
     
				var geometry = _objects.update( object );
				var material = object.material;


        if ( material.visible ) {
					var depthMaterial = getDepthMaterial( object, geometry, material, light, shadowCamera.near, shadowCamera.far, type );
					_renderer.renderBufferDirect( shadowCamera, null, geometry, depthMaterial, object, null );
				}

				// if ( material is List ) {

				// 	var groups = geometry.groups;

				// 	for ( var k = 0, kl = groups.length; k < kl; k ++ ) {

				// 		var group = groups[ k ];
				// 		var groupMaterial = material[ group.materialIndex ];

				// 		if ( groupMaterial && groupMaterial.visible ) {

				// 			var depthMaterial = getDepthMaterial( object, geometry, groupMaterial, light, shadowCamera.near, shadowCamera.far, type );

				// 			_renderer.renderBufferDirect( shadowCamera, null, geometry, depthMaterial, object, group );

				// 		}

				// 	}

				// } else if ( material.visible ) {

				// 	var depthMaterial = getDepthMaterial( object, geometry, material, light, shadowCamera.near, shadowCamera.far, type );

				// 	_renderer.renderBufferDirect( shadowCamera, null, geometry, depthMaterial, object, null );

				// }

			}

		}

		var children = object.children;

		for ( var i = 0, l = children.length; i < l; i ++ ) {

			renderObject( children[ i ], camera, shadowCamera, light, type );

		}

	}

}

