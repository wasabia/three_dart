part of jsm_loader;

/**
 * Requires opentype.js to be included in the project.
 * Loads TTF files and converts them into typeface JSON that can be used directly
 * to create THREE.Font objects.
 */

class TTFLoader extends Loader {

  bool reversed = false;

  TTFLoader(manager) : super(manager) {

  }

  loadAsync( url, Function? onProgress ) async {

		var scope = this;

		var loader = new FileLoader( this.manager );
		loader.setPath( this.path );
		loader.setResponseType( 'arraybuffer' );
		loader.setRequestHeader( this.requestHeader );
		loader.setWithCredentials( this.withCredentials );
		var buffer = await loader.loadAsync( url, null );

    return this._parse( buffer );
	}

  load( url, onLoad, onProgress, onError ) {

		var scope = this;

		var loader = new FileLoader( this.manager );
		loader.setPath( this.path );
		loader.setResponseType( 'arraybuffer' );
		loader.setRequestHeader( this.requestHeader );
		loader.setWithCredentials( this.withCredentials );
		loader.load( url, ( buffer ) {

			// try {

				if(onLoad != null) onLoad( scope._parse( buffer ) );

			// } catch ( e ) {

			// 	if ( onError != null ) {

			// 		onError( e );

			// 	} else {

			// 		print( e );

			// 	}

			// 	scope.manager.itemError( url );

			// }

		}, onProgress, onError );

	}
	
  _parse( arraybuffer ) {
    reverseCommands( commands ) {

			var paths = [];
			var path;

			commands.forEach( ( c ) {

				if ( c.type.toLowerCase() == 'm' ) {

					path = [ c ];
					paths.add( path );

				} else if ( c.type.toLowerCase() != 'z' ) {

					path.push( c );

				}

			} );

			var reversed = [];

			paths.forEach( ( p ) {

				var result = {
					"type": 'm',
					"x": p[ p.length - 1 ].x,
					"y": p[ p.length - 1 ].y
				};

				reversed.add( result );

				for ( var i = p.length - 1; i > 0; i -- ) {

					var command = p[ i ];
					var result = { "type": command.type };

					if ( command.x2 != null && command.y2 != null ) {

						result["x1"] = command.x2;
						result["y1"] = command.y2;
						result["x2"] = command.x1;
						result["y2"] = command.y1;

					} else if ( command.x1 != null && command.y1 != null ) {

						result["x1"] = command.x1;
						result["y1"] = command.y1;

					}

					result["x"] = p[ i - 1 ].x;
					result["y"] = p[ i - 1 ].y;
					reversed.add( result );

				}

			} );

			return reversed;

		}

		convert( font, reversed ) {

			var round = Math.round;

			var glyphs = {};
			var scale = ( 100000 ) / ( ( font.unitsPerEm ?? 2048 ) * 72 );

			var glyphIndexMap = font.encoding.cmap["glyphIndexMap"];
			var unicodes = glyphIndexMap.keys.toList();

			for ( var i = 0; i < unicodes.length; i ++ ) {

				var unicode = unicodes[ i ];
				var glyph = font.glyphs.glyphs[ glyphIndexMap[ unicode ] ];

				if ( unicode != null ) {

					Map<String, dynamic> token = {
						"ha": round( glyph.advanceWidth * scale ),
						"x_min": glyph.xMin != null ? round( glyph.xMin * scale ) : null,
						"x_max": glyph.xMax != null ? round( glyph.xMax * scale ) : null,
						"o": ''
					};

					if ( reversed ) {

						glyph.path.commands = reverseCommands( glyph.path.commands );

					}

          if(glyph.path != null) {
            glyph.path.commands.forEach( ( command ) {

              if ( command["type"].toLowerCase() == 'c' ) {

                command["type"] = 'b';

              }

              token["o"] += command["type"].toLowerCase() + ' ';

              if ( command["x"] != null && command["y"] != null ) {

                token["o"] += round( command["x"] * scale ).toString() + ' ' + round( command["y"] * scale ).toString() + ' ';

              }

              if ( command["x1"] != null && command["y1"] != null ) {

                token["o"] += round( command["x1"] * scale ).toString() + ' ' + round( command["y1"] * scale ).toString() + ' ';

              }

              if ( command["x2"] != null && command["y2"] != null ) {

                token["o"] += round( command["x2"] * scale ).toString() + ' ' + round( command["y2"] * scale ).toString() + ' ';

              }

            } );
          }
					

					glyphs[ String.fromCharCode( glyph.unicode ) ] = token;

				}

			}

			return {
				"glyphs": glyphs,
				"familyName": font.getEnglishName( 'fullName' ),
				"ascender": round( font.ascender * scale ),
				"descender": round( font.descender * scale ),
				"underlinePosition": font.tables["post"]["underlinePosition"],
				"underlineThickness": font.tables["post"]["underlineThickness"],
				"boundingBox": {
					"xMin": font.tables["head"]["xMin"],
					"xMax": font.tables["head"]["xMax"],
					"yMin": font.tables["head"]["yMin"],
					"yMax": font.tables["head"]["yMax"]
				},
				"resolution": 1000,
				"original_font_information": font.tables["name"]
			};

		}

		return convert( opentype.parseBuffer( arraybuffer, null ), this.reversed ); // eslint-disable-line no-undef

	}

}

