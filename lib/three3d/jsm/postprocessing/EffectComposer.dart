
part of jsm_postprocessing;



class EffectComposer {

  late WebGLRenderer renderer;
  late WebGLRenderTarget renderTarget1;
  late WebGLRenderTarget renderTarget2;

  late WebGLRenderTarget writeBuffer;
  late WebGLRenderTarget readBuffer;

  bool renderToScreen = true;

  num _pixelRatio = 1.0;
  late num _width;
  late num _height;

  List<Pass> passes = [];

  late Clock clock;

  late Pass copyPass;

  EffectComposer( WebGLRenderer renderer, WebGLRenderTarget? renderTarget ) {
    this.renderer = renderer;

    if ( renderTarget == null ) {

      var parameters = {
        "minFilter": LinearFilter,
        "magFilter": LinearFilter,
        "format": RGBAFormat
      };

      var size = renderer.getSize( new Vector2(null, null) );
      this._pixelRatio = renderer.getPixelRatio();
      this._width = size.width;
      this._height = size.height;

      renderTarget = new WebGLRenderTarget( 
        (this._width * this._pixelRatio).toInt(), 
        (this._height * this._pixelRatio).toInt(), 
        WebGLRenderTargetOptions(parameters) 
      );
      renderTarget.texture.name = 'EffectComposer.rt1';

    } else {

      this._pixelRatio = 1;
      this._width = renderTarget.width;
      this._height = renderTarget.height;

    }

    this.renderTarget1 = renderTarget;
    this.renderTarget2 = renderTarget.clone();
    this.renderTarget2.texture.name = 'EffectComposer.rt2';

    this.writeBuffer = this.renderTarget1;
    this.readBuffer = this.renderTarget2;

    this.renderToScreen = true;

    this.passes = [];

    // dependencies

    if ( CopyShader == null ) {

      print( 'THREE.EffectComposer relies on CopyShader' );

    }

    if ( ShaderPass == null ) {

      print( 'THREE.EffectComposer relies on ShaderPass' );

    }

    this.copyPass = new ShaderPass( CopyShader, null );

    this.clock = new Clock(false);
  }

	swapBuffers () {

		var tmp = this.readBuffer;
		this.readBuffer = this.writeBuffer;
		this.writeBuffer = tmp;

	}

	addPass ( pass ) {

		this.passes.add( pass );
		pass.setSize( this._width * this._pixelRatio, this._height * this._pixelRatio );

	}

	insertPass ( pass, index ) {

		splice(this.passes, index, 0, pass );
		pass.setSize( this._width * this._pixelRatio, this._height * this._pixelRatio );

	}

	removePass ( pass ) {

		var index = this.passes.indexOf( pass );

		if ( index != - 1 ) {

			splice(this.passes, index, 1 );

		}

	}

  clearPass() {
    this.passes.clear();
  }

	isLastEnabledPass ( passIndex ) {

		for ( var i = passIndex + 1; i < this.passes.length; i ++ ) {

			if ( this.passes[ i ].enabled ) {

				return false;

			}

		}

		return true;

	}

	render ( deltaTime ) {

		// deltaTime value is in seconds

		if ( deltaTime == null ) {

			deltaTime = this.clock.getDelta();

		}

		var currentRenderTarget = this.renderer.getRenderTarget();

		var maskActive = false;

		var pass, i, il = this.passes.length;


		for ( i = 0; i < il; i ++ ) {

			pass = this.passes[ i ];

			if ( pass.enabled == false ) continue;

			pass.renderToScreen = ( this.renderToScreen && this.isLastEnabledPass( i ) );
			pass.render( this.renderer, this.writeBuffer, this.readBuffer, deltaTime: deltaTime, maskActive: maskActive );

			if ( pass.needsSwap ) {

				if ( maskActive ) {

					var context = this.renderer.getContext();
					var stencil = this.renderer.state.buffers["stencil"];

					//context.stencilFunc( context.NOTEQUAL, 1, 0xffffffff );
					stencil.setFunc( context.NOTEQUAL, 1, 0xffffffff );

					this.copyPass.render( this.renderer, this.writeBuffer, this.readBuffer, deltaTime: deltaTime );

					//context.stencilFunc( context.EQUAL, 1, 0xffffffff );
					stencil.setFunc( context.EQUAL, 1, 0xffffffff );

				}

				this.swapBuffers();

			}

			if ( MaskPass != null ) {

				if ( pass.runtimeType.toString() == "MaskPass" ) {

					maskActive = true;

				} else if ( pass.runtimeType.toString() == "ClearMaskPass" ) {

					maskActive = false;

				}

			}

		}

		this.renderer.setRenderTarget( currentRenderTarget );

	}

	reset( renderTarget ) {

		if ( renderTarget == null ) {

			var size = this.renderer.getSize( new Vector2(null, null) );
			this._pixelRatio = this.renderer.getPixelRatio();
			this._width = size.width;
			this._height = size.height;

			renderTarget = this.renderTarget1.clone();
			renderTarget.setSize( this._width * this._pixelRatio, this._height * this._pixelRatio );

		}

		this.renderTarget1.dispose();
		this.renderTarget2.dispose();
		this.renderTarget1 = renderTarget;
		this.renderTarget2 = renderTarget.clone();

		this.writeBuffer = this.renderTarget1;
		this.readBuffer = this.renderTarget2;

	}

	setSize ( width, height ) {

		this._width = width;
		this._height = height;

		var effectiveWidth = this._width * this._pixelRatio;
		var effectiveHeight = this._height * this._pixelRatio;

		this.renderTarget1.setSize( effectiveWidth, effectiveHeight );
		this.renderTarget2.setSize( effectiveWidth, effectiveHeight );

		for ( var i = 0; i < this.passes.length; i ++ ) {

			this.passes[ i ].setSize( effectiveWidth, effectiveHeight );

		}

	}

	setPixelRatio ( pixelRatio ) {

		this._pixelRatio = pixelRatio;

		this.setSize( this._width, this._height );

	}


}