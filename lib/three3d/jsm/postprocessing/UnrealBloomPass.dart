part of jsm_postprocessing;


/**
 * UnrealBloomPass is inspired by the bloom pass of Unreal Engine. It creates a
 * mip map chain of bloom textures and blurs them with different radii. Because
 * of the weighted combination of mips, and because larger blurs are done on
 * higher mips, this effect provides good quality and performance.
 *
 * Reference:
 * - https://docs.unrealengine.com/latest/INT/Engine/Rendering/PostProcessEffects/Bloom/
 */
class UnrealBloomPass extends Pass {

  static Vector2 BlurDirectionX = new Vector2( 1.0, 0.0 );
  static Vector2 BlurDirectionY = new Vector2( 0.0, 1.0 );

  late Vector2 resolution;
	late double strength;
	late double radius;
	late double threshold;
	late Color clearColor;
	late List<WebGLRenderTarget> renderTargetsHorizontal;
	late List<WebGLRenderTarget> renderTargetsVertical;
	late num nMips;
	late WebGLRenderTarget renderTargetBright;
	late Map<String, dynamic> highPassUniforms;
	late ShaderMaterial materialHighPassFilter;
	late List<ShaderMaterial> separableBlurMaterials;
	late ShaderMaterial compositeMaterial;
	late List<Vector3> bloomTintColors;
  late Map<String, dynamic> copyUniforms;
	late ShaderMaterial materialCopy;
	late Color oldClearColor;
	late num oldClearAlpha;
	late MeshBasicMaterial basic;


