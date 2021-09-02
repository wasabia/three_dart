part of three_webgl;

class WebGLMaterials {

  WebGLProperties properties;

  WebGLMaterials( this.properties ) {
  }


	refreshFogUniforms( uniforms, fog ) {

		uniforms["fogColor"]["value"].copy( fog.color );

		if ( fog.isFog ) {

			uniforms["fogNear"]["value"] = fog.near;
			uniforms["fogFar"]["value"] = fog.far;

		} else if ( fog.isFogExp2 ) {

			uniforms["fogDensity"]["value"] = fog.density;

		}

	}

  refreshMaterialUniforms( uniforms, Material material, pixelRatio, height, transmissionRenderTarget ) {

		if ( material.isMeshBasicMaterial ) {

			refreshUniformsCommon( uniforms, material );

		} else if ( material.isMeshLambertMaterial ) {

			refreshUniformsCommon( uniforms, material );
			refreshUniformsLambert( uniforms, material );

		} else if ( material.isMeshToonMaterial ) {

			refreshUniformsCommon( uniforms, material );
			refreshUniformsToon( uniforms, material );

		} else if ( material.isMeshPhongMaterial ) {

			refreshUniformsCommon( uniforms, material );
			refreshUniformsPhong( uniforms, material );

		} else if ( material.isMeshStandardMaterial ) {

			refreshUniformsCommon( uniforms, material );

			if ( material.isMeshPhysicalMaterial ) {

				refreshUniformsPhysical( uniforms, material, transmissionRenderTarget );

			} else {

				refreshUniformsStandard( uniforms, material );

			}

		} else if ( material.isMeshMatcapMaterial ) {

			refreshUniformsCommon( uniforms, material );
			refreshUniformsMatcap( uniforms, material );

		} else if ( material.isMeshDepthMaterial ) {

			refreshUniformsCommon( uniforms, material );
			refreshUniformsDepth( uniforms, material );

		} else if ( material.isMeshDistanceMaterial ) {

			refreshUniformsCommon( uniforms, material );
			refreshUniformsDistance( uniforms, material );

		} else if ( material.isMeshNormalMaterial ) {

			refreshUniformsCommon( uniforms, material );
			refreshUniformsNormal( uniforms, material );

		} else if ( material.isLineBasicMaterial ) {

			refreshUniformsLine( uniforms, material );

			if ( material.isLineDashedMaterial ) {

				refreshUniformsDash( uniforms, material );

			}

		} else if ( material.isPointsMaterial ) {

			refreshUniformsPoints( uniforms, material, pixelRatio, height );

		} else if ( material.isSpriteMaterial ) {

			refreshUniformsSprites( uniforms, material );

		} else if ( material.isShadowMaterial ) {

			uniforms.color.value.copy( material.color );
			uniforms.opacity.value = material.opacity;

		} else if ( material.isShaderMaterial ) {

			material.uniformsNeedUpdate = false; // #15581

		}

	}


