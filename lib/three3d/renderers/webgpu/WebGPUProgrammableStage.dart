part of three_webgpu;

int _id = 0;

class WebGPUProgrammableStage {

  late int id;
  late dynamic code;
  late dynamic type;
  late int usedTimes;

  late Map stage;

	WebGPUProgrammableStage( GPUDevice device, code, type ) {

		this.id = _id ++;

		this.code = code;
		this.type = type;
		this.usedTimes = 0;


    var module = device.createShaderModule( GPUShaderModuleDescriptor(code: code) );
		this.stage = {
			"module": module,
			"entryPoint": 'main'
		};

	}

}


