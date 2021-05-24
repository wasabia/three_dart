part of three_extra;

class Shape extends Path {

  late String uuid;
  late List<Path> holes;
  String type = "Shape";


   Shape( points ) : super(points) {
    this.uuid = MathUtils.generateUUID();
    this.holes = [];
   }

  Shape.fromJSON (Map<String, dynamic> json ): super.fromJSON(json) {


		this.uuid = json["uuid"];
		this.holes = [];

		for ( var i = 0, l = json["holes"].length; i < l; i ++ ) {

			var hole = json["holes"][ i ];
			this.holes.add( new Path.fromJSON( hole ) );

		}

	}

  


	getPointsHoles ( divisions ) {

		var holesPts = List<dynamic>.filled(this.holes.length, null);

		for ( var i = 0, l = this.holes.length; i < l; i ++ ) {

			holesPts[ i ] = this.holes[ i ].getPoints( divisions: divisions );

		}

		return holesPts;

	}

	// get points of shape and holes (keypoints based on segments parameter)

	Map<String, dynamic> extractPoints ( divisions ) {

		return {

			"shape": this.getPoints( divisions: divisions ),
			"holes": this.getPointsHoles( divisions )

		};

	}

	copy ( source ) {

		super.copy( source );

		this.holes = [];

		for ( var i = 0, l = source.holes.length; i < l; i ++ ) {

			var hole = source.holes[ i ];

			this.holes.add( hole.clone() );

		}

		return this;

	}

	toJSON ({Object3dMeta? meta}) {

		var data = super.toJSON( );

		data["uuid"] = this.uuid;
		data["holes"] = [];

		for ( var i = 0, l = this.holes.length; i < l; i ++ ) {

			var hole = this.holes[ i ];
			data["holes"].add( hole.toJSON() );

		}

		return data;

	}

	
}