  UnrealBloomPass(Vector2? resolution, double? strength, double radius, double threshold ) : super() {
    this.strength = ( strength != null ) ? strength : 1.0;
    this.radius = radius;
    this.threshold = threshold;
    this.resolution = ( resolution != null ) ? new Vector2( resolution.x, resolution.y ) : new Vector2( 256, 256 );

    this.uniforms = {
      "strength": {"value": strength}
    };

    // create color only once here, reuse it later inside the render function
    this.clearColor = new Color( 0, 0, 0 );

    // render targets
    var pars = WebGLRenderTargetOptions(
      { "minFilter": LinearFilter, "magFilter": LinearFilter, "format": RGBAFormat }
    );
    this.renderTargetsHorizontal = [];
    this.renderTargetsVertical = [];
    this.nMips = 5;
    var resx = Math.round( this.resolution.x / 2 ).toInt();
    var resy = Math.round( this.resolution.y / 2 ).toInt();

    this.renderTargetBright = new WebGLRenderTarget( resx, resy, pars );
    this.renderTargetBright.texture.name = 'UnrealBloomPass.bright';
    this.renderTargetBright.texture.generateMipmaps = false;

    for ( var i = 0; i < this.nMips; i ++ ) {

      var renderTargetHorizonal = new WebGLRenderTarget( resx, resy, pars );

      renderTargetHorizonal.texture.name = 'UnrealBloomPass.h' + i.toString();
      renderTargetHorizonal.texture.generateMipmaps = false;

      this.renderTargetsHorizontal.add( renderTargetHorizonal );

      var renderTargetVertical = new WebGLRenderTarget( resx, resy, pars );

      renderTargetVertical.texture.name = 'UnrealBloomPass.v' + i.toString();
      renderTargetVertical.texture.generateMipmaps = false;

      this.renderTargetsVertical.add( renderTargetVertical );

      resx = Math.round( resx / 2 ).toInt();

      resy = Math.round( resy / 2 ).toInt();

    }

    // luminosity high pass material

    if ( LuminosityHighPassShader == null ) {
      print( 'THREE.UnrealBloomPass relies on LuminosityHighPassShader' );
    }

    var highPassShader = LuminosityHighPassShader;
    this.highPassUniforms = UniformsUtils.clone( highPassShader["uniforms"] );

    this.highPassUniforms[ 'luminosityThreshold' ]["value"] = threshold;
    this.highPassUniforms[ 'smoothWidth' ]["value"] = 0.01;

    this.materialHighPassFilter = new ShaderMaterial( {
      "uniforms": this.highPassUniforms,
      "vertexShader": highPassShader["vertexShader"],
      "fragmentShader": highPassShader["fragmentShader"],
      "defines": Map<String, dynamic>()
    } );

    // Gaussian Blur Materials
    this.separableBlurMaterials = [];
    var kernelSizeArray = [ 3, 5, 7, 9, 11 ];
    resx = Math.round( this.resolution.x / 2 );
    resy = Math.round( this.resolution.y / 2 );

    for ( var i = 0; i < this.nMips; i ++ ) {

      this.separableBlurMaterials.add( this.getSeperableBlurMaterial( kernelSizeArray[ i ] ) );

      this.separableBlurMaterials[ i ].uniforms![ 'texSize' ]["value"] = new Vector2( resx.toDouble(), resy.toDouble() );

      resx = Math.round( resx / 2 );

      resy = Math.round( resy / 2 );

    }

    // Composite material
    this.compositeMaterial = this.getCompositeMaterial( this.nMips );
    this.compositeMaterial.uniforms![ 'blurTexture1' ]["value"] = this.renderTargetsVertical[ 0 ].texture;
    this.compositeMaterial.uniforms![ 'blurTexture2' ]["value"] = this.renderTargetsVertical[ 1 ].texture;
    this.compositeMaterial.uniforms![ 'blurTexture3' ]["value"] = this.renderTargetsVertical[ 2 ].texture;
    this.compositeMaterial.uniforms![ 'blurTexture4' ]["value"] = this.renderTargetsVertical[ 3 ].texture;
    this.compositeMaterial.uniforms![ 'blurTexture5' ]["value"] = this.renderTargetsVertical[ 4 ].texture;
    this.compositeMaterial.uniforms![ 'bloomStrength' ]["value"] = strength;
    this.compositeMaterial.uniforms![ 'bloomRadius' ]["value"] = 0.1;
    this.compositeMaterial.needsUpdate = true;

    var bloomFactors = [ 1.0, 0.8, 0.6, 0.4, 0.2 ];
    this.compositeMaterial.uniforms![ 'bloomFactors' ]["value"] = bloomFactors;
    this.bloomTintColors = [ new Vector3( 1, 1, 1 ), new Vector3( 1, 1, 1 ), new Vector3( 1, 1, 1 ),
                new Vector3( 1, 1, 1 ), new Vector3( 1, 1, 1 ) ];
    this.compositeMaterial.uniforms![ 'bloomTintColors' ]["value"] = this.bloomTintColors;

    // copy material
    if ( CopyShader == null ) {
      print( 'THREE.UnrealBloomPass relies on CopyShader' );
    }

    var copyShader = CopyShader;

    this.copyUniforms = UniformsUtils.clone( copyShader["uniforms"] );
    this.copyUniforms[ 'opacity' ]["value"] = 1.0;

    this.materialCopy = new ShaderMaterial( {
      "uniforms": this.copyUniforms,
      "vertexShader": copyShader["vertexShader"],
      "fragmentShader": copyShader["fragmentShader"],
      "blending": AdditiveBlending,
      "depthTest": false,
      "depthWrite": false,
      "transparent": true
    } );

    this.enabled = true;
    this.needsSwap = false;

    this.oldClearColor = Color.fromHex(0xffffff);
    this.oldClearAlpha = 0.0;

    this.basic = new MeshBasicMaterial(Map<String, dynamic>());

    this.fsQuad = FullScreenQuad( null );
  }

  dispose() {

		for ( var i = 0; i < this.renderTargetsHorizontal.length; i ++ ) {

			this.renderTargetsHorizontal[ i ].dispose();

		}

		for ( var i = 0; i < this.renderTargetsVertical.length; i ++ ) {

			this.renderTargetsVertical[ i ].dispose();

		}

		this.renderTargetBright.dispose();

	}

