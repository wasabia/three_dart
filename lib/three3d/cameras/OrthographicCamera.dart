part of three_camera;

class OrthographicCamera extends Camera {

  bool isOrthographicCamera = true;
  String type = 'OrthographicCamera';

  double zoom = 1;

  OrthographicCamera([num left=-1, num right=1, num top=1, num bottom=-1, num near=0.1, num far=2000]) : super() {

    this.view = null;

    this.left = left;
    this.right = right;
    this.top = top;
    this.bottom = bottom;

    this.near = near;
    this.far = far;

    this.updateProjectionMatrix();

  }


  copy ( source, recursive ) {

		super.copy( source, recursive );

    OrthographicCamera source1 = source as OrthographicCamera;

		this.left = source1.left;
		this.right = source1.right;
		this.top = source1.top;
		this.bottom = source1.bottom;
		this.near = source1.near;
		this.far = source1.far;

		this.zoom = source1.zoom;
		this.view = source1.view == null ? null : json.decode(json.encode(source1.view));

		return this;

	}

	setViewOffset ( fullWidth, fullHeight, x, y, width, height ) {

		if ( this.view == null ) {

			this.view = {
				"enabled": true,
				"fullWidth": 1,
				"fullHeight": 1,
				"offsetX": 0,
				"offsetY": 0,
				"width": 1,
				"height": 1
			};

		}

		this.view!["enabled"] = true;
		this.view!["fullWidth"] = fullWidth;
		this.view!["fullHeight"] = fullHeight;
		this.view!["offsetX"] = x;
		this.view!["offsetY"] = y;
		this.view!["width"] = width;
		this.view!["height"] = height;

		this.updateProjectionMatrix();

	}

	clearViewOffset () {

		if ( this.view != null ) {

			this.view!["enabled"] = false;

		}

		this.updateProjectionMatrix();

	}

	updateProjectionMatrix () {

		var dx = ( this.right - this.left ) / ( 2 * this.zoom );
		var dy = ( this.top - this.bottom ) / ( 2 * this.zoom );
		var cx = ( this.right + this.left ) / 2;
		var cy = ( this.top + this.bottom ) / 2;

		var left = cx - dx;
		var right = cx + dx;
		var top = cy + dy;
		var bottom = cy - dy;

		if ( this.view != null && this.view!["enabled"] ) {

			var scaleW = ( this.right - this.left ) / this.view!["fullWidth"] / this.zoom;
			var scaleH = ( this.top - this.bottom ) / this.view!["fullHeight"] / this.zoom;

			left += scaleW * this.view!["offsetX"];
			right = left + scaleW * this.view!["width"];
			top -= scaleH * this.view!["offsetY"];
			bottom = top - scaleH * this.view!["height"];

		}

		this.projectionMatrix.makeOrthographic( left, right, top, bottom, this.near, this.far );

		this.projectionMatrixInverse.copy( this.projectionMatrix ).invert();

	}

	toJSON ( {Object3dMeta? meta}  ) {

		var data = super.toJSON( meta: meta );

		data["object"]["zoom"] = this.zoom;
		data["object"]["left"] = this.left;
		data["object"]["right"] = this.right;
		data["object"]["top"] = this.top;
		data["object"]["bottom"] = this.bottom;
		data["object"]["near"] = this.near;
		data["object"]["far"] = this.far;

		if ( this.view != null ) data["object"]["view"] = json.decode(json.encode(this.view));

		return data;

	}
	

}