	refreshUniformsCommon( Map<String, dynamic> uniforms, Material material ) {

		uniforms["opacity"]["value"] = material.opacity;

 
		if ( material.color != null ) {

			uniforms["diffuse"]["value"].copy( material.color );

		}



		if ( material.emissive != null ) {

			uniforms["emissive"]["value"].copy( material.emissive ).multiplyScalar( material.emissiveIntensity );

		}

  
		if ( material.map != null ) {

			uniforms["map"]["value"] = material.map;

		}

		if ( material.alphaMap != null ) {

			uniforms["alphaMap"]["value"] = material.alphaMap;

		}

		if ( material.specularMap != null ) {

			uniforms["specularMap"]["value"] = material.specularMap;

		}

 
		var envMap = properties.get( material )["envMap"];

		if ( envMap != null ) {

			uniforms["envMap"]["value"] = envMap;

			uniforms["flipEnvMap"]["value"] = ( envMap.isCubeTexture && envMap.isRenderTargetTexture == false ) ? - 1 : 1;

			uniforms["reflectivity"]["value"] = material.reflectivity;
      uniforms["ior"]["value"] = material.ior;
			uniforms["refractionRatio"]["value"] = material.refractionRatio;

			var maxMipLevel = properties.get( envMap )["__maxMipLevel"];

			if ( maxMipLevel != null ) {

				uniforms["maxMipLevel"]["value"] = maxMipLevel;

			}

		}

  
		if ( material.lightMap != null ) {

			uniforms["lightMap"]["value"] = material.lightMap;
			uniforms["lightMapIntensity"]["value"] = material.lightMapIntensity;

		}

		if ( material.aoMap != null ) {

			uniforms["aoMap"]["value"] = material.aoMap;
			uniforms["aoMapIntensity"]["value"] = material.aoMapIntensity;

		}

		// uv repeat and offset setting priorities
		// 1. color map
		// 2. specular map
		// 3. displacementMap map
		// 4. normal map
		// 5. bump map
		// 6. roughnessMap map
		// 7. metalnessMap map
		// 8. alphaMap map
		// 9. emissiveMap map
		// 10. clearcoat map
		// 11. clearcoat normal map
		// 12. clearcoat roughnessMap map

		var uvScaleMap;

		if ( material.map != null ) {

			uvScaleMap = material.map;

		} else if ( material.specularMap != null ) {

			uvScaleMap = material.specularMap;

		} else if ( material.displacementMap != null ) {

			uvScaleMap = material.displacementMap;

		} else if ( material.normalMap != null ) {

			uvScaleMap = material.normalMap;

		} else if ( material.bumpMap != null ) {

			uvScaleMap = material.bumpMap;

		} else if ( material.roughnessMap != null ) {

			uvScaleMap = material.roughnessMap;

		} else if ( material.metalnessMap != null ) {

			uvScaleMap = material.metalnessMap;

		} else if ( material.alphaMap != null ) {

			uvScaleMap = material.alphaMap;

		} else if ( material.emissiveMap != null ) {

			uvScaleMap = material.emissiveMap;

		} else if ( material.clearcoatMap != null ) {

			uvScaleMap = material.clearcoatMap;

		} else if ( material.clearcoatNormalMap != null ) {

			uvScaleMap = material.clearcoatNormalMap;

		} else if ( material.clearcoatRoughnessMap != null ) {

			uvScaleMap = material.clearcoatRoughnessMap;
      
    } else if ( material.specularIntensityMap != null ) {

			uvScaleMap = material.specularIntensityMap;

		} else if ( material.specularTintMap != null ) {

			uvScaleMap = material.specularTintMap;

		}

		if ( uvScaleMap != null ) {

			// backwards compatibility
			if ( uvScaleMap.isWebGLRenderTarget ) {

				uvScaleMap = uvScaleMap.texture;

			}

			if ( uvScaleMap.matrixAutoUpdate == true ) {

				uvScaleMap.updateMatrix();

			}

			uniforms["uvTransform"]["value"].copy( uvScaleMap.matrix );

		}

		// uv repeat and offset setting priorities for uv2
		// 1. ao map
		// 2. light map

		var uv2ScaleMap;

		if ( material.aoMap != null ) {

			uv2ScaleMap = material.aoMap;

		} else if ( material.lightMap != null ) {

			uv2ScaleMap = material.lightMap;

		}

		if ( uv2ScaleMap != null ) {

			// backwards compatibility
			if ( uv2ScaleMap.isWebGLRenderTarget ) {

				uv2ScaleMap = uv2ScaleMap.texture;

			}

			if ( uv2ScaleMap.matrixAutoUpdate == true ) {

				uv2ScaleMap.updateMatrix();

			}

			uniforms["uv2Transform"]["value"].copy( uv2ScaleMap.matrix );

		}

	}

	refreshUniformsLine( uniforms, material ) {

		uniforms["diffuse"]["value"].copy( material.color );
		uniforms["opacity"]["value"] = material.opacity;

	}

	refreshUniformsDash( uniforms, material ) {

		uniforms["dashSize"]["value"] = material.dashSize;
		uniforms["totalSize"]["value"] = material.dashSize + material.gapSize;
		uniforms["scale"]["value"] = material.scale;

	}

	refreshUniformsPoints( uniforms, Material material, pixelRatio, height ) {

		uniforms["diffuse"]["value"].copy( material.color );
		uniforms["opacity"]["value"] = material.opacity;
		uniforms["size"]["value"] = material.size! * pixelRatio;
		uniforms["scale"]["value"] = height * 0.5;

		if ( material.map != null ) {

			uniforms["map"]["value"] = material.map;

		}

		if ( material.alphaMap != null ) {

			uniforms["alphaMap"]["value"] = material.alphaMap;

		}

		// uv repeat and offset setting priorities
		// 1. color map
		// 2. alpha map

		var uvScaleMap;

		if ( material.map != null ) {

			uvScaleMap = material.map;

		} else if ( material.alphaMap != null ) {

			uvScaleMap = material.alphaMap;

		}

		if ( uvScaleMap != null ) {

			if ( uvScaleMap.matrixAutoUpdate == true ) {

				uvScaleMap.updateMatrix();

			}

			uniforms["uvTransform"]["value"].copy( uvScaleMap.matrix );

		}

	}

