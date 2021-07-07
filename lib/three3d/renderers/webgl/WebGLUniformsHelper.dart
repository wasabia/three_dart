part of three_webgl;


var emptyTexture = new Texture(null, null, null, null, null, null, null, null, null, null);
var emptyTexture2dArray = new DataTexture2DArray(null);
var emptyTexture3d = new DataTexture3D();
var emptyCubeTexture = new CubeTexture(null, null, null, null, null, null, null, null, null, null);

// --- Utilities ---

// Array Caches (provide typed arrays for temporary by size)

var arrayCacheF32 = {};
var arrayCacheI32 = {};

// Float32Array caches used for uploading Matrix uniforms

var mat4array = new Float32Array( 16 );
var mat3array = new Float32Array( 9 );
var mat2array = new Float32Array( 4 );


// --- Uniform Classes ---

class SingleUniform with WebGLUniformsHelper {

  late dynamic id;
  late Function setValue;
  late int activeInfoType;
  late dynamic activeInfo;

  SingleUniform( id, activeInfo, addr ) {

    this.id = id;
    this.addr = addr;
    this.activeInfo = activeInfo;
    this.activeInfoType = activeInfo.type;
    this.setValue = getSingularSetter( id, activeInfo );
  }

  // for DEBUG
  // setValue( gl, value, textures ) {
    
  //   String vt = value.runtimeType.toString();

  //   if(vt == "Color" || vt == "Matrix4" || vt == "Vector3" || vt == "Vector2" || vt == "Matrix3") {
  //     print("SingleUniform. setValue id: ${id} value: ${value.toJSON()}  type: ${activeInfo.type} ");
  //   } else if(value.runtimeType.toString().indexOf("List<") >= 0) {
  //     var v0 = value[0];
  //     String v0t = v0.runtimeType.toString();
  //     if(v0t == "Matrix4" || v0t == "Vector3" || v0t == "Vector2" || v0t == "Matrix3" ) {
  //       print("SingleUniform. setValue id: ${id} value: ${value.map((e) => e.toJSON())}  type: ${activeInfo.type} ");
  //     } else {
  //       print("SingleUniform. setValue id: ${id} value: ${value}  type: ${activeInfo.type} ");
  //     }
  //   } else {
  //     print("SingleUniform. setValue id: ${id} value: ${value} type: ${activeInfo.type} ");
  //   }

    
  //   Function fn = getSingularSetter( id, activeInfo );
  //   fn(gl, value, textures);
  // }

  

	// this.path = activeInfo.name; // DEBUG

}

class PureArrayUniform with WebGLUniformsHelper {

  late dynamic id;
  late Function setValue;
  late int activeInfoType;
  late dynamic activeInfo;

  PureArrayUniform( id, activeInfo, addr ) {

    this.id = id;
    this.addr = addr;
    this.cache = {};
    this.activeInfo = activeInfo;
    this.size = activeInfo.size;
    this.activeInfoType = activeInfo.type;
    this.setValue = getPureArraySetter( id, activeInfo );
  }

  // for DEBUG
  // setValue( gl, value, textures ) {
  //   String vt = value.runtimeType.toString();

  //   if(vt == "Color" || vt == "Matrix4" || vt == "Vector3" || vt == "Vector2" || vt == "Matrix3") {
  //     print("PureArrayUniform. setValue id: ${id} value: ${value.toJSON()} type: ${activeInfo.type}");
  //   } else if(value.runtimeType.toString().indexOf("List<") >= 0) {
  //     var v0 = value[0];
  //     String v0t = v0.runtimeType.toString();
  //     if(v0t == "Matrix4" || v0t == "Vector3" || v0t == "Vector2" || v0t == "Matrix3") {
  //       print("PureArrayUniform. setValue id: ${id} value: ${value.map((e) => e.toJSON())} type: ${activeInfo.type}");
  //     } else {
  //       print("PureArrayUniform. setValue id: ${id} value: ${value} type: ${activeInfo.type}");
  //     }
        
  //   } else {
  //     print("PureArrayUniform. setValue id: ${id} value: ${value} type: ${activeInfo.type}");
  //   }

    
  //   Function fn = getPureArraySetter( id, activeInfo );
  //   fn(gl, value, textures);
  // }

	// this.path = activeInfo.name; // DEBUG

