part of three_shaders;

/// Uniforms library for shared webgl shaders

Map<String, dynamic> UniformsLib = {
  "common": {
    "diffuse": {"value": Color.fromHex(0xffffff)},
    "opacity": {"value": 1.0},
    "map": {},
    "uvTransform": {"value": Matrix3()},
    "uv2Transform": {"value": Matrix3()},
    "alphaMap": {},
    "alphaTest": {"value": 0.0}
  },
  "specularmap": {
    "specularMap": {},
  },
  "envmap": {
    "envMap": {},
    "flipEnvMap": {"value": -1},
    "reflectivity": {"value": 1.0}, // basic, lambert, phong
    "ior": {"value": 1.5}, // standard, physical
    "refractionRatio": {"value": 0.98},
  },
  "aomap": {
    "aoMap": {},
    "aoMapIntensity": {"value": 1}
  },
  "lightmap": {
    "lightMap": {},
    "lightMapIntensity": {"value": 1}
  },
  "emissivemap": {"emissiveMap": {}},
  "bumpmap": {
    "bumpMap": {},
    "bumpScale": {"value": 1}
  },
  "normalmap": {
    "normalMap": {},
    "normalScale": {"value": Vector2(1, 1)}
  },
  "displacementmap": {
    "displacementMap": {},
    "displacementScale": {"value": 1},
    "displacementBias": {"value": 0}
  },
  "roughnessmap": {"roughnessMap": {}},
  "metalnessmap": {"metalnessMap": {}},
  "gradientmap": {"gradientMap": {}},
  "fog": {
    "fogDensity": {"value": 0.00025},
    "fogNear": {"value": 1},
    "fogFar": {"value": 2000},
    "fogColor": {"value": Color(0, 0, 0)}
  },
  "lights": {
    "ambientLightColor": {"value": []},

    "lightProbe": {"value": []},

    "directionalLights": {
      "value": [],
      "properties": {"direction": {}, "color": {}}
    },

    "directionalLightShadows": {
      "value": [],
      "properties": {
        "shadowBias": {},
        "shadowNormalBias": {},
        "shadowRadius": {},
        "shadowMapSize": {}
      }
    },

    "directionalShadowMap": {"value": []},
    "directionalShadowMatrix": {"value": []},

    "spotLights": {
      "value": [],
      "properties": {
        "color": {},
        "position": {},
        "direction": {},
        "distance": {},
        "coneCos": {},
        "penumbraCos": {},
        "decay": {}
      }
    },

    "spotLightShadows": {
      "value": [],
      "properties": {
        "shadowBias": {},
        "shadowNormalBias": {},
        "shadowRadius": {},
        "shadowMapSize": {}
      }
    },

    "spotShadowMap": {"value": []},
    "spotShadowMatrix": {"value": []},

    "pointLights": {
      "value": [],
      "properties": {"color": {}, "position": {}, "decay": {}, "distance": {}}
    },

    "pointLightShadows": {
      "value": [],
      "properties": {
        "shadowBias": {},
        "shadowNormalBias": {},
        "shadowRadius": {},
        "shadowMapSize": {},
        "shadowCameraNear": {},
        "shadowCameraFar": {}
      }
    },

    "pointShadowMap": {"value": []},
    "pointShadowMatrix": {"value": []},

    "hemisphereLights": {
      "value": [],
      "properties": {"direction": {}, "skyColor": {}, "groundColor": {}}
    },

    // TODO (abelnation): RectAreaLight BRDF data needs to be moved from example to main src
    "rectAreaLights": {
      "value": [],
      "properties": {"color": {}, "position": {}, "width": {}, "height": {}}
    },

    "ltc_1": {},
    "ltc_2": {}
  },
  "points": {
    "diffuse": {"value": Color.fromHex(0xffffff)},
    "opacity": {"value": 1.0},
    "size": {"value": 1.0},
    "scale": {"value": 1.0},
    "map": {},
    "alphaMap": {},
    "alphaTest": {"value": 0.0},
    "uvTransform": {"value": Matrix3()}
  },
  "sprite": {
    "diffuse": {"value": Color.fromHex(0xffffff)},
    "opacity": {"value": 1.0},
    "center": {"value": Vector2(0.5, 0.5)},
    "rotation": {"value": 0.0},
    "map": {},
    "alphaMap": {},
    "alphaTest": {"value": 0.0},
    "uvTransform": {"value": Matrix3()}
  }
};
