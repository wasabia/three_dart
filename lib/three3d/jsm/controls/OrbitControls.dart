part of jsm_controls;


// This set of controls performs orbiting, dollying (zooming), and panning.
// Unlike TrackballControls, it maintains the "up" direction object.up (+Y by default).
//
//    Orbit - left mouse / touch: one-finger move
//    Zoom - middle mouse, or mousewheel / touch: two-finger spread or squish
//    Pan - right mouse, or left mouse + ctrl/meta/shiftKey, or arrow keys / touch: two-finger move
var STATE = {
  "NONE": - 1,
  "ROTATE": 0,
  "DOLLY": 1,
  "PAN": 2,
  "TOUCH_ROTATE": 3,
  "TOUCH_PAN": 4,
  "TOUCH_DOLLY_PAN": 5,
  "TOUCH_DOLLY_ROTATE": 6
};


class OrbitControls with EventDispatcher {

  late Camera object;
	dynamic domElement;

	// API
	late bool enabled;
	late Vector3 target;
  late Vector3 target0;
  late Vector3 position0;
  late double zoom0;

  num clientHeight = 400;
  num clientWidth = 400;
	// deprecated
	late Vector3 center;

	late double minDistance;
	late double maxDistance;

	late double minZoom;
	late double maxZoom;

	late double minPolarAngle;
	late double maxPolarAngle;

	late double minAzimuthAngle;
	late double maxAzimuthAngle;

	late bool enableDamping;
	late double dampingFactor;

	late bool enableZoom;
	late double zoomSpeed;

	late bool enableRotate;
	late double rotateSpeed;

	late bool enablePan;
	late double panSpeed;
	late bool screenSpacePanning;
	late double keyPanSpeed;

	late bool autoRotate;
	late double autoRotateSpeed;

	late bool enableKeys;
	late Map<String, dynamic> keys;
	late Map<String, dynamic> mouseButtons;
	late Map<String, dynamic> touches;


  var changeEvent = Event({ "type": 'change' });
	var startEvent = Event({ "type": 'start' });
	var endEvent = Event({ "type": 'end' });

	

	var state = STATE["NONE"];

	var EPS = 0.000001;

	// current position in spherical coordinates
	var spherical = new Spherical();
	var sphericalDelta = new Spherical();

	num scale = 1;
	var panOffset = new Vector3.init();
	var zoomChanged = false;

	var rotateStart = new Vector2(0, 0);
	var rotateEnd = new Vector2(null, null);
	var rotateDelta = new Vector2(null, null);

	var panStart = new Vector2(null, null);
	var panEnd = new Vector2(null, null);
	var panDelta = new Vector2(null, null);

	var dollyStart = new Vector2(null, null);
	var dollyEnd = new Vector2(null, null);
	var dollyDelta = new Vector2(null, null);

