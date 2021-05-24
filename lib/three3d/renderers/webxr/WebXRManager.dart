
// import 'package:three_dart/three3d/cameras/index.dart';
// import 'package:three_dart/three3d/core/index.dart';
// import 'package:three_dart/three3d/math/index.dart';
// import 'package:three_dart/three3d/renderers/index.dart';




// class WebXRManager with EventDispatcher {

//   WebXRManager scope;
//   dynamic gl;
//   WebGLRenderer renderer;



// 	late dynamic session;

// 	num framebufferScaleFactor = 1.0;

// 	var referenceSpace = null;
// 	String referenceSpaceType = 'local-floor';

// 	var pose = null;

// 	var controllers = [];
// 	Map inputSourcesMap = new Map();

//   var cameraL = PerspectiveCamera();
//   var cameraR = PerspectiveCamera();


// 	List<Camera> cameras;

// 	var cameraVR = ArrayCamera([]);
	
// 	var _currentDepthNear = null;
// 	var _currentDepthFar = null;

// 	//
// 	bool enabled = false;
// 	bool isPresenting = false;

//   WebXRManager( WebGLRenderer renderer, gl ) {
//     renderer = renderer;
//     gl = gl;

//     cameras = [ cameraL, cameraR ];
//     scope = this;

//     cameraL.layers.enable( 1 );
// 	  cameraL.viewport = new Vector4.init();

//     cameraR.layers.enable( 2 );
// 	  cameraR.viewport = new Vector4.init();

//     cameraVR.layers.enable( 1 );
// 	  cameraVR.layers.enable( 2 );

//   }



	

// 	getController ( index ) {

// 		var controller = controllers[ index ];

// 		if ( controller == null ) {

// 			controller = new WebXRController();
// 			controllers[ index ] = controller;

// 		}

// 		return controller.getTargetRaySpace();

// 	}

// 	getControllerGrip ( index ) {

// 		var controller = controllers[ index ];

// 		if ( controller == null ) {

// 			controller = new WebXRController();
// 			controllers[ index ] = controller;

// 		}

// 		return controller.getGripSpace();

// 	}

// 	getHand( index ) {

// 		var controller = controllers[ index ];

// 		if ( controller == null ) {

// 			controller = new WebXRController();
// 			controllers[ index ] = controller;

// 		}

// 		return controller.getHandSpace();

// 	};

// 	//

// 	onSessionEvent( event ) {

// 		var controller = inputSourcesMap.get( event.inputSource );

// 		if ( controller ) {

// 			controller.dispatchEvent( { type: event.type, data: event.inputSource } );

// 		}

// 	}

// 	onSessionEnd() {

// 		inputSourcesMap.forEach( ( controller, inputSource ) {

// 			controller.disconnect( inputSource );

// 		} );

// 		inputSourcesMap.clear();

// 		//

// 		renderer.setFramebuffer( null );
// 		renderer.setRenderTarget( renderer.getRenderTarget() ); // Hack #15830
// 		animation.stop();

// 		scope.isPresenting = false;

// 		scope.dispatchEvent( Event("sessionend", null, null) );

// 	}

// 	onRequestReferenceSpace( value ) {

// 		referenceSpace = value;

// 		animation.setContext( session );
// 		animation.start();

// 		scope.isPresenting = true;

// 		scope.dispatchEvent( Event("sessionstart", null, null) );

// 	}

// 	setFramebufferScaleFactor ( value ) {

// 		framebufferScaleFactor = value;

// 		if ( scope.isPresenting == true ) {

// 			print( 'THREE.WebXRManager: Cannot change framebuffer scale while presenting.' );

// 		}

// 	};

// 	setReferenceSpaceType ( value ) {

// 		referenceSpaceType = value;

// 		if ( scope.isPresenting == true ) {

// 			print( 'THREE.WebXRManager: Cannot change reference space type while presenting.' );

// 		}

// 	}

// 	getReferenceSpace () {

// 		return referenceSpace;

// 	}

// 	getSession () {

// 		return session;

// 	}

// 	setSession ( value ) {

// 		session = value;

// 		if ( session != null ) {

// 			session.addEventListener( 'select', onSessionEvent );
// 			session.addEventListener( 'selectstart', onSessionEvent );
// 			session.addEventListener( 'selectend', onSessionEvent );
// 			session.addEventListener( 'squeeze', onSessionEvent );
// 			session.addEventListener( 'squeezestart', onSessionEvent );
// 			session.addEventListener( 'squeezeend', onSessionEvent );
// 			session.addEventListener( 'end', onSessionEnd );

