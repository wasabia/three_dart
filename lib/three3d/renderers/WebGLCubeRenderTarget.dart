part of three_renderers;

class WebGLCubeRenderTarget extends WebGLRenderTarget {
  WebGLCubeRenderTarget(double size, options, dummy) : super(size, size, options) {
    isWebGLCubeRenderTarget = true;
    // By convention -- likely based on the RenderMan spec from the 1990's -- cube maps are specified by WebGL (and three.js)
    // in a coordinate system in which positive-x is to the right when looking up the positive-z axis -- in other words,
    // in a left-handed coordinate system. By continuing this convention, preexisting cube maps continued to render correctly.

    // three.js uses a right-handed coordinate system. So environment maps used in three.js appear to have px and nx swapped
    // and the flag isRenderTargetTexture controls this conversion. The flip is not required when using WebGLCubeRenderTarget.texture
    // as a cube texture (this is detected when isRenderTargetTexture is set to true for cube textures).
    var image = ImageElement(width: size, height: size, depth: 1);
		var images = [ image, image, image, image, image, image ];

    options = options ?? WebGLRenderTargetOptions({});
    texture = CubeTexture(
        images,
        options.mapping,
        options.wrapS,
        options.wrapT,
        options.magFilter,
        options.minFilter,
        options.format,
        options.type,
        options.anisotropy,
        options.encoding);
    texture.isRenderTargetTexture = true;

    texture.generateMipmaps = options.generateMipmaps ?? false;
    texture.minFilter = options.minFilter ?? LinearFilter;
  }

  WebGLCubeRenderTarget fromEquirectangularTexture(renderer, Texture texture) {
    this.texture.type = texture.type;
    this.texture.format = RGBAFormat; // see #18859
    this.texture.encoding = texture.encoding;

    this.texture.generateMipmaps = texture.generateMipmaps;
    this.texture.minFilter = texture.minFilter;
    this.texture.magFilter = texture.magFilter;

    var shader = {
      "uniforms": {
        "tEquirect": {},
      },
      "vertexShader": """

        varying vec3 vWorldDirection;

        vec3 transformDirection( in vec3 dir, in mat4 matrix ) {

          return normalize( ( matrix * vec4( dir, 0.0 ) ).xyz );

        }

        void main() {

          vWorldDirection = transformDirection( position, modelMatrix );

          #include <begin_vertex>
          #include <project_vertex>

        }
      """,
      "fragmentShader": """

        uniform sampler2D tEquirect;

        varying vec3 vWorldDirection;

        #include <common>

        void main() {

          vec3 direction = normalize( vWorldDirection );

          vec2 sampleUV = equirectUv( direction );

          gl_FragColor = texture2D( tEquirect, sampleUV );

        }
      """
    };

    var geometry = BoxGeometry(5, 5, 5);

    var material = ShaderMaterial({
      "name": 'CubemapFromEquirect',
      "uniforms": cloneUniforms(shader["uniforms"] as Map<String, dynamic>),
      "vertexShader": shader["vertexShader"],
      "fragmentShader": shader["fragmentShader"],
      "side": BackSide,
      "blending": NoBlending
    });

    material.uniforms["tEquirect"]["value"] = texture;

    var mesh = Mesh(geometry, material);

    var currentMinFilter = texture.minFilter;

    // Avoid blurred poles
    if (texture.minFilter == LinearMipmapLinearFilter) {
      texture.minFilter = LinearFilter;
    }

    var camera = CubeCamera(1, 10, this);
    camera.update(renderer, mesh);

    texture.minFilter = currentMinFilter;

    mesh.geometry!.dispose();
    mesh.material.dispose();

    return this;
  }

  void clear(renderer, Color color, int depth, stencil) {
    var currentRenderTarget = renderer.getRenderTarget();

    for (var i = 0; i < 6; i++) {
      renderer.setRenderTarget(this, i);

      renderer.clear(color, depth, stencil);
    }

    renderer.setRenderTarget(currentRenderTarget);
  }
}
