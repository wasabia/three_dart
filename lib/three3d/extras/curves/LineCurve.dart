
part of three_extra;

class LineCurve extends Curve {



  bool isLineCurve = true;

  LineCurve( Vector2 v1, Vector2 v2 ) {
    
    this.type = 'LineCurve';

    this.v1 = v1;
    this.v2 = v2;
  }


  LineCurve.fromJSON ( Map<String, dynamic> json ) : super.fromJSON(json) {


  }


  getPoint( t, optionalTarget ) {

    var point = optionalTarget ?? Vector2(null,null);

    if ( t == 1 ) {

      point.copy( this.v2 );

    } else {

      point.copy( this.v2 ).sub( this.v1 );
      point.multiplyScalar( t ).add( this.v1 );

    }

    return point;

  }

  // Line curve is linear, so we can overwrite default getPointAt

  getPointAt ( u, optionalTarget ) {

    return this.getPoint( u, optionalTarget );

  }

  getTangent ( t, [optionalTarget] ) {

    var tangent = optionalTarget ?? new Vector2(null,null);

    tangent.copy( this.v2 ).sub( this.v1 ).normalize();

    return tangent;

  }

  copy ( source ) {

    super.copy( source );

    this.v1.copy( source.v1 );
    this.v2.copy( source.v2 );

    return this;

  }

  toJSON () {

    var data = super.toJSON( );

    data["v1"] = this.v1.toArray();
    data["v2"] = this.v2.toArray();

    return data;

  }



}