  OrbitControls( Camera object, domElement ) {
    this.object = object;
    this.domElement = domElement;

    // Set to false to disable this control
    this.enabled = true;

    // "target" sets the location of focus, where the object orbits around
    this.target = new Vector3.init();

    // How far you can dolly in and out ( PerspectiveCamera only )
    this.minDistance = 0;
    this.maxDistance = Math.Infinity;

    // How far you can zoom in and out ( OrthographicCamera only )
    this.minZoom = 0;
    this.maxZoom = Math.Infinity;

    // How far you can orbit vertically, upper and lower limits.
    // Range is 0 to Math.PI radians.
    this.minPolarAngle = 0; // radians
    this.maxPolarAngle = Math.PI; // radians

    // How far you can orbit horizontally, upper and lower limits.
    // If set, the interval [ min, max ] must be a sub-interval of [ - 2 PI, 2 PI ], with ( max - min < 2 PI )
    this.minAzimuthAngle = - Math.Infinity; // radians
    this.maxAzimuthAngle = Math.Infinity; // radians

    // Set to true to enable damping (inertia)
    // If damping is enabled, you must call controls.update() in your animation loop
    this.enableDamping = false;
    this.dampingFactor = 0.05;

    // This option actually enables dollying in and out; left as "zoom" for backwards compatibility.
    // Set to false to disable zooming
    this.enableZoom = true;
    this.zoomSpeed = 1.0;

    // Set to false to disable rotating
    this.enableRotate = true;
    this.rotateSpeed = 1.0;

    // Set to false to disable panning
    this.enablePan = true;
    this.panSpeed = 1.0;
    this.screenSpacePanning = true; // if false, pan orthogonal to world-space direction camera.up
    this.keyPanSpeed = 7.0;	// pixels moved per arrow key push

    // Set to true to automatically rotate around the target
    // If auto-rotate is enabled, you must call controls.update() in your animation loop
    this.autoRotate = false;
    this.autoRotateSpeed = 2.0; // 30 seconds per round when fps is 60

    // Set to false to disable use of the keys
    this.enableKeys = true;

    // The four arrow keys
    this.keys = { "LEFT": 37, "UP": 38, "RIGHT": 39, "BOTTOM": 40 };

    // Mouse buttons
    this.mouseButtons = { "LEFT": MOUSE["ROTATE"], "MIDDLE": MOUSE["DOLLY"], "RIGHT": MOUSE["PAN"] };

    // Touch fingers
    this.touches = { "ONE": TOUCH["ROTATE"], "TWO": TOUCH["DOLLY_PAN"] };

    // for reset
    this.target0 = this.target.clone();
    this.position0 = this.object.position.clone();
    this.zoom0 = this.object.zoom;


    this.domElement.addEventListener( 'contextmenu', onContextMenu, false );
    this.domElement.addEventListener( 'pointerdown', onPointerDown, false );
    this.domElement.addEventListener( 'wheel', onMouseWheel, false );
    this.domElement.addEventListener( 'touchstart', onTouchStart, false );
    this.domElement.addEventListener( 'touchend', onTouchEnd, false );
    this.domElement.addEventListener( 'pointerupdate', onPointerMove, false );
    this.domElement.addEventListener( 'keydown', onKeyDown, false );

    // force an update at start

    this.update();
  }

  //
	// public methods
	//

  getPolarAngle () {
		return spherical.phi;
	}

	getAzimuthalAngle () {

		return spherical.theta;

	}

	saveState () {

		this.target0.copy( this.target );
		this.position0.copy( this.object.position );
		this.zoom0 = this.object.zoom;

	}

	reset () {

		this.target.copy( this.target0 );
		this.object.position.copy( this.position0 );
		this.object.zoom = this.zoom0;

		this.object.updateProjectionMatrix();
		this.dispatchEvent( changeEvent );

		this.update();

		state = STATE["NONE"];

	}

	// this method is exposed, but perhaps it would be better if we can make it private...
	update () {

    print(" ---------------- update ........... ");

		var offset = new Vector3.init();

		// so camera.up is the orbit axis
		var quat = new Quaternion().setFromUnitVectors( object.up, new Vector3( 0.0, 1.0, 0.0 ) );
		var quatInverse = quat.clone().invert();

		var lastPosition = new Vector3.init();
		var lastQuaternion = new Quaternion();

		var twoPI = 2 * Math.PI;

		Function _update = () {

			var position = this.object.position;

			offset.copy( position ).sub( this.target );

			// rotate offset to "y-axis-is-up" space
			offset.applyQuaternion( quat );

			// angle from z-axis around y-axis
			spherical.setFromVector3( offset );

			if ( this.autoRotate && state == STATE["NONE"] ) {

				rotateLeft( getAutoRotationAngle() );

			}

			if ( this.enableDamping ) {

				spherical.theta += sphericalDelta.theta * this.dampingFactor;
				spherical.phi += sphericalDelta.phi * this.dampingFactor;

			} else {

				spherical.theta += sphericalDelta.theta;
				spherical.phi += sphericalDelta.phi;

			}

			// restrict theta to be between desired limits

			var min = this.minAzimuthAngle;
			var max = this.maxAzimuthAngle;

			if ( isFinite( min ) && isFinite( max ) ) {

				if ( min < - Math.PI ) min += twoPI; else if ( min > Math.PI ) min -= twoPI;

				if ( max < - Math.PI ) max += twoPI; else if ( max > Math.PI ) max -= twoPI;

				if ( min <= max ) {

					spherical.theta = Math.max( min, Math.min( max, spherical.theta ) );

				} else {

					spherical.theta = ( spherical.theta > ( min + max ) / 2 ) ?
						Math.max( min, spherical.theta ) :
						Math.min( max, spherical.theta );

				}

			}

			// restrict phi to be between desired limits
			spherical.phi = Math.max( this.minPolarAngle, Math.min( this.maxPolarAngle, spherical.phi ) );

			spherical.makeSafe();


			spherical.radius *= scale;

			// restrict radius to be between desired limits
			spherical.radius = Math.max( this.minDistance, Math.min( this.maxDistance, spherical.radius ) );

			// move target to panned location

			if ( this.enableDamping == true ) {

				this.target.addScaledVector( panOffset, this.dampingFactor );

			} else {

				this.target.add( panOffset );

			}

			offset.setFromSpherical( spherical );

			// rotate offset back to "camera-up-vector-is-up" space
			offset.applyQuaternion( quatInverse );

			position.copy( this.target ).add( offset );

			this.object.lookAt( this.target );

			if ( this.enableDamping == true ) {

				sphericalDelta.theta *= ( 1 - this.dampingFactor );
				sphericalDelta.phi *= ( 1 - this.dampingFactor );

				panOffset.multiplyScalar( 1 - this.dampingFactor );

			} else {

				sphericalDelta.set( 0, 0, 0 );

				panOffset.set( 0, 0, 0 );

			}

			scale = 1;

			// update condition is:
			// min(camera displacement, camera rotation in radians)^2 > EPS
			// using small-angle approximation cos(x/2) = 1 - x^2 / 8

			if ( zoomChanged ||
				lastPosition.distanceToSquared( this.object.position ) > EPS ||
				8 * ( 1 - lastQuaternion.dot( this.object.quaternion ) ) > EPS ) {

				this.dispatchEvent( changeEvent );

				lastPosition.copy( this.object.position );
				lastQuaternion.copy( this.object.quaternion );
				zoomChanged = false;

				return true;

			}

			return false;

		};

    return _update();
	}