  // updateCache( data ) {

  //   var cache = this.cache;

  //   if ( data instanceof Float32Array && cache.length != data.length ) {

  //     this.cache = new Float32Array( data.length );

  //   }

  //   copyArray( cache, data );

  // }
}


class WebGLUniform {
  late List seq;
  late Map map;
}

class StructuredUniform with WebGLUniformsHelper, WebGLUniform {

  late dynamic id;
  late int activeInfoType;

  StructuredUniform( id ) {
    this.id = id;
    this.seq = [];
    this.map = {};
  }

  setValue( gl, value, textures ) {

    var seq = this.seq;

    for ( var i = 0, n = seq.length; i != n; ++ i ) {

      var u = seq[ i ];
      u.setValue( gl, value[ u.id ], textures );

    }

  }


}



// --- Top-level ---

// Parser - builds up the property tree from the path strings

var RePathPart = RegExp(r"(\w+)(\])?(\[|\.)?"); //g;

// extracts
// 	- the identifier (member name or array index)
//  - followed by an optional right bracket (found when array index)
//  - followed by an optional left bracket or dot (type of subscript)
//
// Note: These portions can be read in a non-overlapping fashion and
// allow straightforward parsing of the hierarchy that WebGL encodes
// in the uniform names.

addUniform(WebGLUniform container, uniformObject ) {



	container.seq.add( uniformObject );
	container.map[ uniformObject.id ] = uniformObject;

}

parseUniform( activeInfo, addr, WebGLUniform container ) {

	var path = activeInfo.name;
	var pathLength = path.length;

  // print("WebGLUniformsHelper.parseUniform path: ${path} addr: ${addr} ");
  
	// reset RegExp object, because of the early exit of a previous run
	// RePathPart.lastIndex = 0;
  int _lastIndex = 0;

  var matches = RePathPart.allMatches( path );
 
	for(var match in matches) {

		dynamic id = match.group(1);
		var idIsIndex = match.group(2) == ']';
		var subscript = match.group(3);

		if ( idIsIndex ) id = int.parse(id); // convert to integer


    var matchEnd = match.end;


		if ( subscript == null || subscript == '[' && matchEnd + 2 == pathLength ) {

			// bare name or "pure" bottom-level array "[0]" suffix

			addUniform( container, subscript == null ?
				new SingleUniform( id, activeInfo, addr ) :
				new PureArrayUniform( id, activeInfo, addr ) );

      break;
		} else {

			// step into inner node / create it in case it doesn't exist

			var map = container.map;
			var next = map[ id ];

			if ( next == null ) {

				next = new StructuredUniform( id );
				addUniform( container, next );

			}

			container = next;

		}


	}



}


class WebGLUniformsHelper {
  // Flattening for arrays of vectors and matrices
  // id 类型  string || int
  late dynamic id;
  Map<int, dynamic> cache = Map<int, dynamic>();
  dynamic addr;
  late int size;

  Float32List flatten(List array, int nBlocks, int blockSize ) {

    var firstElem = array[ 0 ];

    if(firstElem.runtimeType == num || firstElem.runtimeType == double || firstElem.runtimeType == int) {
      List<double> array2 = [];

      array.forEach((element) {
        array2.add(element.toDouble());
      });
      
      return Float32List.fromList(array2);
    }
    
    // // unoptimized: ! isNaN( firstElem )
    // // see http://jacksondunstan.com/articles/983

    var n = nBlocks * blockSize;
    var r = arrayCacheF32[ n ];
    

    if ( r == null ) {

      r = Float32List( n );
      arrayCacheF32[ n ] = r;

    }

    if ( nBlocks != 0 ) {

      // firstElem.toArray( r.data, offset: 0 );

      // for ( var i = 1, offset = 0; i != nBlocks; ++ i ) {

      //   offset += blockSize;
      //   array[ i ].toArray( r.data, offset: offset );

      // }

      for ( var i = 0; i < nBlocks; i++ ) {
        List<num> _data = array[ i ].toJSON();

        _data.asMap().forEach((index, element) {
          int _idx = i * blockSize + index;
          r[_idx] = element.toDouble();
        });
      }


      // bool stringKey = false;

      // if(array[0] == null) {
      //   stringKey = true;
      // }

   
      // if(!stringKey) {
      //   for ( var i = 0; i < nBlocks; i++ ) {
      //     List<num> _data = array[ i ].toJSON();

      //     _data.asMap().forEach((index, element) {
      //       int _idx = i * blockSize + index;
      //       r[_idx] = element;
      //     });
      //   }
      // } else {
      //   for ( var i = 0; i < nBlocks; i++ ) {
      //     List<num> _data = array[ i.toString() ].toJSON();

      //     _data.asMap().forEach((index, element) {
      //       int _idx = i * blockSize + index;
      //       r[_idx] = element;
      //     });
      //   }
      // }

    }

    return r;




    // List<num> r = [];
    // if(array.runtimeType == List) {
    //   for ( var i = 0; i < nBlocks; i++ ) {
    //     r.addAll(array[ i ].toJSON());
    //   }
    // } else {
    //   for ( var i = 0; i < nBlocks; i++ ) {
    //     r.addAll(array[ i.toString() ].toJSON());
    //   }
    // }
    // return r;
  }

