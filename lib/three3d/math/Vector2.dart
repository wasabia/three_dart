part of three_math;


class Vector2 {

  String type = "Vector2";

  num x = 0;
  num y = 0;

	Vector2(num? x, num? y) {
		this.x = x ?? 0;
		this.y = y ?? 0;
	}

  Vector2.init({num x = 0, num y = 0}) {
		this.x = x;
		this.y = y;
	}

  Vector2.fromJSON( List<num> json ) {
    if(json != null) {
      this.x = json[0];
      this.y = json[1];
    }
	}


	num get width {
		return this.x;
	}

	set width( num value ) {
		this.x = value;
	}

	num get height {
		return this.y;
	}

	set height( num value ) {

		this.y = value;

	}

	Vector2 set( num x, num y ) {
		this.x = x;
		this.y = y;

		return this;
	}

	Vector2 setScalar( num scalar ) {

		this.x = scalar;
		this.y = scalar;

		return this;

	}

	Vector2 setX( num x ) {

		this.x = x;

		return this;

	}

	Vector2 setY( num y ) {

		this.y = y;

		return this;

	}

	Vector2 setComponent( int index, double value ) {

		switch ( index ) {

			case 0: this.x = value; break;
			case 1: this.y = value; break;
			default: throw "index is out of range: ${index}";

		}

		return this;

	}

	num getComponent( int index ) {

		switch ( index ) {

			case 0: return this.x;
			case 1: return this.y;
			default: throw "index is out of range: ${index}";

		}

	}

	Vector2 clone() {

		return Vector2( this.x, this.y );

	}

	Vector2 copy( Vector2 v ) {

		this.x = v.x;
		this.y = v.y;

		return this;
	}

	Vector2 add( Vector2 v, {Vector2? w} ) {

		if ( w != null ) {

			print( 'THREE.Vector2: .add() now only accepts one argument. Use .addVectors( a, b ) instead.' );
			return this.addVectors( v, w );

		}

		this.x += v.x;
		this.y += v.y;

		return this;

	}

	Vector2 addScalar( double s ) {

		this.x += s;
		this.y += s;

		return this;

	}

	Vector2 addVectors( Vector2 a, Vector2 b ) {

		this.x = a.x + b.x;
		this.y = a.y + b.y;

		return this;

	}

	Vector2 addScaledVector( Vector2 v, double s ) {

		this.x += v.x * s;
		this.y += v.y * s;

		return this;

	}

	Vector2 sub( Vector2 v, { Vector2? w }) {

		if ( w != null ) {

			print( 'THREE.Vector2: .sub() now only accepts one argument. Use .subVectors( a, b ) instead.' );
			return this.subVectors( v, w );

		}

		this.x -= v.x;
		this.y -= v.y;

		return this;

	}

	Vector2 subScalar( double s ) {

		this.x -= s;
		this.y -= s;

		return this;

	}

	Vector2 subVectors( Vector2 a, Vector2 b ) {

		this.x = a.x - b.x;
		this.y = a.y - b.y;

		return this;

	}

	Vector2 multiply( Vector2 v ) {

		this.x *= v.x;
		this.y *= v.y;

		return this;

	}

	Vector2 multiplyScalar( num scalar ) {

		this.x *= scalar;
		this.y *= scalar;

		return this;

	}

	Vector2 divide( Vector2 v ) {

		this.x /= v.x;
		this.y /= v.y;

		return this;

	}

	Vector2 divideScalar( num scalar ) {

		return this.multiplyScalar( 1 / scalar );

	}

	Vector2 applyMatrix3( Matrix3 m ) {

		var x = this.x;
    var y = this.y;
		var e = m.elements;

		this.x = e[ 0 ] * x + e[ 3 ] * y + e[ 6 ];
		this.y = e[ 1 ] * x + e[ 4 ] * y + e[ 7 ];

		return this;

	}

	Vector2 min( Vector2 v ) {

		this.x = Math.min( this.x, v.x ).toDouble();
		this.y = Math.min( this.y, v.y ).toDouble();

		return this;

	}

	Vector2 max( Vector2 v ) {

		this.x = Math.max( this.x, v.x );
		this.y = Math.max( this.y, v.y );

		return this;

	}

	Vector2 clamp( Vector2 min, Vector2 max ) {

		// assumes min < max, componentwise

		this.x = Math.max( min.x, Math.min( max.x, this.x ) );
		this.y = Math.max( min.y, Math.min( max.y, this.y ) );

		return this;

	}