	dispose() {

		this.domElement.removeEventListener( 'contextmenu', onContextMenu, false );

		this.domElement.removeEventListener( 'pointerdown', onPointerDown, false );
		this.domElement.removeEventListener( 'wheel', onMouseWheel, false );

		this.domElement.removeEventListener( 'touchstart', onTouchStart, false );
		this.domElement.removeEventListener( 'touchend', onTouchEnd, false );
		this.domElement.removeEventListener( 'touchmove', onTouchMove, false );

		this.domElement.ownerDocument.removeEventListener( 'pointermove', onPointerMove, false );
		this.domElement.ownerDocument.removeEventListener( 'pointerup', onPointerUp, false );

		this.domElement.removeEventListener( 'keydown', onKeyDown, false );

		//this.dispatchEvent( { type: 'dispose' } ); // should this be added here?

	}

	//
	// internals
	//


	

	getAutoRotationAngle() {

		return 2 * Math.PI / 60 / 60 * this.autoRotateSpeed;

	}

	getZoomScale() {

		return Math.pow( 0.95, this.zoomSpeed );

	}

	rotateLeft( angle ) {

		sphericalDelta.theta -= angle;

	}

	rotateUp( angle ) {

		sphericalDelta.phi -= angle;

	}

	panLeft(distance, objectMatrix) {

		var v = new Vector3.init();

		Function _panLeft = ( distance, objectMatrix ) {

			v.setFromMatrixColumn( objectMatrix, 0 ); // get X column of objectMatrix
			v.multiplyScalar( - distance );

			panOffset.add( v );

		};

    return _panLeft(distance, objectMatrix);
	}

	panUp(distance, objectMatrix) {

		var v = new Vector3.init();

		Function _panUp = ( distance, objectMatrix ) {

			if ( this.screenSpacePanning == true ) {

				v.setFromMatrixColumn( objectMatrix, 1 );

			} else {

				v.setFromMatrixColumn( objectMatrix, 0 );
				v.crossVectors( this.object.up, v );

			}

			v.multiplyScalar( distance );

			panOffset.add( v );

		};

    return _panUp(distance, objectMatrix);
	}