// 			var attributes = gl.getContextAttributes();

// 			if ( attributes.xrCompatible != true ) {

// 				gl.makeXRCompatible();

// 			}

// 			var layerInit = {
// 				antialias: attributes.antialias,
// 				alpha: attributes.alpha,
// 				depth: attributes.depth,
// 				stencil: attributes.stencil,
// 				framebufferScaleFactor: framebufferScaleFactor
// 			};

// 			// eslint-disable-next-line no-undef
// 			var baseLayer = new XRWebGLLayer( session, gl, layerInit );

// 			session.updateRenderState( { baseLayer: baseLayer } );

// 			session.requestReferenceSpace( referenceSpaceType ).then( onRequestReferenceSpace );

// 			//

// 			session.addEventListener( 'inputsourceschange', updateInputSources );

// 		}

// 	}

// 	updateInputSources( event ) {

// 		var inputSources = session.inputSources;

// 		// Assign inputSources to available controllers

// 		for ( var i = 0; i < controllers.length; i ++ ) {

// 			inputSourcesMap.set( inputSources[ i ], controllers[ i ] );

// 		}

// 		// Notify disconnected

// 		for ( var i = 0; i < event.removed.length; i ++ ) {

// 			var inputSource = event.removed[ i ];
// 			var controller = inputSourcesMap.get( inputSource );

// 			if ( controller ) {

// 				controller.dispatchEvent( { type: 'disconnected', data: inputSource } );
// 				inputSourcesMap.delete( inputSource );

// 			}

// 		}

// 		// Notify connected

// 		for ( var i = 0; i < event.added.length; i ++ ) {

// 			var inputSource = event.added[ i ];
// 			var controller = inputSourcesMap.get( inputSource );

// 			if ( controller ) {

// 				controller.dispatchEvent( { type: 'connected', data: inputSource } );

// 			}

// 		}

// 	}

// 	//

// 	var cameraLPos = new Vector3.init();
// 	var cameraRPos = new Vector3.init();

// 	/**
// 	 * Assumes 2 cameras that are parallel and share an X-axis, and that
// 	 * the cameras' projection and world matrices have already been set.
// 	 * And that near and far planes are identical for both cameras.
// 	 * Visualization of this technique: https://computergraphics.stackexchange.com/a/4765
// 	 */
// 	setProjectionFromUnion( camera, cameraL, cameraR ) {

// 		cameraLPos.setFromMatrixPosition( cameraL.matrixWorld );
// 		cameraRPos.setFromMatrixPosition( cameraR.matrixWorld );

// 		var ipd = cameraLPos.distanceTo( cameraRPos );

// 		var projL = cameraL.projectionMatrix.elements;
// 		var projR = cameraR.projectionMatrix.elements;

// 		// VR systems will have identical far and near planes, and
// 		// most likely identical top and bottom frustum extents.
// 		// Use the left camera for these values.
// 		var near = projL[ 14 ] / ( projL[ 10 ] - 1 );
// 		var far = projL[ 14 ] / ( projL[ 10 ] + 1 );
// 		var topFov = ( projL[ 9 ] + 1 ) / projL[ 5 ];
// 		var bottomFov = ( projL[ 9 ] - 1 ) / projL[ 5 ];

// 		var leftFov = ( projL[ 8 ] - 1 ) / projL[ 0 ];
// 		var rightFov = ( projR[ 8 ] + 1 ) / projR[ 0 ];
// 		var left = near * leftFov;
// 		var right = near * rightFov;

// 		// Calculate the new camera's position offset from the
// 		// left camera. xOffset should be roughly half `ipd`.
// 		var zOffset = ipd / ( - leftFov + rightFov );
// 		var xOffset = zOffset * - leftFov;

// 		// TODO: Better way to apply this offset?
// 		cameraL.matrixWorld.decompose( camera.position, camera.quaternion, camera.scale );
// 		camera.translateX( xOffset );
// 		camera.translateZ( zOffset );
// 		camera.matrixWorld.compose( camera.position, camera.quaternion, camera.scale );
// 		camera.matrixWorldInverse.copy( camera.matrixWorld ).invert();