	setSize( width, height ) {

		var resx = Math.round( width / 2 );
		var resy = Math.round( height / 2 );

		this.renderTargetBright.setSize( resx, resy );

		for ( var i = 0; i < this.nMips; i ++ ) {

			this.renderTargetsHorizontal[ i ].setSize( resx, resy );
			this.renderTargetsVertical[ i ].setSize( resx, resy );

			this.separableBlurMaterials[ i ].uniforms![ 'texSize' ]["value"] = new Vector2( resx.toDouble(), resy.toDouble() );

			resx = Math.round( resx / 2 );
			resy = Math.round( resy / 2 );

		}

	}

	render( renderer, writeBuffer, readBuffer, {num? deltaTime, bool? maskActive} ) {

		renderer.getClearColor( this.oldClearColor );
		this.oldClearAlpha = renderer.getClearAlpha();
		var oldAutoClear = renderer.autoClear;
		renderer.autoClear = false;

		renderer.setClearColor( this.clearColor, alpha: 1 );

		if ( maskActive == true ) renderer.state.buffers.stencil.setTest( false );

		// Render input to screen

		if ( this.renderToScreen ) {

			this.fsQuad.material = this.basic;
			this.basic.map = readBuffer.texture;

			renderer.setRenderTarget( null );
			renderer.clear(null, null, null);
			this.fsQuad.render( renderer );

		}

		// 1. Extract Bright Areas

		this.highPassUniforms[ 'tDiffuse' ]["value"] = readBuffer.texture;
		this.highPassUniforms[ 'luminosityThreshold' ]["value"] = this.threshold;
		this.fsQuad.material = this.materialHighPassFilter;

		renderer.setRenderTarget( this.renderTargetBright );
		renderer.clear(null, null, null);
		this.fsQuad.render( renderer );

		// 2. Blur All the mips progressively

		var inputRenderTarget = this.renderTargetBright;

		for ( var i = 0; i < this.nMips; i ++ ) {

			this.fsQuad.material = this.separableBlurMaterials[ i ];

			this.separableBlurMaterials[ i ].uniforms![ 'colorTexture' ]["value"] = inputRenderTarget.texture;
			this.separableBlurMaterials[ i ].uniforms![ 'direction' ]["value"] = UnrealBloomPass.BlurDirectionX;
			renderer.setRenderTarget( this.renderTargetsHorizontal[ i ] );
			renderer.clear(null, null, null);
			this.fsQuad.render( renderer );

			this.separableBlurMaterials[ i ].uniforms![ 'colorTexture' ]["value"] = this.renderTargetsHorizontal[ i ].texture;
			this.separableBlurMaterials[ i ].uniforms![ 'direction' ]["value"] = UnrealBloomPass.BlurDirectionY;
			renderer.setRenderTarget( this.renderTargetsVertical[ i ] );
			renderer.clear(null, null, null);
			this.fsQuad.render( renderer );

			inputRenderTarget = this.renderTargetsVertical[ i ];

		}

		// Composite All the mips

		this.fsQuad.material = this.compositeMaterial;
		this.compositeMaterial.uniforms![ 'bloomStrength' ]["value"] = this.strength;
		this.compositeMaterial.uniforms![ 'bloomRadius' ]["value"] = this.radius;
		this.compositeMaterial.uniforms![ 'bloomTintColors' ]["value"] = this.bloomTintColors;

		renderer.setRenderTarget( this.renderTargetsHorizontal[ 0 ] );
		renderer.clear(null, null, null);
		this.fsQuad.render( renderer );

		// Blend it additively over the input texture

		this.fsQuad.material = this.materialCopy;
		this.copyUniforms[ 'tDiffuse' ]["value"] = this.renderTargetsHorizontal[ 0 ].texture;

		if ( maskActive == true ) renderer.state.buffers.stencil.setTest( true );

		if ( this.renderToScreen ) {

			renderer.setRenderTarget( null );
			this.fsQuad.render( renderer );

		} else {

			renderer.setRenderTarget( readBuffer );
			this.fsQuad.render( renderer );

		}

		// Restore renderer settings

		renderer.setClearColor( this.oldClearColor, alpha: this.oldClearAlpha );
		renderer.autoClear = oldAutoClear;

	}

