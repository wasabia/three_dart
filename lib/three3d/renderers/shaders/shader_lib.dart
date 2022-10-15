
import 'package:three_dart/three3d/math/index.dart';
import 'package:three_dart/three3d/renderers/shaders/shader_chunk.dart';
import 'package:three_dart/three3d/renderers/shaders/uniforms_lib.dart';
import 'package:three_dart/three3d/renderers/shaders/uniforms_utils.dart';

Map<String, dynamic> ShaderLibStandard = {
  "uniforms": mergeUniforms([
    UniformsLib["common"],
    UniformsLib["envmap"],
    UniformsLib["aomap"],
    UniformsLib["lightmap"],
    UniformsLib["emissivemap"],
    UniformsLib["bumpmap"],
    UniformsLib["normalmap"],
    UniformsLib["displacementmap"],
    UniformsLib["roughnessmap"],
    UniformsLib["metalnessmap"],
    UniformsLib["fog"],
    UniformsLib["lights"],
    {
      "emissive": {"value": Color(0, 0, 0)},
      "roughness": {"value": 1.0},
      "metalness": {"value": 0.0},
      "envMapIntensity": {"value": 1} // temporary
    }
  ]),
  "vertexShader": ShaderChunk["meshphysical_vert"],
  "fragmentShader": ShaderChunk["meshphysical_frag"]
};