	refreshUniformsSprites( uniforms, material ) {

		uniforms["diffuse"]["value"].copy( material.color );
		uniforms["opacity"]["value"] = material.opacity;
		uniforms["rotation"]["value"] = material.rotation;

		if ( material.map != null ) {

			uniforms["map"]["value"] = material.map;

		}

		if ( material.alphaMap != null ) {

			uniforms["alphaMap"]["value"] = material.alphaMap;

		}

		// uv repeat and offset setting priorities
		// 1. color map
		// 2. alpha map

		var uvScaleMap;

		if ( material.map != null ) {

			uvScaleMap = material.map;

		} else if ( material.alphaMap != null ) {

			uvScaleMap = material.alphaMap;

		}

		if ( uvScaleMap != null ) {

			if ( uvScaleMap.matrixAutoUpdate == true ) {

				uvScaleMap.updateMatrix();

			}

			uniforms["uvTransform"]["value"].copy( uvScaleMap.matrix );

		}

	}

	refreshUniformsLambert( uniforms, Material material ) {

		if ( material.emissiveMap != null ) {

			uniforms["emissiveMap"]["value"] = material.emissiveMap;

		}

	}

	refreshUniformsPhong( uniforms, material ) {

 
		uniforms["specular"]["value"].copy( material.specular );
		uniforms["shininess"]["value"] = Math.max( material.shininess, 1e-4 ); // to prevent pow( 0.0, 0.0 )

		if ( material.emissiveMap != null ) {

			uniforms["emissiveMap"]["value"] = material.emissiveMap;

		}

		if ( material.bumpMap != null) {

			uniforms["bumpMap"]["value"] = material.bumpMap;
			uniforms["bumpScale"]["value"] = material.bumpScale;
			if ( material.side == BackSide ) uniforms["bumpScale"]["value"] *= - 1;

		}

		if ( material.normalMap != null) {

			uniforms["normalMap"]["value"] = material.normalMap;
			uniforms["normalScale"]["value"].copy( material.normalScale );
			if ( material.side == BackSide ) uniforms["normalScale"]["value"].negate();

		}

		if ( material.displacementMap != null) {

			uniforms["displacementMap"]["value"] = material.displacementMap;
			uniforms["displacementScale"]["value"] = material.displacementScale;
			uniforms["displacementBias"]["value"] = material.displacementBias;

		}

	}

	refreshUniformsToon( uniforms, material ) {

		if ( material.gradientMap != null) {

			uniforms["gradientMap"]["value"] = material.gradientMap;

		}

		if ( material.emissiveMap != null) {
			uniforms["emissiveMap"]["value"] = material.emissiveMap;
		}

		if ( material.bumpMap != null) {

			uniforms["bumpMap"]["value"] = material.bumpMap;
			uniforms["bumpScale"]["value"] = material.bumpScale;
			if ( material.side == BackSide ) uniforms["bumpScale"]["value"] *= - 1;

		}

		if ( material.normalMap != null) {

			uniforms["normalMap"]["value"] = material.normalMap;
			uniforms["normalScale"]["value"].copy( material.normalScale );
			if ( material.side == BackSide ) uniforms["normalScale"]["value"].negate();

		}

		if ( material.displacementMap != null) {

			uniforms["displacementMap"]["value"] = material.displacementMap;
			uniforms["displacementScale"]["value"] = material.displacementScale;
			uniforms["displacementBias"]["value"] = material.displacementBias;

		}

	}

	refreshUniformsStandard( uniforms, material ) {

		uniforms["roughness"]["value"] = material.roughness;
		uniforms["metalness"]["value"] = material.metalness;

		if ( material.roughnessMap != null) {

			uniforms["roughnessMap"]["value"] = material.roughnessMap;

		}

		if ( material.metalnessMap != null) {

			uniforms["metalnessMap"]["value"] = material.metalnessMap;

		}

		if ( material.emissiveMap != null) {

			uniforms["emissiveMap"]["value"] = material.emissiveMap;

		}

		if ( material.bumpMap != null) {

			uniforms["bumpMap"]["value"] = material.bumpMap;
			uniforms["bumpScale"]["value"] = material.bumpScale;
			if ( material.side == BackSide ) uniforms["bumpScale"]["value"] *= - 1;

		}

		if ( material.normalMap != null) {

			uniforms["normalMap"]["value"] = material.normalMap;
			uniforms["normalScale"]["value"].copy( material.normalScale );
			if ( material.side == BackSide ) uniforms["normalScale"]["value"].negate();

		}

		if ( material.displacementMap != null) {

			uniforms["displacementMap"]["value"] = material.displacementMap;
			uniforms["displacementScale"]["value"] = material.displacementScale;
			uniforms["displacementBias"]["value"] = material.displacementBias;

		}

		var envMap = properties.get( material )["envMap"];

		if ( envMap == true ) {

			//uniforms["envMap"]["value"] = material.envMap; // part of uniforms common
			uniforms["envMapIntensity"]["value"] = material.envMapIntensity;

		}

	}