	getSeperableBlurMaterial( kernelRadius ) {

		return new ShaderMaterial( {
			"defines": {
				'KERNEL_RADIUS': kernelRadius,
				'SIGMA': kernelRadius
			},
			"uniforms": {
				'colorTexture': { },
				'texSize': { "value": new Vector2( 0.5, 0.5 ) },
				'direction': { "value": new Vector2( 0.5, 0.5 ) }
			},

			"vertexShader": """
				varying vec2 vUv;
				void main() {
					vUv = uv;
					gl_Position = projectionMatrix * modelViewMatrix * vec4( position, 1.0 );
				}
      """,
			"fragmentShader": """
				#include <common>
				varying vec2 vUv;
				uniform sampler2D colorTexture;
				uniform vec2 texSize;
				uniform vec2 direction;
				
				float gaussianPdf(in float x, in float sigma) {
					return 0.39894 * exp( -0.5 * x * x/( sigma * sigma))/sigma;
				}
				void main() {
					vec2 invSize = 1.0 / texSize;
					float fSigma = float(SIGMA);
					float weightSum = gaussianPdf(0.0, fSigma);
					vec3 diffuseSum = texture2D( colorTexture, vUv).rgb * weightSum;
					for( int i = 1; i < KERNEL_RADIUS; i ++ ) {
						float x = float(i);
						float w = gaussianPdf(x, fSigma);
						vec2 uvOffset = direction * invSize * x;
						vec3 sample1 = texture2D( colorTexture, vUv + uvOffset).rgb;
						vec3 sample2 = texture2D( colorTexture, vUv - uvOffset).rgb;
						diffuseSum += (sample1 + sample2) * w;
						weightSum += 2.0 * w;
					}
					gl_FragColor = vec4(diffuseSum/weightSum, 1.0);
				}
        
      """  
		} );

	}

	getCompositeMaterial( nMips ) {

		return new ShaderMaterial( {

			"defines": {
				'NUM_MIPS': nMips
			},

			"uniforms": {
				'blurTexture1': { },
				'blurTexture2': { },
				'blurTexture3': { },
				'blurTexture4': { },
				'blurTexture5': { },
				'dirtTexture': {  },
				'bloomStrength': { "value": 1.0 },
				'bloomFactors': {  },
				'bloomTintColors': {  },
				'bloomRadius': { "value": 0.0 }
			},

			"vertexShader": """
				varying vec2 vUv;
				void main() {
					vUv = uv;
					gl_Position = projectionMatrix * modelViewMatrix * vec4( position, 1.0 );
				}
        """,

			"fragmentShader": """
				varying vec2 vUv;
				uniform sampler2D blurTexture1;
				uniform sampler2D blurTexture2;
				uniform sampler2D blurTexture3;
				uniform sampler2D blurTexture4;
				uniform sampler2D blurTexture5;
				uniform sampler2D dirtTexture;
				uniform float bloomStrength;
				uniform float bloomRadius;
				uniform float bloomFactors[NUM_MIPS];
				uniform vec3 bloomTintColors[NUM_MIPS];
				
				float lerpBloomFactor(const in float factor) {
					float mirrorFactor = 1.2 - factor;
					return mix(factor, mirrorFactor, bloomRadius);
				}
				
				void main() {
					gl_FragColor = bloomStrength * ( lerpBloomFactor(bloomFactors[0]) * vec4(bloomTintColors[0], 1.0) * texture2D(blurTexture1, vUv) + 
													 lerpBloomFactor(bloomFactors[1]) * vec4(bloomTintColors[1], 1.0) * texture2D(blurTexture2, vUv) + 
													 lerpBloomFactor(bloomFactors[2]) * vec4(bloomTintColors[2], 1.0) * texture2D(blurTexture3, vUv) + 
													 lerpBloomFactor(bloomFactors[3]) * vec4(bloomTintColors[3], 1.0) * texture2D(blurTexture4, vUv) + 
													 lerpBloomFactor(bloomFactors[4]) * vec4(bloomTintColors[4], 1.0) * texture2D(blurTexture5, vUv) );
				}
      """
		} );

	}


}