	// deltaX and deltaY are in pixels; right and down are positive
	pan(deltaX, deltaY) {

		var offset = new Vector3.init();

		Function _pan = ( deltaX, deltaY ) {

			var element = this.domElement;

			if ( this.object.isPerspectiveCamera ) {

				// perspective
				var position = this.object.position;
				offset.copy( position ).sub( this.target );
				var targetDistance = offset.length();

				// half of the fov is center to top of screen
				targetDistance *= Math.tan( ( this.object.fov / 2 ) * Math.PI / 180.0 );

				// we use only clientHeight here so aspect ratio does not distort speed
				panLeft( 2 * deltaX * targetDistance / clientHeight, this.object.matrix );
				panUp( 2 * deltaY * targetDistance / clientHeight, this.object.matrix );

			} else if ( this.object.isOrthographicCamera ) {

				// orthographic
				panLeft( deltaX * ( this.object.right - this.object.left ) / this.object.zoom / clientWidth, this.object.matrix );
				panUp( deltaY * ( this.object.top - this.object.bottom ) / this.object.zoom / clientHeight, this.object.matrix );

			} else {

				// camera neither orthographic nor perspective
				print( 'WARNING: OrbitControls.js encountered an unknown camera type - pan disabled.' );
				this.enablePan = false;

			}

		};

    return _pan(deltaX, deltaY);
	}

	dollyOut( num dollyScale ) {

		if ( this.object.isPerspectiveCamera ) {

			scale /= dollyScale;

		} else if ( this.object.isOrthographicCamera ) {

			this.object.zoom = Math.max( this.minZoom, Math.min( this.maxZoom, this.object.zoom * dollyScale ) );
			this.object.updateProjectionMatrix();
			zoomChanged = true;

		} else {

			print( 'WARNING: OrbitControls.js encountered an unknown camera type - dolly/zoom disabled.' );
			this.enableZoom = false;

		}

	}

	dollyIn( dollyScale ) {

		if ( this.object.isPerspectiveCamera ) {

			scale *= dollyScale;

		} else if ( this.object.isOrthographicCamera ) {

			this.object.zoom = Math.max( this.minZoom, Math.min( this.maxZoom, this.object.zoom / dollyScale ) );
			this.object.updateProjectionMatrix();
			zoomChanged = true;

		} else {

			print( 'WARNING: OrbitControls.js encountered an unknown camera type - dolly/zoom disabled.' );
			this.enableZoom = false;

		}

	}

	//
	// event callbacks - update the object state
	//

	handleMouseDownRotate( event ) {

		rotateStart.set( event.page.x, event.page.x );

	}

	handleMouseDownDolly( event ) {

		dollyStart.set( event.page.x, event.page.x );

	}

	handleMouseDownPan( event ) {

		panStart.set( event.page.x, event.page.x );

	}

	handleMouseMoveRotate( event ) {

    print("handleMouseMoveRotate ............. ");

		rotateEnd.set( event.page.x, event.page.y );

		rotateDelta.subVectors( rotateEnd, rotateStart ).multiplyScalar( this.rotateSpeed );

		var element = this.domElement;

		rotateLeft( 2 * Math.PI * rotateDelta.x / clientHeight ); // yes, height

		rotateUp( 2 * Math.PI * rotateDelta.y / clientHeight );

		rotateStart.copy( rotateEnd );

		this.update();

	}

	handleMouseMoveDolly( event ) {

		dollyEnd.set( event.page.x, event.page.y );

		dollyDelta.subVectors( dollyEnd, dollyStart );

		if ( dollyDelta.y > 0 ) {

			dollyOut( getZoomScale() );

		} else if ( dollyDelta.y < 0 ) {

			dollyIn( getZoomScale() );

		}

		dollyStart.copy( dollyEnd );

		this.update();

	}

	handleMouseMovePan( event ) {

		panEnd.set( event.page.x, event.page.y );

		panDelta.subVectors( panEnd, panStart ).multiplyScalar( this.panSpeed );

		pan( panDelta.x, panDelta.y );

		panStart.copy( panEnd );

		this.update();

	}

	handleMouseUp( event ) {

		// no-op

	}

	handleMouseWheel( event ) {

		if ( event.deltaY < 0 ) {

			dollyIn( getZoomScale() );

		} else if ( event.deltaY > 0 ) {

			dollyOut( getZoomScale() );

		}

		this.update();

	}

