
part of three_core;


class Face3 {

  late int a;
  late int b;
  late int c;
  late Vector3 normal;
  late List<Vector3> vertexNormals;
  late Color color;
  late List<Color> vertexColors;
  late int materialIndex;

	Face3( a, b, c, normal, color, {int materialIndex = 0} ) {

		this.a = a;
		this.b = b;
		this.c = c;


		this.normal = ( normal != null && normal.runtimeType == Vector3 ) ? normal : new Vector3.init();
		this.vertexNormals = normal != null ? normal : [];

		this.color = ( color != null && color.runtimeType == Color ) ? color : new Color(0,0,0);
		this.vertexColors = color != null ? color : [];

		this.materialIndex = materialIndex;

	}

	clone() {
		return Face3(0,0,0,null,null).copy( this );
	}

	copy( Face3 source ) {

		this.a = source.a;
		this.b = source.b;
		this.c = source.c;

		this.normal.copy( source.normal );
		this.color.copy( source.color );

		this.materialIndex = source.materialIndex;

    this.vertexNormals = List<Vector3>.filled(source.vertexNormals.length, Vector3.init());

		for ( var i = 0, il = source.vertexNormals.length; i < il; i ++ ) {

			this.vertexNormals[ i ] = source.vertexNormals[ i ].clone();

		}


     this.vertexColors = List<Color>.filled(source.vertexColors.length, Color(0,0,0));
		for ( var i = 0, il = source.vertexColors.length; i < il; i ++ ) {

			this.vertexColors[ i ] = source.vertexColors[ i ].clone();

		}

		return this;

	}

}


