part of three_webgpu;

class WebGPUBinding {

  late String name;
  late dynamic visibility;
  late dynamic type;
  late bool isShared;

	WebGPUBinding( [name = ''] ) {

		this.name = name;
		this.visibility = null;

		this.type = null; // read-only

		this.isShared = false;

	}

	setVisibility( visibility ) {

		this.visibility = visibility;

	}

}

