part of jsm_postprocessing;


class FilmPass extends Pass {

	FilmPass( noiseIntensity, scanlinesIntensity, scanlinesCount, grayscale ) : super() {

    if ( FilmShader == null ) print( 'THREE.FilmPass relies on FilmShader' );
      

    var shader = FilmShader;

    this.uniforms = UniformsUtils.clone( shader["uniforms"] );

    this.material = new ShaderMaterial( {

      "uniforms": this.uniforms,
      "vertexShader": shader["vertexShader"],
      "fragmentShader": shader["fragmentShader"]

    } );

    if ( grayscale != null )	this.uniforms["grayscale"]["value"] = grayscale;
    if ( noiseIntensity != null ) this.uniforms["nIntensity"]["value"] = noiseIntensity;
    if ( scanlinesIntensity != null ) this.uniforms["sIntensity"]["value"] = scanlinesIntensity;
    if ( scanlinesCount != null ) this.uniforms["sCount"]["value"] = scanlinesCount;

    this.fsQuad = new FullScreenQuad( this.material );
  }


  render ( renderer, writeBuffer, readBuffer, {num? deltaTime, bool? maskActive}) {

		this.uniforms[ 'tDiffuse' ]["value"] = readBuffer.texture;
		this.uniforms[ 'time' ]["value"] += deltaTime;

		if ( this.renderToScreen ) {

			renderer.setRenderTarget( null );
			this.fsQuad.render( renderer );

		} else {

			renderer.setRenderTarget( writeBuffer );
			if ( this.clear ) renderer.clear();
			this.fsQuad.render( renderer );

		}

	}


}
