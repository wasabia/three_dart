part of three_webgpu;


class WebGPUUniformsGroup extends WebGPUUniformBuffer {

  late List uniforms;

	WebGPUUniformsGroup( name ) : super( name ) {
		// the order of uniforms in this array must match the order of uniforms in the shader

		this.uniforms = [];

	}

	addUniform( uniform ) {

		this.uniforms.add( uniform );

		return this;

	}

	removeUniform( uniform ) {

		var index = this.uniforms.indexOf( uniform );

		if ( index != - 1 ) {

			this.uniforms.removeAt( index );

		}

		return this;

	}

	getBuffer() {

		var buffer = this.buffer;

		if ( buffer == null ) {

			var byteLength = this.getByteLength();

			buffer = new Float32Array( byteLength );

			this.buffer = buffer;

		}

		return buffer;

	}

	getByteLength() {

		int offset = 0; // global buffer offset in bytes

		for ( var i = 0, l = this.uniforms.length; i < l; i ++ ) {

			var uniform = this.uniforms[ i ];

			// offset within a single chunk in bytes

			var chunkOffset = offset % GPUChunkSize;
			var remainingSizeInChunk = GPUChunkSize - chunkOffset;

			// conformance tests

			if ( chunkOffset != 0 && ( remainingSizeInChunk - uniform.boundary ) < 0 ) {

				// check for chunk overflow

				offset += ( GPUChunkSize - chunkOffset );

			} else if ( chunkOffset % uniform.boundary != 0 ) {

				// check for correct alignment

				offset += ( chunkOffset % uniform.boundary ).toInt();

			}

			uniform.offset = ( offset ~/ this.bytesPerElement );

      int _v = ( uniform.itemSize * this.bytesPerElement ).toInt();
			offset += _v;

		}

		return offset;

	}

	update() {

		var updated = false;

		for ( var uniform in this.uniforms ) {

			if ( this.updateByType( uniform ) == true ) {

				updated = true;

			}

		}

		return updated;

	}

	updateByType( uniform ) {

		if ( uniform is FloatUniform ) return this.updateNumber( uniform );
		if ( uniform is Vector2Uniform ) return this.updateVector2( uniform );
		if ( uniform is Vector3Uniform ) return this.updateVector3( uniform );
		if ( uniform is Vector4Uniform ) return this.updateVector4( uniform );
		if ( uniform is ColorUniform ) return this.updateColor( uniform );
		if ( uniform is Matrix3Uniform ) return this.updateMatrix3( uniform );
		if ( uniform is Matrix4Uniform ) return this.updateMatrix4( uniform );

		console.error( 'THREE.WebGPUUniformsGroup: Unsupported uniform type.', uniform );

	}

	updateNumber( uniform ) {

		var updated = false;

		var a = this.buffer;
		var v = uniform.getValue();
		var offset = uniform.offset;

		if ( a[ offset ] != v ) {

			a[ offset ] = v;
			updated = true;

		}

		return updated;

	}

	updateVector2( uniform ) {

		var updated = false;

		var a = this.buffer;
		var v = uniform.getValue();
		var offset = uniform.offset;

		if ( a[ offset + 0 ] != v.x || a[ offset + 1 ] != v.y ) {

			a[ offset + 0 ] = v.x;
			a[ offset + 1 ] = v.y;

			updated = true;

		}

		return updated;

	}

	updateVector3( uniform ) {

		var updated = false;

		var a = this.buffer;
		var v = uniform.getValue();
		var offset = uniform.offset;

		if ( a[ offset + 0 ] != v.x || a[ offset + 1 ] != v.y || a[ offset + 2 ] != v.z ) {

			a[ offset + 0 ] = v.x;
			a[ offset + 1 ] = v.y;
			a[ offset + 2 ] = v.z;

			updated = true;

		}

		return updated;

	}

	updateVector4( uniform ) {

		var updated = false;

		var a = this.buffer;
		var v = uniform.getValue();
		var offset = uniform.offset;

		if ( a[ offset + 0 ] != v.x || a[ offset + 1 ] != v.y || a[ offset + 2 ] != v.z || a[ offset + 4 ] != v.w ) {

			a[ offset + 0 ] = v.x;
			a[ offset + 1 ] = v.y;
			a[ offset + 2 ] = v.z;
			a[ offset + 3 ] = v.w;

			updated = true;

		}

		return updated;

	}

	updateColor( uniform ) {

		var updated = false;

		var a = this.buffer;
		var c = uniform.getValue();
		var offset = uniform.offset;

		if ( a[ offset + 0 ] != c.r || a[ offset + 1 ] != c.g || a[ offset + 2 ] != c.b ) {

			a[ offset + 0 ] = c.r;
			a[ offset + 1 ] = c.g;
			a[ offset + 2 ] = c.b;

			updated = true;

		}

		return updated;

	}

	updateMatrix3( uniform ) {

		var updated = false;

		var a = this.buffer;
		var e = uniform.getValue().elements;
		var offset = uniform.offset;

		if ( a[ offset + 0 ] != e[ 0 ] || a[ offset + 1 ] != e[ 1 ] || a[ offset + 2 ] != e[ 2 ] ||
			a[ offset + 4 ] != e[ 3 ] || a[ offset + 5 ] != e[ 4 ] || a[ offset + 6 ] != e[ 5 ] ||
			a[ offset + 8 ] != e[ 6 ] || a[ offset + 9 ] != e[ 7 ] || a[ offset + 10 ] != e[ 8 ] ) {

			a[ offset + 0 ] = e[ 0 ];
			a[ offset + 1 ] = e[ 1 ];
			a[ offset + 2 ] = e[ 2 ];
			a[ offset + 4 ] = e[ 3 ];
			a[ offset + 5 ] = e[ 4 ];
			a[ offset + 6 ] = e[ 5 ];
			a[ offset + 8 ] = e[ 6 ];
			a[ offset + 9 ] = e[ 7 ];
			a[ offset + 10 ] = e[ 8 ];

			updated = true;

		}

		return updated;

	}

	updateMatrix4( uniform ) {

		var updated = false;

		var a = this.buffer;
		var e = uniform.getValue().elements;
		var offset = uniform.offset;

		if ( arraysEqual( a, e, offset ) == false ) {

			a.set( e, offset );
			updated = true;

		}

		return updated;

	}

}

arraysEqual( a, b, offset ) {

	for ( var i = 0, l = b.length; i < l; i ++ ) {

		if ( a[ offset + i ] != b[ i ] ) return false;

	}

	return true;

}


