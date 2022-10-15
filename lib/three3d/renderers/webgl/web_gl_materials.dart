
import 'package:three_dart/three3d/constants.dart';
import 'package:three_dart/three3d/materials/index.dart';
import 'package:three_dart/three3d/materials/material.dart';
import 'package:three_dart/three3d/math/index.dart';
import 'package:three_dart/three3d/renderers/web_gl_renderer.dart';
import 'package:three_dart/three3d/renderers/webgl/web_gl_properties.dart';
import 'package:three_dart/three3d/textures/index.dart';

class WebGLMaterials {
   WebGLRenderer renderer;
  WebGLProperties properties;

  WebGLMaterials(this.renderer, this.properties);

  refreshFogUniforms(uniforms, fog) {
    uniforms["fogColor"]["value"].copy(fog.color);

    if (fog.isFog) {
      uniforms["fogNear"]["value"] = fog.near;
      uniforms["fogFar"]["value"] = fog.far;
    } else if (fog.isFogExp2) {
      uniforms["fogDensity"]["value"] = fog.density;
    }
  }

  refreshMaterialUniforms(uniforms, Material material, pixelRatio, height,
      transmissionRenderTarget) {
    if (material is MeshBasicMaterial) {
      refreshUniformsCommon(uniforms, material);
    } else if (material is MeshLambertMaterial) {
      refreshUniformsCommon(uniforms, material);
    } else if (material is MeshToonMaterial) {
      refreshUniformsCommon(uniforms, material);
      refreshUniformsToon(uniforms, material);
    } else if (material is MeshPhongMaterial) {
      refreshUniformsCommon(uniforms, material);
      refreshUniformsPhong(uniforms, material);
    } else if (material is MeshStandardMaterial) {
      refreshUniformsCommon(uniforms, material);
      refreshUniformsStandard( uniforms, material );
      if (material is MeshPhysicalMaterial) {
        refreshUniformsPhysical(uniforms, material, transmissionRenderTarget);
      }
    } else if (material is MeshMatcapMaterial) {
      refreshUniformsCommon(uniforms, material);
      refreshUniformsMatcap(uniforms, material);
    } else if (material is MeshDepthMaterial) {
      refreshUniformsCommon(uniforms, material);
    } else if (material is MeshDistanceMaterial) {
      refreshUniformsCommon(uniforms, material);
      refreshUniformsDistance(uniforms, material);
    } else if (material is MeshNormalMaterial) {
      refreshUniformsCommon(uniforms, material);
    } else if (material is LineBasicMaterial) {
      refreshUniformsLine(uniforms, material);

      if (material is LineDashedMaterial) {
        refreshUniformsDash(uniforms, material);
      }
    } else if (material is PointsMaterial) {
      refreshUniformsPoints(uniforms, material, pixelRatio, height);
    } else if (material is SpriteMaterial) {
      refreshUniformsSprites(uniforms, material);
    } else if (material is ShadowMaterial) {
      uniforms["color"]["value"].copy(material.color);
      uniforms["opacity"]["value"] = material.opacity;
    } else if (material is ShaderMaterial) {
      material.uniformsNeedUpdate = false; // #15581

    }
  }

