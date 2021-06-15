part of jsm_postprocessing;

class ShaderPass extends Pass {

  late dynamic textureID;
  late Map<String, dynamic> uniforms;
  late Material material;
  late FullScreenQuad fsQuad;

  ShaderPass( shader, textureID ) : super() {

    this.textureID = ( textureID != null ) ? textureID : 'tDiffuse';

    if ( shader.runtimeType.toString() == "ShaderMaterial" ) {

      this.uniforms = shader.uniforms;

      this.material = shader;

    } else if ( shader != null ) {

      this.uniforms = UniformsUtils.clone( shader["uniforms"] );

      Map<String, dynamic> _defines = {};
      _defines.addAll(shader["defines"] ?? {});
      this.material = new ShaderMaterial( {
        "defines": _defines,
        "uniforms": this.uniforms,
        "vertexShader": shader["vertexShader"],
        "fragmentShader": shader["fragmentShader"]
      } );

    }

    this.fsQuad = new FullScreenQuad( this.material );
  }


  render( renderer, writeBuffer, readBuffer, {num? deltaTime, bool? maskActive} ) {

		if ( this.uniforms[ this.textureID ] != null ) {

			this.uniforms[ this.textureID ]["value"] = readBuffer.texture;

		}

		this.fsQuad.material = this.material;

		if ( this.renderToScreen ) {

			renderer.setRenderTarget( null );
			this.fsQuad.render( renderer );

		} else {

			renderer.setRenderTarget( writeBuffer );
			// TODO: Avoid using autoClear properties, see https://github.com/mrdoob/three.js/pull/15571#issuecomment-465669600
			if ( this.clear ) renderer.clear( renderer.autoClearColor, renderer.autoClearDepth, renderer.autoClearStencil );
			this.fsQuad.render( renderer );

		}

	}

}
