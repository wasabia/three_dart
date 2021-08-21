part of three_webgl;


class WebGLCubeUVMaps {

	var cubeUVmaps = new WeakMap();
  WebGLRenderer renderer;
	var pmremGenerator = null;

  WebGLCubeUVMaps( this.renderer ) {

  }


	get( texture ) {

		if ( texture && texture.isTexture && texture.isRenderTargetTexture == false ) {

			var mapping = texture.mapping;

			var isEquirectMap = ( mapping == EquirectangularReflectionMapping || mapping == EquirectangularRefractionMapping );
			var isCubeMap = ( mapping == CubeReflectionMapping || mapping == CubeRefractionMapping );

			if ( isEquirectMap || isCubeMap ) {

				// equirect/cube map to cubeUV conversion

				if ( cubeUVmaps.has( texture ) ) {

					return cubeUVmaps.get( texture ).texture;

				} else {

					var image = texture.image;

					if ( ( isEquirectMap && image && image.height > 0 ) || ( isCubeMap && image && isCubeTextureComplete( image ) ) ) {

						var currentRenderTarget = renderer.getRenderTarget();

						if ( pmremGenerator == null ) pmremGenerator = new PMREMGenerator( renderer );

						var renderTarget = isEquirectMap ? pmremGenerator.fromEquirectangular( texture ) : pmremGenerator.fromCubemap( texture );
						cubeUVmaps.add( key: texture, value: renderTarget );

						renderer.setRenderTarget( currentRenderTarget );

						texture.addEventListener( 'dispose', onTextureDispose );

						return renderTarget.texture;

					} else {

						// image not yet ready. try the conversion next frame

						return null;

					}

				}

			}

		}

		return texture;

	}

	isCubeTextureComplete( image ) {

		var count = 0;
		var length = 6;

		for ( var i = 0; i < length; i ++ ) {

			if ( image[ i ] != null ) count ++;

		}

		return count == length;


	}

	onTextureDispose( event ) {

		var texture = event.target;

		texture.removeEventListener( 'dispose', onTextureDispose );

		var cubemapUV = cubeUVmaps.get( texture );

		if ( cubemapUV != null ) {

			cubemapUV.delete( texture );
			cubemapUV.dispose();

		}

	}

	dispose() {

		cubeUVmaps = new WeakMap();

		if ( pmremGenerator != null ) {

			pmremGenerator.dispose();
			pmremGenerator = null;

		}

	}

}