  refreshUniformsCommon(Map<String, dynamic> uniforms, Material material) {
    uniforms["opacity"]["value"] = material.opacity;

    uniforms["diffuse"]["value"].copy(material.color);

    if (material.emissive != null) {
      uniforms["emissive"]["value"]
          .copy(material.emissive)
          .multiplyScalar(material.emissiveIntensity);
    }

    if (material.map != null) {
      uniforms["map"]["value"] = material.map;
    }

    if (material.alphaMap != null) {
      uniforms["alphaMap"]["value"] = material.alphaMap;
    }

    if ( material.bumpMap != null ) {

			uniforms["bumpMap"]["value"] = material.bumpMap;
			uniforms["bumpScale"]["value"] = material.bumpScale;
			if ( material.side == BackSide ) uniforms["bumpScale"]["value"] *= - 1;

		}

		if ( material.displacementMap != null ) {

			uniforms["displacementMap"]["value"] = material.displacementMap;
			uniforms["displacementScale"]["value"] = material.displacementScale;
			uniforms["displacementBias"]["value"] = material.displacementBias;

		}

		if ( material.emissiveMap != null ) {

			uniforms["emissiveMap"]["value"] = material.emissiveMap;

		}

		if ( material.normalMap != null ) {

			uniforms["normalMap"]["value"] = material.normalMap;
			uniforms["normalScale"]["value"].copy( material.normalScale );
			if ( material.side == BackSide ) uniforms["normalScale"]["value"].negate();
		}

    if (material.specularMap != null) {
      uniforms["specularMap"]["value"] = material.specularMap;
    }

    if (material.alphaTest > 0) {
      uniforms["alphaTest"]["value"] = material.alphaTest;
    }

    var envMap = properties.get(material)["envMap"];

    if (envMap != null) {
      uniforms["envMap"]["value"] = envMap;

      uniforms["flipEnvMap"]["value"] = (envMap.type == "CubeTexture" &&
              envMap.isRenderTargetTexture == false)
          ? -1
          : 1;

      uniforms["reflectivity"]["value"] = material.reflectivity;
      uniforms["ior"]["value"] = material.ior;
      uniforms["refractionRatio"]["value"] = material.refractionRatio;
    }

    if (material.lightMap != null) {
      uniforms["lightMap"]["value"] = material.lightMap;
 
			// artist-friendly light intensity scaling factor
			var scaleFactor = ( renderer.physicallyCorrectLights != true ) ? Math.PI : 1;

			uniforms["lightMapIntensity"]["value"] = material.lightMapIntensity! * scaleFactor;
    }

    if (material.aoMap != null) {
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

    if (material.map != null) {
      uvScaleMap = material.map;
    } else if (material.specularMap != null) {
      uvScaleMap = material.specularMap;
    } else if (material.displacementMap != null) {
      uvScaleMap = material.displacementMap;
    } else if (material.normalMap != null) {
      uvScaleMap = material.normalMap;
    } else if (material.bumpMap != null) {
      uvScaleMap = material.bumpMap;
    } else if (material.roughnessMap != null) {
      uvScaleMap = material.roughnessMap;
    } else if (material.metalnessMap != null) {
      uvScaleMap = material.metalnessMap;
    } else if (material.alphaMap != null) {
      uvScaleMap = material.alphaMap;
    } else if (material.emissiveMap != null) {
      uvScaleMap = material.emissiveMap;
    } else if (material.clearcoatMap != null) {
      uvScaleMap = material.clearcoatMap;
    } else if (material.clearcoatNormalMap != null) {
      uvScaleMap = material.clearcoatNormalMap;
    } else if (material.clearcoatRoughnessMap != null) {
      uvScaleMap = material.clearcoatRoughnessMap;
    } else if (material.specularIntensityMap != null) {
      uvScaleMap = material.specularIntensityMap;
    } else if (material.specularColorMap != null) {
      uvScaleMap = material.specularColorMap;
    } else if (material.transmissionMap != null) {
      uvScaleMap = material.transmissionMap;
    } else if (material.thicknessMap != null) {
      uvScaleMap = material.thicknessMap;
    } else if (material.sheenColorMap != null) {
      uvScaleMap = material.sheenColorMap;
    } else if (material.sheenRoughnessMap != null) {
      uvScaleMap = material.sheenRoughnessMap;
    }

    if (uvScaleMap != null) {
      // backwards compatibility
      if (uvScaleMap.isWebGLRenderTarget) {
        uvScaleMap = uvScaleMap.texture;
      }

      if (uvScaleMap?.matrixAutoUpdate == true) {
        uvScaleMap?.updateMatrix();
      }

      uniforms["uvTransform"]["value"].copy(uvScaleMap.matrix);
    }

    // uv repeat and offset setting priorities for uv2
    // 1. ao map
    // 2. light map

    var uv2ScaleMap;

    if (material.aoMap != null) {
      uv2ScaleMap = material.aoMap;
    } else if (material.lightMap != null) {
      uv2ScaleMap = material.lightMap;
    }

    if (uv2ScaleMap != null) {
      // backwards compatibility
      if (uv2ScaleMap.isWebGLRenderTarget) {
        uv2ScaleMap = uv2ScaleMap.texture;
      }

      if (uv2ScaleMap.matrixAutoUpdate == true) {
        uv2ScaleMap.updateMatrix();
      }

      uniforms["uv2Transform"]["value"].copy(uv2ScaleMap.matrix);
    }
  }

  refreshUniformsLine(uniforms, material) {
    uniforms["diffuse"]["value"].copy(material.color);
    uniforms["opacity"]["value"] = material.opacity;
  }

  refreshUniformsDash(uniforms, material) {
    uniforms["dashSize"]["value"] = material.dashSize;
    uniforms["totalSize"]["value"] = material.dashSize + material.gapSize;
    uniforms["scale"]["value"] = material.scale;
  }

  refreshUniformsPoints(uniforms, Material material, pixelRatio, height) {
    uniforms["diffuse"]["value"].copy(material.color);
    uniforms["opacity"]["value"] = material.opacity;
    uniforms["size"]["value"] = material.size! * pixelRatio;
    uniforms["scale"]["value"] = height * 0.5;

    if (material.map != null) {
      uniforms["map"]["value"] = material.map;
    }

    if (material.alphaMap != null) {
      uniforms["alphaMap"]["value"] = material.alphaMap;
    }

    if (material.alphaTest > 0) {
      uniforms["alphaTest"]["value"] = material.alphaTest;
    }

    // uv repeat and offset setting priorities
    // 1. color map
    // 2. alpha map

    Texture? uvScaleMap;

    if (material.map != null) {
      uvScaleMap = material.map;
    } else if (material.alphaMap != null) {
      uvScaleMap = material.alphaMap;
    }

    if (uvScaleMap != null) {
      if (uvScaleMap.matrixAutoUpdate == true) {
        uvScaleMap.updateMatrix();
      }

      uniforms["uvTransform"]["value"].copy(uvScaleMap.matrix);
    }
  }

  refreshUniformsSprites(uniforms, material) {
    uniforms["diffuse"]["value"].copy(material.color);
    uniforms["opacity"]["value"] = material.opacity;
    uniforms["rotation"]["value"] = material.rotation;

    if (material.map != null) {
      uniforms["map"]["value"] = material.map;
    }

    if (material.alphaMap != null) {
      uniforms["alphaMap"]["value"] = material.alphaMap;
    }

    if (material.alphaTest > 0) {
      uniforms["alphaTest"]["value"] = material.alphaTest;
    }

    // uv repeat and offset setting priorities
    // 1. color map
    // 2. alpha map

    var uvScaleMap;

    if (material.map != null) {
      uvScaleMap = material.map;
    } else if (material.alphaMap != null) {
      uvScaleMap = material.alphaMap;
    }

    if (uvScaleMap != null) {
      if (uvScaleMap.matrixAutoUpdate == true) {
        uvScaleMap.updateMatrix();
      }

      uniforms["uvTransform"]["value"].copy(uvScaleMap.matrix);
    }
  }

  refreshUniformsPhong(uniforms, material) {
    uniforms["specular"]["value"].copy(material.specular);
    uniforms["shininess"]["value"] =
        Math.max<num>(material.shininess, 1e-4); // to prevent pow( 0.0, 0.0 )
  }

  refreshUniformsToon(uniforms, material) {
    if (material.gradientMap != null) {
      uniforms["gradientMap"]["value"] = material.gradientMap;
    }
  }

  refreshUniformsStandard(uniforms, material) {
    uniforms["roughness"]["value"] = material.roughness;
    uniforms["metalness"]["value"] = material.metalness;

    if (material.roughnessMap != null) {
      uniforms["roughnessMap"]["value"] = material.roughnessMap;
    }

    if (material.metalnessMap != null) {
      uniforms["metalnessMap"]["value"] = material.metalnessMap;
    }

    var envMap = properties.get( material )["envMap"];

		if ( envMap != null ) {

			//uniforms.envMap.value = material.envMap; // part of uniforms common
			uniforms["envMapIntensity"]["value"] = material.envMapIntensity;

		}
  }

  refreshUniformsPhysical(uniforms, material, transmissionRenderTarget) {

    uniforms["ior"]["value"] = material.ior; // also part of uniforms common

    if (material.sheen > 0) {
      uniforms["sheenColor"]["value"].copy(material.sheenColor);

      uniforms["sheenRoughness"]["value"] = material.sheenRoughness;

      if (material.sheenColorMap != null) {
        uniforms["sheenColorMap"]["value"] = material.sheenColorMap;
      }

      if (material.sheenRoughnessMap != null) {
        uniforms["sheenRoughnessMap"]["value"] = material.sheenRoughnessMap;
      }
    }

    if (material.clearcoat > 0) {
      uniforms["clearcoat"]["value"] = material.clearcoat;
      uniforms["clearcoatRoughness"]["value"] = material.clearcoatRoughness;

      if (material.clearcoatMap != null) {
        uniforms["clearcoatMap"]["value"] = material.clearcoatMap;
      }

      if (material.clearcoatRoughnessMap != null) {
        uniforms["clearcoatRoughnessMap"]["value"] =
            material.clearcoatRoughnessMap;
      }

      if (material.clearcoatNormalMap != null) {
        uniforms["clearcoatNormalScale"]["value"]
            .copy(material.clearcoatNormalScale);
        uniforms["clearcoatNormalMap"]["value"] = material.clearcoatNormalMap;

        if (material.side == BackSide) {
          uniforms["clearcoatNormalScale"]["value"].negate();
        }
      }
    }

    if (material.transmission > 0) {
      uniforms["transmission"]["value"] = material.transmission;
      uniforms["transmissionSamplerMap"]["value"] =
          transmissionRenderTarget.texture;
      uniforms["transmissionSamplerSize"]["value"]
          .set(transmissionRenderTarget.width, transmissionRenderTarget.height);

      if (material.transmissionMap != null) {
        uniforms["transmissionMap"]["value"] = material.transmissionMap;
      }

      uniforms["thickness"]["value"] = material.thickness;

      if (material.thicknessMap != null) {
        uniforms["thicknessMap"]["value"] = material.thicknessMap;
      }
    }

    uniforms["attenuationDistance"]["value"] = material.attenuationDistance;
    uniforms["attenuationColor"]["value"].copy(material.attenuationColor);

    uniforms["specularIntensity"]["value"] = material.specularIntensity;
    uniforms["attenuationColor"]["value"].copy(material.attenuationColor);

    if (material.specularIntensityMap != null) {
      uniforms["specularIntensityMap"]["value"] = material.specularIntensityMap;
    }

    if (material.specularColorMap != null) {
      uniforms["specularColorMap"]["value"] = material.specularColorMap;
    }
  }

  refreshUniformsMatcap(uniforms, material) {
    if (material.matcap != null) {
      uniforms["matcap"]["value"] = material.matcap;
    }
  }

  refreshUniformsDistance(uniforms, material) {
    uniforms["referencePosition"]["value"].copy(material.referencePosition);
    uniforms["nearDistance"]["value"] = material.nearDistance;
    uniforms["farDistance"]["value"] = material.farDistance;
  }

}
