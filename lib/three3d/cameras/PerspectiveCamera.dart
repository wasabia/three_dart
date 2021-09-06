part of three_camera;

class PerspectiveCamera extends Camera {

  String type = "PerspectiveCamera";
  bool isPerspectiveCamera = true;

  // near 设置太小 导致 画面异常 精度问题？ 浮点运算问题？？
  PerspectiveCamera({num fov = 50, num aspect = 1, num near = 0.1, num far = 2000}) : super() {
    this.fov = fov;
    this.aspect = aspect;
    this.near = near;
    this.far = far;

	  updateProjectionMatrix();
  }

  PerspectiveCamera.fromJSON(Map<String, dynamic> json, Map<String, dynamic> rootJSON) : super.fromJSON(json, rootJSON) {
    fov = json["fov"];
    aspect = json["aspect"];
    near = json["near"];
    far = json["far"];

    updateProjectionMatrix();
  }



  copy( Object3D source, recursive ) {

    super.copy(source, recursive);

    PerspectiveCamera source1 = source as PerspectiveCamera;

    this.fov = source1.fov;
    this.zoom = source1.zoom;

    this.near = source1.near;
    this.far = source1.far;
    this.focus = source1.focus;

    this.aspect = source1.aspect;
    this.view = source1.view == null ? null : json.decode(json.encode(source1.view));

    this.filmGauge = source1.filmGauge;
    this.filmOffset = source1.filmOffset;

    return this;
	}

  clone (bool recursive) {

		return PerspectiveCamera().copy( this, false );

	}

// 	/**
// 	 * Sets the FOV by focal length in respect to the current .filmGauge.
// 	 *
// 	 * The default film gauge is 35, so that the focal length can be specified for
// 	 * a 35mm (full frame) camera.
// 	 *
// 	 * Values for focal length and film gauge must have the same unit.
// 	 */
// 	setFocalLength: function ( focalLength ) {

// 		// see http://www.bobatkins.com/photography/technical/field_of_view.html
// 		const vExtentSlope = 0.5 * this.getFilmHeight() / focalLength;

// 		this.fov = MathUtils.RAD2DEG * 2 * Math.atan( vExtentSlope );
// 		this.updateProjectionMatrix();

// 	},

// 	/**
// 	 * Calculates the focal length from the current .fov and .filmGauge.
// 	 */
// 	getFocalLength: function () {

// 		const vExtentSlope = Math.tan( MathUtils.DEG2RAD * 0.5 * this.fov );

// 		return 0.5 * this.getFilmHeight() / vExtentSlope;

// 	},

// 	getEffectiveFOV: function () {

// 		return MathUtils.RAD2DEG * 2 * Math.atan(
// 			Math.tan( MathUtils.DEG2RAD * 0.5 * this.fov ) / this.zoom );

// 	},

	getFilmWidth() {

		// film not completely covered in portrait format (aspect < 1)
		return this.filmGauge * Math.min( this.aspect, 1 );

	}

	getFilmHeight() {

		// film not completely covered in landscape format (aspect > 1)
		return this.filmGauge / Math.max( this.aspect, 1 );

	}

// 	/**
// 	 * Sets an offset in a larger frustum. This is useful for multi-window or
// 	 * multi-monitor/multi-machine setups.
// 	 *
// 	 * For example, if you have 3x2 monitors and each monitor is 1920x1080 and
// 	 * the monitors are in grid like this
// 	 *
// 	 *   +---+---+---+
// 	 *   | A | B | C |
// 	 *   +---+---+---+
// 	 *   | D | E | F |
// 	 *   +---+---+---+
// 	 *
// 	 * then for each monitor you would call it like this
// 	 *
// 	 *   const w = 1920;
// 	 *   const h = 1080;
// 	 *   const fullWidth = w * 3;
// 	 *   const fullHeight = h * 2;
// 	 *
// 	 *   --A--
// 	 *   camera.setViewOffset( fullWidth, fullHeight, w * 0, h * 0, w, h );
// 	 *   --B--
// 	 *   camera.setViewOffset( fullWidth, fullHeight, w * 1, h * 0, w, h );
// 	 *   --C--
// 	 *   camera.setViewOffset( fullWidth, fullHeight, w * 2, h * 0, w, h );
// 	 *   --D--
// 	 *   camera.setViewOffset( fullWidth, fullHeight, w * 0, h * 1, w, h );
// 	 *   --E--
// 	 *   camera.setViewOffset( fullWidth, fullHeight, w * 1, h * 1, w, h );
// 	 *   --F--
// 	 *   camera.setViewOffset( fullWidth, fullHeight, w * 2, h * 1, w, h );
// 	 *
// 	 *   Note there is no reason monitors have to be the same size or in a grid.
// 	 */
// 	setViewOffset: function ( fullWidth, fullHeight, x, y, width, height ) {

// 		this.aspect = fullWidth / fullHeight;

// 		if ( this.view === null ) {

// 			this.view = {
// 				enabled: true,
// 				fullWidth: 1,
// 				fullHeight: 1,
// 				offsetX: 0,
// 				offsetY: 0,
// 				width: 1,
// 				height: 1
// 			};

// 		}

// 		this.view.enabled = true;
// 		this.view.fullWidth = fullWidth;
// 		this.view.fullHeight = fullHeight;
// 		this.view.offsetX = x;
// 		this.view.offsetY = y;
// 		this.view.width = width;
// 		this.view.height = height;

// 		this.updateProjectionMatrix();

// 	},

// 	clearViewOffset: function () {

// 		if ( this.view !== null ) {

// 			this.view.enabled = false;

// 		}

// 		this.updateProjectionMatrix();

// 	},

	updateProjectionMatrix() {

		num near = this.near;
		num top = near * Math.tan( MathUtils.DEG2RAD * 0.5 * this.fov ) / this.zoom;
		num height = 2 * top;
		num width = this.aspect * height;
		num left = - 0.5 * width;

    print("updateProjectionMatrix: near: ${near} top: ${top} height: ${height} width: ${width} left: ${left} ");
    print(" view: ${view} ");

		if ( this.view != null && this.view!["enabled"] ) {

			var fullWidth = view!["fullWidth"]!;
			var fullHeight = view!["fullHeight"]!;

			left += view!["offsetX"]! * width / fullWidth;
			top -= view!["offsetY"]! * height / fullHeight;
			width *= view!["width"]! / fullWidth;
			height *= view!["height"]! / fullHeight;

		}

		num skew = this.filmOffset;
		if ( skew != 0 ) left += near * skew / this.getFilmWidth();

    print("skew: ${skew}  left: ${left} ");

		this.projectionMatrix.makePerspective( left, left + width, top, top - height, near, this.far );
		this.projectionMatrixInverse.copy( this.projectionMatrix ).invert();

    print("this.projectionMatrix: ${this.projectionMatrix.toJSON()}  ");
    print("this.projectionMatrixInverse: ${this.projectionMatrixInverse.toJSON()}  ");
	}

	toJSON( {Object3dMeta? meta} ) {

		Map<String, dynamic> output = super.toJSON(meta: meta);
    Map<String, dynamic> object = output["object"];

		object["fov"] = fov;
		object["zoom"] = zoom;

    object["near"] = near;
		object["far"] = far;
    object["focus"] = focus;

    object["aspect"] = aspect;
	
		if ( this.view != null ) object["view"] = json.decode(json.encode(this.view));


    object["filmGauge"] = filmGauge;
    object["filmOffset"] = filmOffset;

		return output;
	}


}
