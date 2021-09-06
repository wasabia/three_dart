
part of three_core;





class BufferAttribute extends BaseBufferAttribute {
  String type = "BufferAttribute";
  var _vector = new Vector3.init();
  var _vector2 = new Vector2(null, null);

  String name = '';
  bool isBufferAttribute = true;
  

  BufferAttribute(arrayList, itemSize, normalized ) {
    if(arrayList is ThreeArray) {
      this.array = arrayList;
    } else if (arrayList is Float32List ) {
      this.array = Float32Array.from(arrayList);
    } else if (arrayList is List ) {
      this.array = Float32Array.from(arrayList);  
    } else {
      throw("BufferAttribute  arrayList: ${arrayList.runtimeType} is need support ....  ");
    }
    
    this.itemSize = itemSize;
    this.count = array != null ? (array.length / itemSize).toInt() : 0;
    this.normalized = normalized == true;

    this.usage = StaticDrawUsage;
    this.updateRange = { "offset": 0, "count": - 1 };

    this.version = 0;
  }

  get length => this.count;

  set needsUpdate(bool value) {
    if ( value == true ) this.version ++;
  }

	setUsage( value ) {

		this.usage = value;

		return this;

	}

	copy( source ) {

		this.name = source.name;
		this.array = source.array.clone();
		this.itemSize = source.itemSize;
		this.count = source.count;
		this.normalized = source.normalized;
    this.type = source.type;
		this.usage = source.usage;

		return this;

	}

	copyAt( index1, attribute, index2 ) {

		index1 *= this.itemSize;
		index2 *= attribute.itemSize;

		for ( var i = 0, l = this.itemSize; i < l; i ++ ) {

			this.array[ index1 + i ] = attribute.array[ index2 + i ];

		}

		return this;

	}

	copyArray( array ) {

 
		this.array = array;

		return this;

	}

	copyColorsArray ( colors ) {

		var array = this.array;
		var offset = 0;

		for ( var i = 0, l = colors.length; i < l; i ++ ) {

			var color = colors[ i ];

			if ( color == null ) {

				print( 'THREE.BufferAttribute.copyColorsArray(): color is null ${i}' );
				color = new Color(0,0,0);

			}

			array[ offset ++ ] = color.r;
			array[ offset ++ ] = color.g;
			array[ offset ++ ] = color.b;

		}

		return this;

	}

	copyVector2sArray ( vectors ) {

		var array = this.array;
		var offset = 0;

		for ( var i = 0, l = vectors.length; i < l; i ++ ) {

			var vector = vectors[ i ];

			if ( vector == null ) {

				print( 'THREE.BufferAttribute.copyVector2sArray(): vector is null ${i}' );
				vector = new Vector2(null, null);

			}

			array[ offset ++ ] = vector.x;
			array[ offset ++ ] = vector.y;

		}

		return this;

	}

	copyVector3sArray ( vectors ) {

		var array = this.array;
		var offset = 0;

		for ( var i = 0, l = vectors.length; i < l; i ++ ) {

			var vector = vectors[ i ];

			if ( vector == null ) {

				print( 'THREE.BufferAttribute.copyVector3sArray(): vector is null ${i}' );
				vector = new Vector3.init();

			}

			array[ offset ++ ] = vector.x;
			array[ offset ++ ] = vector.y;
			array[ offset ++ ] = vector.z;

		}

		return this;

	}

	copyVector4sArray ( vectors ) {

		var array = this.array;
		var offset = 0;

		for ( var i = 0, l = vectors.length; i < l; i ++ ) {

			var vector = vectors[ i ];

			if ( vector == null ) {

				print( 'THREE.BufferAttribute.copyVector4sArray(): vector is null ${i}' );
				vector = new Vector4.init();

			}

			array[ offset ++ ] = vector.x;
			array[ offset ++ ] = vector.y;
			array[ offset ++ ] = vector.z;
			array[ offset ++ ] = vector.w;

		}

		return this;

	}

	applyMatrix3 ( m ) {

		if ( this.itemSize == 2 ) {

			for ( var i = 0, l = this.count; i < l; i ++ ) {

				_vector2.fromBufferAttribute( this, i );
				_vector2.applyMatrix3( m );

				this.setXY( i, _vector2.x, _vector2.y );

			}

		} else if ( this.itemSize == 3 ) {

			for ( var i = 0, l = this.count; i < l; i ++ ) {

				_vector.fromBufferAttribute( this, i );
				_vector.applyMatrix3( m );

				this.setXYZ( i, _vector.x, _vector.y, _vector.z );

			}

		}

		return this;

	}

	applyMatrix4 ( Matrix4 m ) {
    
    // print(this.array);

		for ( var i = 0, l = this.count; i < l; i ++ ) {

			_vector.x = this.getX( i );
			_vector.y = this.getY( i );
			_vector.z = this.getZ( i );

			_vector.applyMatrix4( m );

 
			this.setXYZ( i, _vector.x, _vector.y, _vector.z );

		}





	}

	applyNormalMatrix ( m ) {

		for ( var i = 0, l = this.count; i < l; i ++ ) {

			_vector.x = this.getX( i );
			_vector.y = this.getY( i );
			_vector.z = this.getZ( i );

			_vector.applyNormalMatrix( m );

			this.setXYZ( i, _vector.x, _vector.y, _vector.z );

		}

		return this;

	}

	transformDirection ( m ) {

		for ( var i = 0, l = this.count; i < l; i ++ ) {

			_vector.x = this.getX( i );
			_vector.y = this.getY( i );
			_vector.z = this.getZ( i );

			_vector.transformDirection( m );

			this.setXYZ( i, _vector.x, _vector.y, _vector.z );

		}

		return this;

	}