// 		// Find the union of the frustum values of the cameras and scale
// 		// the values so that the near plane's position does not change in world space,
// 		// although must now be relative to the new union camera.
// 		var near2 = near + zOffset;
// 		var far2 = far + zOffset;
// 		var left2 = left - xOffset;
// 		var right2 = right + ( ipd - xOffset );
// 		var top2 = topFov * far / far2 * near2;
// 		var bottom2 = bottomFov * far / far2 * near2;

// 		camera.projectionMatrix.makePerspective( left2, right2, top2, bottom2, near2, far2 );

// 	}

// 	updateCamera( camera, parent ) {

// 		if ( parent == null ) {

// 			camera.matrixWorld.copy( camera.matrix );

// 		} else {

// 			camera.matrixWorld.multiplyMatrices( parent.matrixWorld, camera.matrix );

// 		}

// 		camera.matrixWorldInverse.copy( camera.matrixWorld ).invert();

// 	}

// 	getCamera ( camera ) {

// 		cameraVR.near = cameraR.near = cameraL.near = camera.near;
// 		cameraVR.far = cameraR.far = cameraL.far = camera.far;

// 		if ( _currentDepthNear != cameraVR.near || _currentDepthFar != cameraVR.far ) {

// 			// Note that the new renderState won't apply until the next frame. See #18320

// 			session.updateRenderState( {
// 				"depthNear": cameraVR.near,
// 				"depthFar": cameraVR.far
// 			} );

// 			_currentDepthNear = cameraVR.near;
// 			_currentDepthFar = cameraVR.far;

// 		}

// 		var parent = camera.parent;
// 		var cameras = cameraVR.cameras;

// 		updateCamera( cameraVR, parent );

// 		for ( var i = 0; i < cameras.length; i ++ ) {

// 			updateCamera( cameras[ i ], parent );

// 		}

// 		// update camera and its children

// 		camera.matrixWorld.copy( cameraVR.matrixWorld );

// 		var children = camera.children;

// 		for ( var i = 0, l = children.length; i < l; i ++ ) {

// 			children[ i ].updateMatrixWorld( true );

// 		}

// 		// update projection matrix for proper view frustum culling

// 		if ( cameras.length == 2 ) {

// 			setProjectionFromUnion( cameraVR, cameraL, cameraR );

// 		} else {

// 			// assume single camera setup (AR)

// 			cameraVR.projectionMatrix.copy( cameraL.projectionMatrix );

// 		}

// 		return cameraVR;

// 	}

// 	// Animation Loop

// 	var onAnimationFrameCallback = null;

// 	onAnimationFrame( time, frame ) {

// 		pose = frame.getViewerPose( referenceSpace );

// 		if ( pose != null ) {

// 			var views = pose.views;
// 			var baseLayer = session.renderState.baseLayer;

// 			renderer.setFramebuffer( baseLayer.framebuffer );

// 			var cameraVRNeedsUpdate = false;

// 			// check if it's necessary to rebuild cameraVR's camera list

// 			if ( views.length != cameraVR.cameras.length ) {

// 				cameraVR.cameras.length = 0;
// 				cameraVRNeedsUpdate = true;

// 			}

// 			for ( var i = 0; i < views.length; i ++ ) {

// 				var view = views[ i ];
// 				var viewport = baseLayer.getViewport( view );

// 				var camera = cameras[ i ];
// 				camera.matrix.fromArray( view.transform.matrix );
// 				camera.projectionMatrix.fromArray( view.projectionMatrix );
// 				camera.viewport.set( viewport.x, viewport.y, viewport.width, viewport.height );

// 				if ( i == 0 ) {

// 					cameraVR.matrix.copy( camera.matrix );

// 				}

// 				if ( cameraVRNeedsUpdate == true ) {

// 					cameraVR.cameras.push( camera );

// 				}

// 			}

// 		}

// 		//

// 		var inputSources = session.inputSources;

// 		for ( var i = 0; i < controllers.length; i ++ ) {

// 			var controller = controllers[ i ];
// 			var inputSource = inputSources[ i ];

// 			controller.update( inputSource, frame, referenceSpace );

// 		}

// 		if ( onAnimationFrameCallback ) onAnimationFrameCallback( time, frame );

// 	}

// 	// var animation = new WebGLAnimation();
// 	// animation.setAnimationLoop( onAnimationFrame );

// 	// setAnimationLoop ( callback ) {

// 	// 	onAnimationFrameCallback = callback;

// 	// }

// 	dispose() {

//   }

// }