  arraysEqual( Map<int, dynamic> a, List b ) {
    if ( a.keys.length != b.length ) return false;

    for ( var i = 0, l = a.keys.length; i < l; i ++ ) {

      if ( a[ i ] != b[ i ] ) return false;

    }

    return true;

  }

  copyArray( Map<int, dynamic> a, List b ) {
    for ( var i = 0, l = b.length; i < l; i ++ ) {
      a[ i ] = b[ i ];
    }

  }

  // Texture unit allocation

  allocTexUnits( textures, n ) {

    var r = arrayCacheI32[ n ];

    if ( r == null ) {

      r = Int32List( n );
      arrayCacheI32[ n ] = r;

    }

    for ( var i = 0; i != n; ++ i ) {
      r[ i ] = textures.allocateTextureUnit();
    }

    return r;

  }

  // --- Setters ---

  // Note: Defining these methods externally, because they come in a bunch
  // and this way their names minify.

  // Single scalar

  setValueV1f( gl, v, textures ) {

    var cache = this.cache;

    if ( cache[ 0 ] == v ) return;

    gl.uniform1f( this.addr, v );

    cache[ 0 ] = v;

  }

  // Single float vector (from flat array or THREE.VectorN)

  setValueV2f( gl, v, textures ) {

    var cache = this.cache;

    if ( v.x != null ) {

      if ( cache[ 0 ] != v.x || cache[ 1 ] != v.y ) {

        gl.uniform2f( this.addr, v.x, v.y );

        cache[ 0 ] = v.x;
        cache[ 1 ] = v.y;

      }

    } else {

      if ( arraysEqual( cache, v ) ) return;

      gl.uniform2fv( this.addr, v );

      copyArray( cache, v );

    }

  }

  setValueV3f( gl, v, textures ) {

    // if ( v.runtimeType == Vector3 ) {
    //   print("setValueV3f ${v.runtimeType} v: ${v.toJSON()}  ");
    // } else if ( v.runtimeType == Color ) { 
    //   print("setValueV3f ${v.runtimeType} v: ${v.toJSON()}  ");
    // } else {
    //   print("setValueV3f ${v.runtimeType} v: ${v}  ");
    // }
    

    var cache = this.cache;

    if ( v.runtimeType == Vector3 ) {

      if ( cache[ 0 ] != v.x || cache[ 1 ] != v.y || cache[ 2 ] != v.z ) {

        gl.uniform3f( this.addr, v.x, v.y, v.z );

        cache[ 0 ] = v.x;
        cache[ 1 ] = v.y;
        cache[ 2 ] = v.z;

      }

    } else if ( v.runtimeType == Color ) {

      var cacheR = null;
      var cacheG = null;
      var cacheB = null;

      if(cache.length >= 3) {
        cacheR = cache[0];
        cacheG = cache[1];
        cacheB = cache[2];
      }

 
      if ( cacheR != v.r || cacheG != v.g || cacheB != v.b ) {
       
        gl.uniform3f( this.addr, v.r, v.g, v.b );

        cache[ 0 ] = v.r;
        cache[ 1 ] = v.g;
        cache[ 2 ] = v.b;
        
      }

    } else {

      if ( arraysEqual( cache, v ) ) return;

      gl.uniform3fv( this.addr, v );

      copyArray( cache, v );

    }

  }

