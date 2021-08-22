part of three_webgl;

numericalSort( a, b ) {

	return a[ 0 ] - b[ 0 ];

}

int absNumericalSort( a, b ) {

  if(Math.abs( b[ 1 ] ) - Math.abs( a[ 1 ] ) == 0) return 0;

	return ( Math.abs( b[ 1 ] ) - Math.abs( a[ 1 ] ) ) > 0 ? 1 : -1;

}

class WebGLMorphtargets {

  dynamic gl;

	var influencesList = {};
	var morphInfluences = new Float32Array( 8 );

	var workInfluences = List<List<num>>.filled(8, [0.0, 0.0]);

  WebGLMorphtargets( this.gl ) {
    for ( var i = 0; i < 8; i ++ ) {
      workInfluences[ i ] = [ i, 0 ];
    }
  }


	

	update( object, geometry, Material material, program ) {

		var objectInfluences = object.morphTargetInfluences;

		// When object doesn't have morph target influences defined, we treat it as a 0-length array
		// This is important to make sure we set up morphTargetBaseInfluence / morphTargetInfluences

		var length = objectInfluences == null ? 0 : objectInfluences.length;

		var influences = influencesList[ geometry.id ];

		if ( influences == null || influences.length != length ) {

			// initialise list

			influences = [];

			for ( var i = 0; i < length; i ++ ) {

				// influences[ i ] = [ i, 0 ];
        influences.add([i, 0.0]);
        
			}

			influencesList[ geometry.id ] = influences;

		}

		// Collect influences

		for ( var i = 0; i < length; i ++ ) {
			var influence = influences[ i ];

			influence[ 0 ] = i;
			influence[ 1 ] = objectInfluences[ i ];



		}

		influences.sort( (a,b) => absNumericalSort(a,b) );

		for ( var i = 0; i < 8; i ++ ) {

			if ( i < length && influences[ i ][ 1 ] != null ) {

				workInfluences[ i ][ 0 ] = influences[ i ][ 0 ];
				workInfluences[ i ][ 1 ] = influences[ i ][ 1 ];

			} else {

				workInfluences[ i ][ 0 ] = MAX_SAFE_INTEGER;
				workInfluences[ i ][ 1 ] = 0;

			}

		}

		workInfluences.sort( (a,b) => numericalSort(a,b) );

		var morphTargets = geometry.morphAttributes["position"];
		var morphNormals = geometry.morphAttributes["normal"];

		num morphInfluencesSum = 0.0;

		for ( var i = 0; i < 8; i ++ ) {

			var influence = workInfluences[ i ];
			var index = influence[ 0 ];
			var value = influence[ 1 ];

			if ( index != MAX_SAFE_INTEGER && value != null ) {

				if ( morphTargets && geometry.getAttribute( 'morphTarget${i}' ) != morphTargets[ index ] ) {

					geometry.setAttribute( 'morphTarget${i}', morphTargets[ index ] );

				}

				if ( morphNormals && geometry.getAttribute( 'morphNormal${i}' ) != morphNormals[ index ] ) {

					geometry.setAttribute( 'morphNormal${i}', morphNormals[ index ] );

				}

				morphInfluences[i] = value;
				morphInfluencesSum += value;

			} else {

				if ( morphTargets && geometry.hasAttribute( 'morphTarget${i}' ) == true ) {

					geometry.deleteAttribute( 'morphTarget${i}' );

				}

  
				if ( morphNormals && geometry.hasAttribute( 'morphNormal${i}' ) == true ) {

					geometry.deleteAttribute( 'morphNormal${i}' );

				}

				morphInfluences[i] = 0;

			}

		}

		// GLSL shader uses formula baseinfluence * base + sum(target * influence)
		// This allows us to switch between absolute morphs and relative morphs without changing shader code
		// When baseinfluence = 1 - sum(influence), the above is equivalent to sum((target - base) * influence)
		var morphBaseInfluence = geometry.morphTargetsRelative ? 1 : 1 - morphInfluencesSum;

		program.getUniforms().setValue( gl, 'morphTargetBaseInfluence', morphBaseInfluence, null );
		program.getUniforms().setValue( gl, 'morphTargetInfluences', morphInfluences.data, null );

	}



}


