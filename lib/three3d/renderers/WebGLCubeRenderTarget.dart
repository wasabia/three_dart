part of three_renderers;

class WebGLCubeRenderTarget extends WebGLRenderTarget {

  bool isWebGLCubeRenderTarget = true;

  WebGLCubeRenderTarget(size, options, dummy) : super(size, size, options) {
    if ( options is num ) {

      print( 'THREE.WebGLCubeRenderTarget: constructor signature is now WebGLCubeRenderTarget( size, options )' );

      options = dummy;

    }

    options = options ?? {};

    this.texture = CubeTexture( null, options.mapping, options.wrapS, options.wrapT, options.magFilter, options.minFilter, options.format, options.type, options.anisotropy, options.encoding );

    this.texture.generateMipmaps = options.generateMipmaps ?? false;
		this.texture.minFilter = options.minFilter ?? LinearFilter;

    CubeTexture cubeTexture = texture as CubeTexture;
	  cubeTexture.needsFlipEnvMap = false;

  }


    
  fromEquirectangularTexture ( renderer, texture ) {

    this.texture.type = texture.type;
    this.texture.format = RGBAFormat; // see #18859
    this.texture.encoding = texture.encoding;

    this.texture.generateMipmaps = texture.generateMipmaps;
    this.texture.minFilter = texture.minFilter;
    this.texture.magFilter = texture.magFilter;

    var shader = {

      "uniforms": {
        "tEquirect": { "value": null },
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

    var geometry = new BoxGeometry( width: 5, height: 5, depth: 5 );

    var material = new ShaderMaterial( {

      "name": 'CubemapFromEquirect',

      "uniforms": cloneUniforms( shader["uniforms"] as Map<String, dynamic> ),
      "vertexShader": shader["vertexShader"],
      "fragmentShader": shader["fragmentShader"],
      "side": BackSide,
      "blending": NoBlending

    } );

    material.uniforms!["tEquirect"]["value"] = texture;

    var mesh = Mesh( geometry, material );

    var currentMinFilter = texture.minFilter;

    // Avoid blurred poles
    if ( texture.minFilter == LinearMipmapLinearFilter ) texture.minFilter = LinearFilter;

    var camera = CubeCamera( 1, 10, this );
    camera.update( renderer, mesh );

    texture.minFilter = currentMinFilter;

    mesh.geometry.dispose();
    mesh.material.dispose();

    return this;

  }

  clear ( renderer, color, depth, stencil ) {

    var currentRenderTarget = renderer.getRenderTarget();

    for ( var i = 0; i < 6; i ++ ) {

      renderer.setRenderTarget( this, i );

      renderer.clear( color, depth, stencil );

    }

    renderer.setRenderTarget( currentRenderTarget );

  }
	

}