  setValueV4f( gl, v, textures ) {

    var cache = this.cache;

    if ( v.runtimeType == Vector4 ) {

      if ( cache[ 0 ] != v.x || cache[ 1 ] != v.y || cache[ 2 ] != v.z || cache[ 3 ] != v.w ) {

        gl.uniform4f( this.addr, v.x, v.y, v.z, v.w );

        cache[ 0 ] = v.x;
        cache[ 1 ] = v.y;
        cache[ 2 ] = v.z;
        cache[ 3 ] = v.w;

      }
    } else if(v is Color) {
      if ( cache[ 0 ] != v.r || cache[ 1 ] != v.g || cache[ 2 ] != v.b || cache[ 3 ] != 1.0 ) {

        gl.uniform4f( this.addr, v.r, v.g, v.b, 1.0 );

        cache[ 0 ] = v.r;
        cache[ 1 ] = v.g;
        cache[ 2 ] = v.b;
        cache[ 3 ] = 1.0;

      }
    } else if(v is List) {
      if ( cache[ 0 ] != v[0] || cache[ 1 ] != v[1] || cache[ 2 ] != v[2] || cache[ 3 ] != v[3] ) {

        gl.uniform4f( this.addr, v[0], v[1], v[2], v[3] );

        cache[ 0 ] = v[0];
        cache[ 1 ] = v[1];
        cache[ 2 ] = v[2];
        cache[ 3 ] = v[3];

      }  
    } else {

      print(" WebGLUniformsHelper setValueV4f ");
      
      if ( arraysEqual( cache, v ) ) return;

      gl.uniform4fv( this.addr, v );

      copyArray( cache, v );

    }

  }

  // Single matrix (from flat array or MatrixN)

  setValueM2( gl, v, textures ) {

    var cache = this.cache;
    var elements = v.elements;

    if ( elements == null ) {

      if ( arraysEqual( cache, v ) ) return;

      gl.uniformMatrix2fv( this.addr, false, v );

      copyArray( cache, v );

    } else {

      if ( arraysEqual( cache, elements ) ) return;

      mat2array.set( elements );

      gl.uniformMatrix2fv( this.addr, false, mat2array );

      copyArray( cache, elements );

    }

  }

  setValueM3( gl, v, textures ) {

    var cache = this.cache;
    var elements = v.elements;

    if ( elements == null ) {
      if ( arraysEqual( cache, v ) ) return;

      gl.uniformMatrix3fv( this.addr, false, v );

      copyArray( cache, v );

    } else {

      if ( arraysEqual( cache, elements ) ) {
        return;
      }

      mat3array.set( elements );

      gl.uniformMatrix3fv( this.addr, false, elements );



      copyArray( cache, elements );
    }

  }

  setValueM4( gl, v, textures ) {

    var cache = this.cache;
    var elements = v.elements;

    if ( elements == null ) {

      if ( arraysEqual( cache, v ) ) return;

      gl.uniformMatrix4fv( this.addr, false, v );

      copyArray( cache, v );

    } else {

      if ( arraysEqual( cache, elements ) ) {
  
        return;
      }

      mat4array.set( elements );

      gl.uniformMatrix4fv( this.addr, false, elements );

      copyArray( cache, elements );

    }

  }

  // Single texture (2D / Cube)

  setValueT1( gl, v, textures ) {

    var cache = this.cache;
    var unit = textures.allocateTextureUnit();

  
    if ( cache[ 0 ] != unit ) {

      gl.uniform1i( this.addr, unit );
      cache[ 0 ] = unit;

    }



    textures.safeSetTexture2D( v ?? emptyTexture, unit );

  }

  setValueT2DArray1( gl, v, textures ) {

    var cache = this.cache;
    var unit = textures.allocateTextureUnit();

    if ( cache[ 0 ] != unit ) {

      gl.uniform1i( this.addr, unit );
      cache[ 0 ] = unit;

    }

    textures.setTexture2DArray( v ?? emptyTexture2dArray, unit );

  }

  setValueT3D1( gl, v, textures ) {

    var cache = this.cache;
    var unit = textures.allocateTextureUnit();

    if ( cache[ 0 ] != unit ) {

      gl.uniform1i( this.addr, unit );
      cache[ 0 ] = unit;

    }

    textures.setTexture3D( v ?? emptyTexture3d, unit );

  }