	set ( value, {int offset = 0} ) {

		this.array[offset] = value;

		return this;

	}

	getX ( int index ) {

		return this.array[ index * this.itemSize ];

	}

	setX ( int index, x ) {

		this.array[ index * this.itemSize ] = x;

		return this;

	}

	getY ( int index ) {

		return this.array[ index * this.itemSize + 1 ];

	}

	setY ( int index, y ) {

		this.array[ index * this.itemSize + 1 ] = y;

		return this;

	}

	getZ ( int index ) {

		return this.array[ index * this.itemSize + 2 ];

	}

	setZ ( int index, z ) {

		this.array[ index * this.itemSize + 2 ] = z;

		return this;

	}

	getW ( int index ) {

		return this.array[ index * this.itemSize + 3 ];

	}

	setW ( int index, w ) {

		this.array[ index * this.itemSize + 3 ] = w;

		return this;

	}

	setXY ( int index, x, y ) {

		index *= this.itemSize;

		this.array[ index + 0 ] = x;
		this.array[ index + 1 ] = y;

		return this;

	}

	setXYZ ( int index, num x, num y, num z ) {

		int _idx = index * this.itemSize;

		this.array[ _idx + 0 ] = x.toDouble();
		this.array[ _idx + 1 ] = y.toDouble();
		this.array[ _idx + 2 ] = z.toDouble();
	}

	setXYZW ( int index, x, y, z, w ) {

		index *= this.itemSize;

		this.array[ index + 0 ] = x;
		this.array[ index + 1 ] = y;
		this.array[ index + 2 ] = z;
		this.array[ index + 3 ] = w;

		return this;

	}

	onUpload ( callback ) {

		this.onUploadCallback = callback;

		return this;

	}

	clone () {
    if(type == "BufferAttribute") {
      return BufferAttribute( this.array, this.itemSize, false ).copy( this );
    } else if(type == "Float32BufferAttribute") {
      return Float32BufferAttribute(this.array, this.itemSize, false).copy(this);
    } else if(type == "Uint8BufferAttribute") {
      return Uint8BufferAttribute(this.array, this.itemSize, false).copy(this);
    } else if(type == "Uint16BufferAttribute") {
      return Uint16BufferAttribute(this.array, this.itemSize, false).copy(this);  
      
    } else {
      throw("BufferAttribute type: ${type} clone need support ....  ");
    }
	}

	toJSON () {

    // print(" BufferAttribute to JSON todo  ${this.array.runtimeType} ");

		// return {
		// 	"itemSize": this.itemSize,
		// 	"type": this.array.runtimeType.toString(),
		// 	"array": this.array.sublist(0),
		// 	"normalized": this.normalized
		// };

    var data = {
			"itemSize": this.itemSize,
			"type": this.array.runtimeType.toString(),
			"array": this.array.sublist(0),
			"normalized": this.normalized
		};

		if ( this.name != '' ) data["name"] = this.name;
		if ( this.usage != StaticDrawUsage ) data["usage"] = this.usage;
		if ( this.updateRange?["offset"] != 0 || this.updateRange?["count"] != - 1 ) data["updateRange"] = this.updateRange;

		return data;

	}


}


class Int8BufferAttribute extends BufferAttribute {
  String type = "Int8BufferAttribute";
  
  Int8BufferAttribute(array, itemSize, normalized ): super(array, itemSize, normalized) {

  }
}



class Uint8BufferAttribute extends BufferAttribute {
  String type = "Uint8BufferAttribute";
  Uint8BufferAttribute(array, itemSize, normalized ): super( array, itemSize, normalized ) {

  }

}


class Uint8ClampedBufferAttribute extends BufferAttribute {
  String type = "Uint8ClampedBufferAttribute";
  Uint8ClampedBufferAttribute( array, itemSize, normalized ): super( array, itemSize, normalized ) {

  }

}



class Int16BufferAttribute extends BufferAttribute {
  String type = "Int16BufferAttribute";
  Int16BufferAttribute(array, itemSize, normalized ): super( array, itemSize, normalized ) {

  }


}

// Int16BufferAttribute.prototype = Object.create( BufferAttribute.prototype );
// Int16BufferAttribute.prototype.constructor = Int16BufferAttribute;


class Uint16BufferAttribute extends BufferAttribute {
  String type = "Uint16BufferAttribute";
  Uint16BufferAttribute(array, itemSize, normalized ): super(array, itemSize, normalized) {

  }


}


class Int32BufferAttribute extends BufferAttribute {
  String type = "Int32BufferAttribute";
  Int32BufferAttribute(array, itemSize, normalized ): super(array, itemSize, normalized) {

  }


}



class Uint32BufferAttribute extends BufferAttribute {
  String type = "Uint32BufferAttribute";
  Uint32BufferAttribute( array, itemSize, normalized ): super(array, itemSize, normalized) {

  }


}


class Float16BufferAttribute extends BufferAttribute {
  String type = "Float16BufferAttribute";
  Float16BufferAttribute( array, itemSize, normalized ): super(array, itemSize, normalized) {

  }

}


class Float32BufferAttribute extends BufferAttribute {

  String type = "Float32BufferAttribute";

  Float32BufferAttribute( array, itemSize, normalized ): super(array, itemSize, normalized) {

  }


}


class Float64BufferAttribute extends BufferAttribute {
  String type = "Float64BufferAttribute";
  Float64BufferAttribute( array, itemSize, normalized ): super(array, itemSize, normalized) {

  }


}