	handleKeyDown( event ) {

		var needsUpdate = false;

		if ( event.keyCode == this.keys["UP"]) {
      pan( 0, this.keyPanSpeed );
      needsUpdate = true;
		} else if( event.keyCode == this.keys["BOTTOM"]) {
      pan( 0, - this.keyPanSpeed );
      needsUpdate = true;
		} else if( event.keyCode == this.keys["LEFT"]) {
      pan( this.keyPanSpeed, 0 );
      needsUpdate = true;
		} else if( event.keyCode == this.keys["RIGHT"]) {
      pan( - this.keyPanSpeed, 0 );
      needsUpdate = true;
		}

		if ( needsUpdate ) {

			// prevent the browser from scrolling on cursor keys
			event.preventDefault();

			this.update();

		}


	}

	handleTouchStartRotate( event ) {

		if ( event.touches.length == 1 ) {

			rotateStart.set( event.touches[ 0 ].pageX, event.touches[ 0 ].pageY );

		} else {

			var x = 0.5 * ( event.touches[ 0 ].pageX + event.touches[ 1 ].pageX );
			var y = 0.5 * ( event.touches[ 0 ].pageY + event.touches[ 1 ].pageY );

			rotateStart.set( x, y );

		}

	}

	handleTouchStartPan( event ) {

		if ( event.touches.length == 1 ) {

			panStart.set( event.touches[ 0 ].pageX, event.touches[ 0 ].pageY );

		} else {

			var x = 0.5 * ( event.touches[ 0 ].pageX + event.touches[ 1 ].pageX );
			var y = 0.5 * ( event.touches[ 0 ].pageY + event.touches[ 1 ].pageY );

			panStart.set( x, y );

		}

	}

	handleTouchStartDolly( event ) {

		var dx = event.touches[ 0 ].pageX - event.touches[ 1 ].pageX;
		var dy = event.touches[ 0 ].pageY - event.touches[ 1 ].pageY;

		var distance = Math.sqrt( dx * dx + dy * dy );

		dollyStart.set( 0, distance );

	}

	handleTouchStartDollyPan( event ) {

		if ( this.enableZoom ) handleTouchStartDolly( event );

		if ( this.enablePan ) handleTouchStartPan( event );

	}

	handleTouchStartDollyRotate( event ) {

		if ( this.enableZoom ) handleTouchStartDolly( event );

		if ( this.enableRotate ) handleTouchStartRotate( event );

	}

	handleTouchMoveRotate( event ) {
    print("handleTouchMoveRotate -------------- ");

		if ( event.touches.length == 1 ) {

			rotateEnd.set( event.touches[ 0 ].pageX, event.touches[ 0 ].pageY );

		} else {

			var x = 0.5 * ( event.touches[ 0 ].pageX + event.touches[ 1 ].pageX );
			var y = 0.5 * ( event.touches[ 0 ].pageY + event.touches[ 1 ].pageY );

			rotateEnd.set( x, y );

		}

		rotateDelta.subVectors( rotateEnd, rotateStart ).multiplyScalar( this.rotateSpeed );

		var element = this.domElement;

		rotateLeft( 2 * Math.PI * rotateDelta.x / clientHeight ); // yes, height

		rotateUp( 2 * Math.PI * rotateDelta.y / clientHeight );

		rotateStart.copy( rotateEnd );

	}

	handleTouchMovePan( event ) {

		if ( event.touches.length == 1 ) {

			panEnd.set( event.touches[ 0 ].pageX, event.touches[ 0 ].pageY );

		} else {

			var x = 0.5 * ( event.touches[ 0 ].pageX + event.touches[ 1 ].pageX );
			var y = 0.5 * ( event.touches[ 0 ].pageY + event.touches[ 1 ].pageY );

			panEnd.set( x, y );

		}

		panDelta.subVectors( panEnd, panStart ).multiplyScalar( this.panSpeed );

		pan( panDelta.x, panDelta.y );

		panStart.copy( panEnd );

	}

	handleTouchMoveDolly( event ) {

		var dx = event.touches[ 0 ].pageX - event.touches[ 1 ].pageX;
		var dy = event.touches[ 0 ].pageY - event.touches[ 1 ].pageY;

		var distance = Math.sqrt( dx * dx + dy * dy );

		dollyEnd.set( 0, distance );

		dollyDelta.set( 0, Math.pow( dollyEnd.y / dollyStart.y, this.zoomSpeed ).toDouble() );

		dollyOut( dollyDelta.y );

		dollyStart.copy( dollyEnd );

	}

	handleTouchMoveDollyPan( event ) {

		if ( this.enableZoom ) handleTouchMoveDolly( event );

		if ( this.enablePan ) handleTouchMovePan( event );

	}