  setValueT6( gl, v, textures ) {

    var cache = this.cache;
    var unit = textures.allocateTextureUnit();

    if ( cache[ 0 ] != unit ) {

      gl.uniform1i( this.addr, unit );
      cache[ 0 ] = unit;

    }

    textures.safeSetTextureCube( v ?? emptyCubeTexture, unit );

  }

  // Integer / Boolean vectors or arrays thereof (always flat arrays)

  setValueV1i( gl, v, textures ) {
    var cache = this.cache;

    if (cache != null && cache.length >= 1 && cache[ 0 ] == v ) return;


    if(v.runtimeType == bool) {
      if(v) {
        gl.uniform1i( this.addr, 1 );
      } else {
        gl.uniform1i( this.addr, 0 );
      }
    } else {
      gl.uniform1i( this.addr, v.toInt() );
    }

    cache[ 0 ] = v;
    
  }

  setValueV2i( gl, v, textures ) {

    var cache = this.cache;

    if ( arraysEqual( cache, v ) ) return;

    gl.uniform2iv( this.addr, v );

    copyArray( cache, v );

  }

  setValueV3i( gl, v, textures ) {

    var cache = this.cache;

    if ( arraysEqual( cache, v ) ) return;

    gl.uniform3iv( this.addr, v );

    copyArray( cache, v );

  }

  setValueV4i( gl, v, textures ) {

    var cache = this.cache;

    if ( arraysEqual( cache, v ) ) return;

    gl.uniform4iv( this.addr, v );

    copyArray( cache, v );

  }

  // uint

  setValueV1ui( gl, v, textures ) {

    var cache = this.cache;

    if ( cache[ 0 ] == v ) return;

    gl.uniform1ui( this.addr, v );

    cache[ 0 ] = v;

  }

  // Helper to pick the right setter for the singular case

  getSingularSetter( id, activeInfo ) {

    // print("getSingularSetter id: ${id} type: ${activeInfo.type}  ");

    var type = activeInfo.type;


    switch ( type ) {

      case 0x1406: return setValueV1f; // FLOAT
      case 0x8b50: return setValueV2f; // _VEC2
      case 0x8b51: return setValueV3f; // _VEC3
      case 0x8b52: return setValueV4f; // _VEC4

      case 0x8b5a: return setValueM2; // _MAT2
      case 0x8b5b: return setValueM3; // _MAT3
      case 0x8b5c: return setValueM4; // _MAT4

      case 0x1404: case 0x8b56: return setValueV1i; // INT, BOOL
      case 0x8b53: case 0x8b57: return setValueV2i; // _VEC2
      case 0x8b54: case 0x8b58: return setValueV3i; // _VEC3
      case 0x8b55: case 0x8b59: return setValueV4i; // _VEC4

      case 0x1405: return setValueV1ui; // UINT

      case 0x8b5e: // SAMPLER_2D
      case 0x8d66: // SAMPLER_EXTERNAL_OES
      case 0x8dca: // INT_SAMPLER_2D
      case 0x8dd2: // UNSIGNED_INT_SAMPLER_2D
      case 0x8b62: // SAMPLER_2D_SHADOW
        return setValueT1;

      case 0x8b5f: // SAMPLER_3D
      case 0x8dcb: // INT_SAMPLER_3D
      case 0x8dd3: // UNSIGNED_INT_SAMPLER_3D
        return setValueT3D1;

      case 0x8b60: // SAMPLER_CUBE
      case 0x8dcc: // INT_SAMPLER_CUBE
      case 0x8dd4: // UNSIGNED_INT_SAMPLER_CUBE
      case 0x8dc5: // SAMPLER_CUBE_SHADOW
        return setValueT6;

      case 0x8dc1: // SAMPLER_2D_ARRAY
      case 0x8dcf: // INT_SAMPLER_2D_ARRAY
      case 0x8dd7: // UNSIGNED_INT_SAMPLER_2D_ARRAY
      case 0x8dc4: // SAMPLER_2D_ARRAY_SHADOW
        return setValueT2DArray1;
      default:
        throw("getSingularSetter id: ${id} name: ${activeInfo.name} size: ${activeInfo.size} type: ${activeInfo.type}  ");
    }

  }