Map<String, dynamic> ShaderLib = {
  "basic": {
    "uniforms": mergeUniforms([
      UniformsLib["common"],
      UniformsLib["specularmap"],
      UniformsLib["envmap"],
      UniformsLib["aomap"],
      UniformsLib["lightmap"],
      UniformsLib["fog"]
    ]),
    "vertexShader": ShaderChunk["meshbasic_vert"],
    "fragmentShader": ShaderChunk["meshbasic_frag"]
  },
  "lambert": {
    "uniforms": mergeUniforms([
      UniformsLib["common"],
      UniformsLib["specularmap"],
      UniformsLib["envmap"],
      UniformsLib["aomap"],
      UniformsLib["lightmap"],
      UniformsLib["emissivemap"],
      UniformsLib["fog"],
      UniformsLib["lights"],
      {
        "emissive": {"value": Color.fromHex(0x000000)}
      }
    ]),
    "vertexShader": ShaderChunk["meshlambert_vert"],
    "fragmentShader": ShaderChunk["meshlambert_frag"]
  },
  "phong": {
    "uniforms": mergeUniforms([
      UniformsLib["common"],
      UniformsLib["specularmap"],
      UniformsLib["envmap"],
      UniformsLib["aomap"],
      UniformsLib["lightmap"],
      UniformsLib["emissivemap"],
      UniformsLib["bumpmap"],
      UniformsLib["normalmap"],
      UniformsLib["displacementmap"],
      UniformsLib["fog"],
      UniformsLib["lights"],
      {
        "emissive": {"value": Color.fromHex(0x000000)},
        "specular": {"value": Color.fromHex(0x111111)},
        "shininess": {"value": 30}
      }
    ]),
    "vertexShader": ShaderChunk["meshphong_vert"],
    "fragmentShader": ShaderChunk["meshphong_frag"]
  },
  "standard": ShaderLibStandard,
  "toon": {
    "uniforms": mergeUniforms([
      UniformsLib["common"],
      UniformsLib["aomap"],
      UniformsLib["lightmap"],
      UniformsLib["emissivemap"],
      UniformsLib["bumpmap"],
      UniformsLib["normalmap"],
      UniformsLib["displacementmap"],
      UniformsLib["gradientmap"],
      UniformsLib["fog"],
      UniformsLib["lights"],
      {
        "emissive": {"value": Color.fromHex(0x000000)}
      }
    ]),
    "vertexShader": ShaderChunk["meshtoon_vert"],
    "fragmentShader": ShaderChunk["meshtoon_frag"]
  },
  "matcap": {
    "uniforms": mergeUniforms([
      UniformsLib["common"],
      UniformsLib["bumpmap"],
      UniformsLib["normalmap"],
      UniformsLib["displacementmap"],
      UniformsLib["fog"],
      {
        "matcap": {"value": null}
      }
    ]),
    "vertexShader": ShaderChunk["meshmatcap_vert"],
    "fragmentShader": ShaderChunk["meshmatcap_frag"]
  },
  "points": {
    "uniforms": mergeUniforms([UniformsLib["points"], UniformsLib["fog"]]),
    "vertexShader": ShaderChunk["points_vert"],
    "fragmentShader": ShaderChunk["points_frag"]
  },
  "dashed": {
    "uniforms": mergeUniforms([
      UniformsLib["common"],
      UniformsLib["fog"],
      {
        "scale": {"value": 1},
        "dashSize": {"value": 1},
        "totalSize": {"value": 2}
      }
    ]),
    "vertexShader": ShaderChunk["linedashed_vert"],
    "fragmentShader": ShaderChunk["linedashed_frag"]
  },
  "depth": {
    "uniforms":
        mergeUniforms([UniformsLib["common"], UniformsLib["displacementmap"]]),
    "vertexShader": ShaderChunk["depth_vert"],
    "fragmentShader": ShaderChunk["depth_frag"]
  },
  "normal": {
    "uniforms": mergeUniforms([
      UniformsLib["common"],
      UniformsLib["bumpmap"],
      UniformsLib["normalmap"],
      UniformsLib["displacementmap"],
      {
        "opacity": {"value": 1.0}
      }
    ]),
    "vertexShader": ShaderChunk["meshnormal_vert"],
    "fragmentShader": ShaderChunk["meshnormal_frag"]
  },
  "sprite": {
    "uniforms": mergeUniforms([UniformsLib["sprite"], UniformsLib["fog"]]),
    "vertexShader": ShaderChunk["sprite_vert"],
    "fragmentShader": ShaderChunk["sprite_frag"]
  },
  "background": {
    "uniforms": {
      "uvTransform": {"value": Matrix3()},
      "t2D": {"value": null},
    },
    "vertexShader": ShaderChunk["background_vert"],
    "fragmentShader": ShaderChunk["background_frag"]
  },
  /* -------------------------------------------------------------------------
	//	Cube map shader
	 ------------------------------------------------------------------------- */

  "cube": {
    "uniforms": mergeUniforms([
      UniformsLib["envmap"],
      {
        "opacity": {"value": 1.0}
      }
    ]),
    "vertexShader": ShaderChunk["cube_vert"],
    "fragmentShader": ShaderChunk["cube_frag"]
  },
  "equirect": {
    "uniforms": {
      "tEquirect": {"value": null},
    },
    "vertexShader": ShaderChunk["equirect_vert"],
    "fragmentShader": ShaderChunk["equirect_frag"]
  },
  "distanceRGBA": {
    "uniforms": mergeUniforms([
      UniformsLib["common"],
      UniformsLib["displacementmap"],
      {
        "referencePosition": {"value": Vector3.init()},
        "nearDistance": {"value": 1},
        "farDistance": {"value": 1000}
      }
    ]),
    "vertexShader": ShaderChunk["distanceRGBA_vert"],
    "fragmentShader": ShaderChunk["distanceRGBA_frag"]
  },
  "shadow": {
    "uniforms": mergeUniforms([
      UniformsLib["lights"],
      UniformsLib["fog"],
      {
        "color": {"value": Color.fromHex(0x000000)},
        "opacity": {"value": 1.0}
      },
    ]),
    "vertexShader": ShaderChunk["shadow_vert"],
    "fragmentShader": ShaderChunk["shadow_frag"]
  },
  "physical": {
    "uniforms": mergeUniforms([
      ShaderLibStandard["uniforms"],
      {
        "clearcoat": {"value": 0},
        "clearcoatMap": {"value": null},
        "clearcoatRoughness": {"value": 0},
        "clearcoatRoughnessMap": {"value": null},
        "clearcoatNormalScale": {"value": Vector2(1, 1)},
        "clearcoatNormalMap": {"value": null},
        "sheenColor": {"value": Color.fromHex(0x000000)},
        "sheenColorMap": {},
        "sheenRoughness": {"value": 1.0},
        "sheenRoughnessMap": {},
        "transmission": {"value": 0},
        "transmissionMap": {"value": null},
        "transmissionSamplerSize": {"value": Vector2(null, null)},
        "transmissionSamplerMap": {"value": null},
        "thickness": {"value": 0},
        "thicknessMap": {"value": null},
        "attenuationDistance": {"value": 0},
        "attenuationColor": {"value": Color.fromHex(0x000000)},
        "specularIntensity": {"value": 1.0},
        "specularIntensityMap": {"value": null},
        "specularColor": {"value": Color(1, 1, 1)},
        "specularColorMap": {"value": null}
      }
    ]),
    "vertexShader": ShaderChunk["meshphysical_vert"],
    "fragmentShader": ShaderChunk["meshphysical_frag"]
  }
};