	refreshUniformsPhysical( uniforms, material, transmissionRenderTarget ) {

		refreshUniformsStandard( uniforms, material );

		uniforms.ior.value = material.ior; // also part of uniforms common

		uniforms.clearcoat.value = material.clearcoat;
		uniforms.clearcoatRoughness.value = material.clearcoatRoughness;

		if ( material.sheen ) uniforms.sheen.value.copy( material.sheen );

		if ( material.clearcoatMap ) {

			uniforms.clearcoatMap.value = material.clearcoatMap;

		}

		if ( material.clearcoatRoughnessMap ) {

			uniforms.clearcoatRoughnessMap.value = material.clearcoatRoughnessMap;

		}

		if ( material.clearcoatNormalMap ) {

			uniforms.clearcoatNormalScale.value.copy( material.clearcoatNormalScale );
			uniforms.clearcoatNormalMap.value = material.clearcoatNormalMap;

			if ( material.side == BackSide ) {

				uniforms.clearcoatNormalScale.value.negate();

			}

		}

		uniforms.transmission.value = material.transmission;

		if ( material.transmissionMap ) {

			uniforms.transmissionMap.value = material.transmissionMap;

		}

		if ( material.transmission > 0.0 ) {

			uniforms.transmissionSamplerMap.value = transmissionRenderTarget.texture;
			uniforms.transmissionSamplerSize.value.set( transmissionRenderTarget.width, transmissionRenderTarget.height );

		}

		uniforms.thickness.value = material.thickness;

		if ( material.thicknessMap ) {

			uniforms.thicknessMap.value = material.thicknessMap;

		}

		uniforms.attenuationDistance.value = material.attenuationDistance;
		uniforms.attenuationTint.value.copy( material.attenuationTint );

		uniforms.specularIntensity.value = material.specularIntensity;
		uniforms.specularTint.value.copy( material.specularTint );

		if ( material.specularIntensityMap ) {

			uniforms.specularIntensityMap.value = material.specularIntensityMap;

		}

		if ( material.specularTintMap ) {

			uniforms.specularTintMap.value = material.specularTintMap;

		}

	}

	refreshUniformsMatcap( uniforms, material ) {

		if ( material.matcap != null) {

			uniforms["matcap"]["value"] = material.matcap;

		}

		if ( material.bumpMap != null) {

			uniforms["bumpMap"]["value"] = material.bumpMap;
			uniforms["bumpScale"]["value"] = material.bumpScale;
			if ( material.side == BackSide ) uniforms["bumpScale"]["value"] *= - 1;

		}

		if ( material.normalMap != null) {

			uniforms["normalMap"]["value"] = material.normalMap;
			uniforms["normalScale"]["value"].copy( material.normalScale );
			if ( material.side == BackSide ) uniforms["normalScale"]["value"].negate();

		}

		if ( material.displacementMap != null) {

			uniforms["displacementMap"]["value"] = material.displacementMap;
			uniforms["displacementScale"]["value"] = material.displacementScale;
			uniforms["displacementBias"]["value"] = material.displacementBias;

		}

	}

	refreshUniformsDepth( uniforms, material ) {

		if ( material.displacementMap != null) {

			uniforms["displacementMap"]["value"] = material.displacementMap;
			uniforms["displacementScale"]["value"] = material.displacementScale;
			uniforms["displacementBias"]["value"] = material.displacementBias;

		}

	}

	refreshUniformsDistance( uniforms, material ) {

		if ( material.displacementMap != null) {

			uniforms["displacementMap"]["value"] = material.displacementMap;
			uniforms["displacementScale"]["value"] = material.displacementScale;
			uniforms["displacementBias"]["value"] = material.displacementBias;

		}

		uniforms["referencePosition"]["value"].copy( material.referencePosition );
		uniforms["nearDistance"]["value"] = material.nearDistance;
		uniforms["farDistance"]["value"] = material.farDistance;

	}

	refreshUniformsNormal( uniforms, material ) {

		if ( material.bumpMap != null) {

			uniforms["bumpMap"]["value"] = material.bumpMap;
			uniforms["bumpScale"]["value"] = material.bumpScale;
			if ( material.side == BackSide ) uniforms["bumpScale"]["value"] *= - 1;

		}

		if ( material.normalMap != null) {

			uniforms["normalMap"]["value"] = material.normalMap;
			uniforms["normalScale"]["value"].copy( material.normalScale );
			if ( material.side == BackSide ) uniforms["normalScale"]["value"].negate();

		}

		if ( material.displacementMap != null) {

			uniforms["displacementMap"]["value"] = material.displacementMap;
			uniforms["displacementScale"]["value"] = material.displacementScale;
			uniforms["displacementBias"]["value"] = material.displacementBias;

		}

	}

}