	handleTouchMoveDollyRotate( event ) {

		if ( this.enableZoom ) handleTouchMoveDolly( event );

		if ( this.enableRotate ) handleTouchMoveRotate( event );

	}

	handleTouchEnd( event ) {

		// no-op

	}

	//
	// event handlers - FSM: listen for events and reset state
	//

	onPointerDown( event ) {

    print("OrbitControls.onPointerDown event.pointerType: ${event.pointerType} ");

		if ( this.enabled == false ) return;

		switch ( event.pointerType ) {

			case 'mouse':
			case 'pen':
				onMouseDown( event );
				break;

			// TODO touch

		}

	}

	onPointerMove( event ) {

		if ( this.enabled == false ) return;

		switch ( event.pointerType ) {

			case 'mouse':
			case 'pen':
				onMouseMove( event );
				break;

			// TODO touch

		}

	}

	onPointerUp( event ) {

		switch ( event.pointerType ) {

			case 'mouse':
			case 'pen':
				onMouseUp( event );
				break;

			// TODO touch

		}

	}

	onMouseDown( event ) {

		// Prevent the browser from scrolling.
		// event.preventDefault();

		// Manually set the focus since calling preventDefault above
		// prevents the browser from setting it automatically.

		// this.domElement.focus ? this.domElement.focus() : window.focus();
    // if(this.domElement.focus != null) this.domElement.focus();

    
		var mouseAction;

		switch ( event.button ) {

			case 0:

				mouseAction = this.mouseButtons["LEFT"];
				break;

			case 1:

				mouseAction = this.mouseButtons["MIDDLE"];
				break;

			case 2:

				mouseAction = this.mouseButtons["RIGHT"];
				break;

			default:

				mouseAction = - 1;

		}

		if ( mouseAction == MOUSE["DOLLY"]) {


				if ( this.enableZoom == false ) return;

				handleMouseDownDolly( event );

				state = STATE["DOLLY"];

    } else if ( mouseAction == MOUSE["ROTATE"] ) {




				// if ( event.ctrlKey || event.metaKey || event.shiftKey ) {

				// 	if ( this.enablePan == false ) return;

				// 	handleMouseDownPan( event );

				// 	state = STATE["PAN"];

				// } else {

					if ( this.enableRotate == false ) return;

					handleMouseDownRotate( event );

					state = STATE["ROTATE"];

				// }

		} else if ( mouseAction == MOUSE["PAN"] ) {



				if ( event.ctrlKey || event.metaKey || event.shiftKey ) {

					if ( this.enableRotate == false ) return;

					handleMouseDownRotate( event );

					state = STATE["ROTATE"];

				} else {

					if ( this.enablePan == false ) return;

					handleMouseDownPan( event );

					state = STATE["PAN"];

				}

    } else {

				state = STATE["NONE"];

		}

		if ( state != STATE["NONE"] ) {

			// this.domElement.ownerDocument.addEventListener( 'pointermove', onPointerMove, false );
			// this.domElement.ownerDocument.addEventListener( 'pointerup', onPointerUp, false );

			this.dispatchEvent( startEvent );

		}

	}

	onMouseMove( event ) {

		if ( this.enabled == false ) return;

		// event.preventDefault();

    print("onMouseMove=============state: ${state} enabled: ${enabled} ");

    state = 0;

		if ( state == STATE["ROTATE"] ) {


				if ( this.enableRotate == false ) return;

				handleMouseMoveRotate( event );

    } else if (state == STATE["DOLLY"]) {

				if ( this.enableZoom == false ) return;

				handleMouseMoveDolly( event );

		} else if (state == STATE["PAN"]) {


				if ( this.enablePan == false ) return;

				handleMouseMovePan( event );

		}

	}

	onMouseUp( event ) {

		this.domElement.ownerDocument.removeEventListener( 'pointermove', onPointerMove, false );
		this.domElement.ownerDocument.removeEventListener( 'pointerup', onPointerUp, false );

		if ( this.enabled == false ) return;

		handleMouseUp( event );

		this.dispatchEvent( endEvent );

		state = STATE["NONE"];

	}