	Vector2 clampScalar( double minVal, double maxVal ) {

		this.x = Math.max( minVal, Math.min( maxVal, this.x ) );
		this.y = Math.max( minVal, Math.min( maxVal, this.y ) );

		return this;

	}

	Vector2 clampLength( double min, double max ) {

		var length = this.length();

		return this.divideScalar( length ).multiplyScalar( Math.max( min, Math.min( max, length ) ) );

	}

	Vector2 floor() {

		this.x = Math.floor( this.x ).toDouble();
		this.y = Math.floor( this.y ).toDouble();

		return this;

	}

	Vector2 ceil() {

		this.x = Math.ceil( this.x ).toDouble();
		this.y = Math.ceil( this.y ).toDouble();

		return this;

	}

	Vector2 round() {

		this.x = Math.round( this.x ).toDouble();
		this.y = Math.round( this.y ).toDouble();

		return this;

	}

	Vector2 roundToZero() {

		this.x = ( this.x < 0 ) ? Math.ceil( this.x ).toDouble() : Math.floor( this.x ).toDouble();
		this.y = ( this.y < 0 ) ? Math.ceil( this.y ).toDouble() : Math.floor( this.y ).toDouble();

		return this;

	}

	Vector2 negate() {

		this.x = - this.x;
		this.y = - this.y;

		return this;

	}

	num dot( Vector2 v ) {

		return this.x * v.x + this.y * v.y;

	}

	num cross( Vector2 v ) {

		return this.x * v.y - this.y * v.x;

	}

	num lengthSq() {

		return this.x * this.x + this.y * this.y;

	}

	num length() {

		return Math.sqrt( this.x * this.x + this.y * this.y );

	}

	num manhattanLength() {

		return (Math.abs( this.x ) + Math.abs( this.y )).toDouble();

	}

	Vector2 normalize() {

		return this.divideScalar( this.length() );

	}

	num angle() {

		// computes the angle in radians with respect to the positive x-axis

		var angle = Math.atan2( -this.y, -this.x ) + Math.PI;

		return angle;

	}

	num distanceTo( v ) {

		return Math.sqrt( this.distanceToSquared( v ) );

	}

	num distanceToSquared( v ) {

		var dx = this.x - v.x, dy = this.y - v.y;
		return dx * dx + dy * dy;

	}

	num manhattanDistanceTo( Vector2 v ) {

		return (Math.abs( this.x - v.x ) + Math.abs( this.y - v.y )).toDouble();

	}

	Vector2 setLength( num length ) {

		return this.normalize().multiplyScalar( length );

	}

	Vector2 lerp(Vector2 v, double alpha ) {

		this.x += ( v.x - this.x ) * alpha;
		this.y += ( v.y - this.y ) * alpha;

		return this;

	}

	Vector2 lerpVectors( Vector2 v1, Vector2 v2, double alpha ) {

		this.x = v1.x + ( v2.x - v1.x ) * alpha;
		this.y = v1.y + ( v2.y - v1.y ) * alpha;

		return this;

	}

	bool equals( Vector2 v ) {

		return ( ( v.x == this.x ) && ( v.y == this.y ) );

	}

	Vector2 fromArray(array, {int offset = 0} ) {

		this.x = array[ offset ];
		this.y = array[ offset + 1 ];

		return this;

	}

	List<num> toArray([List<num>? array, int offset = 0]) {

    if(array == null) {
      array = List<num>.filled(2, 0.0);
    }

    array[ offset ] = this.x;
		array[ offset + 1 ] = this.y;
		return array;
	}

  List<num> toJSON() {
    return [this.x, this.y];
  }

  List<num> toArray2(List<num> array, int offset) {
		return [this.x, this.y];
	}

	Vector2 fromBufferAttribute( attribute, index ) {
		this.x = attribute.getX( index );
		this.y = attribute.getY( index );

		return this;
	}

	Vector2 rotateAround(Vector2 center, double angle ) {

		var c = Math.cos( angle ), s = Math.sin( angle );

		var x = this.x - center.x;
		var y = this.y - center.y;

		this.x = x * c - y * s + center.x;
		this.y = x * s + y * c + center.y;

		return this;

	}

	Vector2 random() {
		this.x = Math.random();
		this.y = Math.random();

		return this;
	}


  Vector2.fromJson(Map<String, dynamic> json) {
    x = json['x'];
    y = json['y'];
  }

  Map<String, dynamic> toJson() {
    return {
      'x': x,
      'y': y
    };
  }

}

