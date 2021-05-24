
part of three_scenes;


class Fog {

  String name = "";
  late Color color;

  bool isFog = true;
  bool isFogExp2 = false;

  late num near;
  late num far;


	Fog( Color color, num? near, num? far ) {
		this.name = '';

		this.color = color;

		this.near = near ?? 1;
		this.far = far ?? 1000;

	}

	clone() {

		return new Fog( this.color, this.near, this.far );

	}

	toJSON( /* meta */ ) {

		return {
			"type": 'Fog',
			"color": this.color.getHex(),
			"near": this.near,
			"far": this.far
		};

	}

}