  // Array of scalars
  setValueV1fArray( gl, v, textures ) {

    gl.uniform1fv( this.addr, v );

  }

  // Integer / Boolean vectors or arrays thereof (always flat arrays)
  setValueV1iArray( gl, v, textures ) {

    gl.uniform1iv( this.addr, v );

  }

  setValueV2iArray( gl, v, textures ) {

    gl.uniform2iv( this.addr, v );

  }

  setValueV3iArray( gl, v, textures ) {

    gl.uniform3iv( this.addr, v );

  }

  setValueV4iArray( gl, v, textures ) {

    gl.uniform4iv( this.addr, v );

  }


  // Array of vectors (flat or from THREE classes)

  setValueV2fArray( gl, v, textures ) {

    var data = flatten( v, this.size, 2 );

    gl.uniform2fv( this.addr, data );

  }

  setValueV3fArray( gl, v, textures ) {

    var data = flatten( v, this.size, 3 );

    gl.uniform3fv( this.addr, data );

  }

  setValueV4fArray( gl, v, textures ) {

    var data = flatten( v, this.size, 4 );

    gl.uniform4fv( this.addr, data );

  }

  // Array of matrices (flat or from THREE clases)

  setValueM2Array( gl, v, textures ) {

    var data = flatten( v, this.size, 4 );

    gl.uniformMatrix2fv( this.addr, false, data );

  }

  setValueM3Array( gl, v, textures ) {

    var data = flatten( v, this.size, 9 );

    gl.uniformMatrix3fv( this.addr, false, data );

  }

  setValueM4Array( gl, v, textures ) {

    var data = flatten( v, this.size, 16 );

    gl.uniformMatrix4fv( this.addr, false, data );

  }

  // Array of textures (2D / Cube)
  setValueT1Array( gl, v, WebGLTextures textures ) {
    var n = v.length;

    var units = allocTexUnits( textures, n );

    // print("setValueT1Array n: ${n} ");
    gl.uniform1iv( this.addr, units );

    for ( var i = 0; i != n; ++ i ) {

      textures.safeSetTexture2D( v[ i ] ?? emptyTexture, units[ i ] );

    }

  }

  setValueT6Array( gl, v, textures ) {

    var n = v.length;

    var units = allocTexUnits( textures, n );

    gl.uniform1iv( this.addr, units );

    for ( var i = 0; i != n; ++ i ) {

      textures.safeSetTextureCube( v[ i ] ?? emptyCubeTexture, units[ i ] );

    }

  }

  // Helper to pick the right setter for a pure (bottom-level) array

  getPureArraySetter( id, activeInfo ) {

    var type = activeInfo.type;

    // print("getPureArraySetter id: ${id} type: ${activeInfo.type}  ");

    switch ( type ) {

      case 0x1406: return setValueV1fArray; // FLOAT
      case 0x8b50: return setValueV2fArray; // _VEC2
      case 0x8b51: return setValueV3fArray; // _VEC3
      case 0x8b52: return setValueV4fArray; // _VEC4

      case 0x8b5a: return setValueM2Array; // _MAT2
      case 0x8b5b: return setValueM3Array; // _MAT3
      case 0x8b5c: return setValueM4Array; // _MAT4

      case 0x1404: case 0x8b56: return setValueV1iArray; // INT, BOOL
      case 0x8b53: case 0x8b57: return setValueV2iArray; // _VEC2
      case 0x8b54: case 0x8b58: return setValueV3iArray; // _VEC3
      case 0x8b55: case 0x8b59: return setValueV4iArray; // _VEC4

      case 0x8b5e: // SAMPLER_2D
      case 0x8d66: // SAMPLER_EXTERNAL_OES
      case 0x8dca: // INT_SAMPLER_2D
      case 0x8dd2: // UNSIGNED_INT_SAMPLER_2D
      case 0x8b62: // SAMPLER_2D_SHADOW
        return setValueT1Array;

      case 0x8b60: // SAMPLER_CUBE
      case 0x8dcc: // INT_SAMPLER_CUBE
      case 0x8dd4: // UNSIGNED_INT_SAMPLER_CUBE
      case 0x8dc5: // SAMPLER_CUBE_SHADOW
        return setValueT6Array;

    }

  }

}