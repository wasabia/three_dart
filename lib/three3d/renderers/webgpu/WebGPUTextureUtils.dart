// Copyright 2020 Brandon Jones
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:

// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.

// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.


// ported from https://github.com/toji/web-texture-tool/blob/master/src/webgpu-mipmap-generator.js

part of three_webgpu;

class WebGPUTextureUtils {

  late GPUDevice device;
  late GPUSampler sampler;
  late dynamic pipelines;
  late dynamic mipmapVertexShaderModule;
  late dynamic mipmapFragmentShaderModule;


	WebGPUTextureUtils( device ) {

		this.device = device;

		var mipmapVertexSource = """
struct VarysStruct {

	[[ builtin( position ) ]] Position: vec4<f32>;
	[[ location( 0 ) ]] vTex : vec2<f32>;

};

[[ stage( vertex ) ]]
fn main( [[ builtin( vertex_index ) ]] vertexIndex : u32 ) -> VarysStruct {

	var Varys: VarysStruct;

	var pos = array< vec2<f32>, 4 >(
		vec2<f32>( -1.0,  1.0 ),
		vec2<f32>(  1.0,  1.0 ),
		vec2<f32>( -1.0, -1.0 ),
		vec2<f32>(  1.0, -1.0 )
	);

	var tex = array< vec2<f32>, 4 >(
		vec2<f32>( 0.0, 0.0 ),
		vec2<f32>( 1.0, 0.0 ),
		vec2<f32>( 0.0, 1.0 ),
		vec2<f32>( 1.0, 1.0 )
	);

	Varys.vTex = tex[ vertexIndex ];
	Varys.Position = vec4<f32>( pos[ vertexIndex ], 0.0, 1.0 );

	return Varys;

}
""";

		var mipmapFragmentSource = """
[[ group( 0 ), binding( 0 ) ]] 
var imgSampler : sampler;

[[ group( 0 ), binding( 1 ) ]] 
var img : texture_2d<f32>;

[[ stage( fragment ) ]]
fn main( [[ location( 0 ) ]] vTex : vec2<f32> ) -> [[ location( 0 ) ]] vec4<f32> {

	return textureSample( img, imgSampler, vTex );

}
""";

		this.sampler = device.createSampler( { "minFilter": GPUFilterMode.Linear } );

		// We'll need a new pipeline for every texture format used.
		this.pipelines = {};

		this.mipmapVertexShaderModule = device.createShaderModule(
      GPUShaderModuleDescriptor(
        code: mipmapVertexSource
      )
    );

		this.mipmapFragmentShaderModule = device.createShaderModule(   
      GPUShaderModuleDescriptor(
        code: mipmapFragmentSource
      )
    );

	}

	getMipmapPipeline( format ) {

		var pipeline = this.pipelines[ format ];

		if ( pipeline == undefined ) {

			pipeline = this.device.createRenderPipeline( 
        
        GPURenderPipelineDescriptor(
          vertex: GPUVertexState(module: mipmapVertexShaderModule, entryPoint: 'main'),
          fragment: GPUFragmentState(
            module: mipmapFragmentShaderModule, 
            entryPoint: 'main', 
            targets: GPUColorTargetState(format: format)
          ),
          primitive: GPUPrimitiveState(
            topology: GPUPrimitiveTopology.TriangleStrip,
            stripIndexFormat: GPUIndexFormat.Uint32
          ),
          multisample: GPUMultisampleState()
        )
        
      );

			this.pipelines[ format ] = pipeline;

		}

		return pipeline;

	}

	generateMipmaps( GPUTexture textureGPU, textureGPUDescriptor ) {

		var pipeline = this.getMipmapPipeline( textureGPUDescriptor.format );

		var commandEncoder = this.device.createCommandEncoder();
		var bindGroupLayout = pipeline.getBindGroupLayout( 0 ); // @TODO: Consider making this static.

		var srcView = textureGPU.createView(
      GPUTextureViewDescriptor(
        baseMipLevel: 0,
        mipLevelCount: 1
      )
    );

		for ( var i = 1; i < textureGPUDescriptor.mipLevelCount; i ++ ) {

			var dstView = textureGPU.createView(
        GPUTextureViewDescriptor(
          baseMipLevel: i,
          mipLevelCount: 1
        )
      );

			var passEncoder = commandEncoder.beginRenderPass( 
        GPURenderPassDescriptor(
          colorAttachments: GPURenderPassColorAttachment(
            view: dstView, clearColor: GPUColor(r: 0, g: 0, b: 0, a: 0),

            loadOp: GPULoadOp.Clear, // TODO Confirm
            storeOp: GPUStoreOp.Store // TODO Confirm
          ),
          depthStencilAttachment: GPURenderPassDepthStencilAttachment()
        )
      );

			var bindGroup = this.device.createBindGroup(
        GPUBindGroupDescriptor(
          layout: bindGroupLayout,
          entries: [
            GPUBindGroupEntry(
              binding: 0,
              sampler: this.sampler
            ),
            GPUBindGroupEntry(
              binding: 1,
              textureView: srcView
            )
          ],
          entryCount: 2
        )
      );

			passEncoder.setPipeline( pipeline );
			passEncoder.setBindGroup( 0, bindGroup );
			passEncoder.draw( 4, 1, 0, 0 );
			passEncoder.endPass();

			srcView = dstView;

		}

		this.device.queue.submit( commandEncoder.finish() );

	}

}