	onMouseWheel( event ) {

		if ( this.enabled == false || this.enableZoom == false || ( state != STATE["NONE"] && state != STATE["ROTATE"] ) ) return;

		event.preventDefault();
		event.stopPropagation();

		this.dispatchEvent( startEvent );

		handleMouseWheel( event );

		this.dispatchEvent( endEvent );

	}

	onKeyDown( event ) {

		if ( this.enabled == false || this.enableKeys == false || this.enablePan == false ) return;

		handleKeyDown( event );

	}

	onTouchStart( event ) {

		if ( this.enabled == false ) return;

		event.preventDefault(); // prevent scrolling

		switch ( event.touches.length ) {

			case 1:

				if ( this.touches["ONE"] == TOUCH["ROTATE"] ) {


						if ( this.enableRotate == false ) return;

						handleTouchStartRotate( event );

						state = STATE["TOUCH_ROTATE"];

        } else if ( this.touches["ONE"] == TOUCH["PAN"] ) {


						if ( this.enablePan == false ) return;

						handleTouchStartPan( event );

						state = STATE["TOUCH_PAN"];

        } else {

						state = STATE["NONE"];

				}


        break;
			case 2:

				if ( this.touches["TWO"] == TOUCH["DOLLY_PAN"] ) {

						if ( this.enableZoom == false && this.enablePan == false ) return;

						handleTouchStartDollyPan( event );

						state = STATE["TOUCH_DOLLY_PAN"];

        } else if ( this.touches["TWO"] == TOUCH["DOLLY_ROTATE"] ) {

	

						if ( this.enableZoom == false && this.enableRotate == false ) return;

						handleTouchStartDollyRotate( event );

						state = STATE["TOUCH_DOLLY_ROTATE"];

        } else {

						state = STATE["NONE"];

				}

				break;

			default:

				state = STATE["NONE"];

		}

		if ( state != STATE["NONE"] ) {

			this.dispatchEvent( startEvent );

		}

	}

	onTouchMove( event ) {

		if ( this.enabled == false ) return;

		// event.preventDefault(); // prevent scrolling
		// event.stopPropagation();
    state = 3;

    print("OrbitControls.onTouchMove state: ${state} event: ${event} enableRotate: ${enableRotate} ");



		if ( state == STATE["TOUCH_ROTATE"] ) {

				if ( this.enableRotate == false ) return;

    

				handleTouchMoveRotate( event );

				this.update();
    } else if	(state == STATE["TOUCH_PAN"] ) {

				if ( this.enablePan == false ) return;

				handleTouchMovePan( event );

				this.update();

    } else if	(state == STATE["TOUCH_DOLLY_PAN"] ) {
	

				if ( this.enableZoom == false && this.enablePan == false ) return;

				handleTouchMoveDollyPan( event );

				this.update();
    } else if	(state == STATE["TOUCH_DOLLY_ROTATE"] ) {

				if ( this.enableZoom == false && this.enableRotate == false ) return;

				handleTouchMoveDollyRotate( event );

				this.update();

    } else {
      state = STATE["NONE"];
		}

	}

	onTouchEnd( event ) {

		if ( this.enabled == false ) return;

		handleTouchEnd( event );

		this.dispatchEvent( endEvent );

		state = STATE["NONE"];

	}

	onContextMenu( event ) {

		if ( this.enabled == false ) return;

		event.preventDefault();

	}

	

}

// This set of controls performs orbiting, dollying (zooming), and panning.
// Unlike TrackballControls, it maintains the "up" direction object.up (+Y by default).
// This is very similar to OrbitControls, another set of touch behavior
//
//    Orbit - right mouse, or left mouse + ctrl/meta/shiftKey / touch: two-finger rotate
//    Zoom - middle mouse, or mousewheel / touch: two-finger spread or squish
//    Pan - left mouse, or arrow keys / touch: one-finger move

class MapControls extends OrbitControls {

  MapControls( object, domElement ) : super(object, domElement) {
    this.screenSpacePanning = false; // pan orthogonal to world-space direction camera.up

    this.mouseButtons["LEFT"] = MOUSE["PAN"];
    this.mouseButtons["RIGHT"] = MOUSE["ROTATE"];

    this.touches["ONE"] = TOUCH["PAN"];
    this.touches["TWO"] = TOUCH["DOLLY_ROTATE"];
  }


}


bool isFinite(v) {
  return v == Math.Infinity || v == -Math.Infinity;
}