part of jsm_loader;

// https://wwwimages2.adobe.com/content/dam/acom/en/products/speedgrade/cc/pdfs/cube-lut-specification-1.0.pdf




class LUTCubeLoader extends Loader {

  LUTCubeLoader(manager) : super(manager) {

  }

	load( String url, Function? onLoad, Function? onProgress, Function? onError ) async {

		var loader = new FileLoader( this.manager );
		loader.setPath( this.path );
		loader.setResponseType( 'text' );
		final data = await loader.load( url, (text) {

			// try {
        if(onLoad != null) {
          onLoad( this.parse( text ) );
        }
			// } catch ( e ) {

			// 	if ( onError != null ) {

			// 		onError( e );

			// 	} else {

			// 		print( e );

			// 	}

			// 	this.manager.itemError( url );

			// }

		}, onProgress, onError );

    return data;
	}

	parse(  str, {String? path, Function? onLoad, Function? onError} ) {

		// Remove empty lines and comments
		// str = str
		// 	.replace( /^#.*?(\n|\r)/gm, '' )
		// 	.replace( /^\s*?(\n|\r)/gm, '' )
		// 	.trim();
    
    final reg = RegExp(r"^#.*?(\n|\r)", multiLine: true);
    str = str.replaceAll(reg, "");

    final reg2 = RegExp(r"^\s*?(\n|\r)", multiLine: true);
    str = str.replaceAll(reg2, "");
    str = str.trim();

		var title = null;
		int size = 0;
		var domainMin = new Vector3( 0, 0, 0 );
		var domainMax = new Vector3( 1, 1, 1 );

    final reg3 = RegExp(r"[\n\r]+");
		var lines = str.split( reg3 );
		Uint8List? data;

		var currIndex = 0;
		for ( var i = 0, l = lines.length; i < l; i ++ ) {

			var line = lines[ i ].trim();
			var split = line.split( RegExp(r"\s") );

			switch ( split[ 0 ] ) {

				case 'TITLE':
					title = line.substring( 7, line.length - 1 );
					break;
				case 'LUT_3D_SIZE':
					// TODO: A .CUBE LUT file specifies floating point values and could be represented with
					// more precision than can be captured with Uint8Array.
					var sizeToken = split[ 1 ];
					size = parseFloat( sizeToken ).toInt();
					data = Uint8List( size * size * size * 3 );
					break;
				case 'DOMAIN_MIN':
					domainMin.x = parseFloat( split[ 1 ] );
					domainMin.y = parseFloat( split[ 2 ] );
					domainMin.z = parseFloat( split[ 3 ] );
					break;
				case 'DOMAIN_MAX':
					domainMax.x = parseFloat( split[ 1 ] );
					domainMax.y = parseFloat( split[ 2 ] );
					domainMax.z = parseFloat( split[ 3 ] );
					break;
				default:
					var r = parseFloat( split[ 0 ] );
					var g = parseFloat( split[ 1 ] );
					var b = parseFloat( split[ 2 ] );

					if (
						r > 1.0 || r < 0.0 ||
						g > 1.0 || g < 0.0 ||
						b > 1.0 || b < 0.0
					) {

						throw ( 'LUTCubeLoader : Non normalized values not supported.' );

					}

					data![ currIndex + 0 ] = (r * 255).toInt();
					data[ currIndex + 1 ] = (g * 255).toInt();
					data[ currIndex + 2 ] = (b * 255).toInt();
					currIndex += 3;

			}

		}

		var texture = new DataTexture(null, null,null, null,null, null,null, null,null, null,null, null);
		texture.image!.data = data;
		texture.image!.width = size;
		texture.image!.height = size * size;
		texture.format = RGBFormat;
		texture.type = UnsignedByteType;
		texture.magFilter = LinearFilter;
		texture.wrapS = ClampToEdgeWrapping;
		texture.wrapT = ClampToEdgeWrapping;
		texture.generateMipmaps = false;

		var texture3D = new DataTexture3D();
		texture3D.image!.data = data;
		texture3D.image!.width = size;
		texture3D.image!.height = size;
		texture3D.image!.depth = size;
		texture3D.format = RGBFormat;
		texture3D.type = UnsignedByteType;
		texture3D.magFilter = LinearFilter;
		texture3D.wrapS = ClampToEdgeWrapping;
		texture3D.wrapT = ClampToEdgeWrapping;
		texture3D.wrapR = ClampToEdgeWrapping;
		texture3D.generateMipmaps = false;

		return {
			"title": title,
			"size": size,
			"domainMin": domainMin,
			"domainMax": domainMax,
			"texture": texture,
			"texture3D": texture3D,
		};

	}

}
