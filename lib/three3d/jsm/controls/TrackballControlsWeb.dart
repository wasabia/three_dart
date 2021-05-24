

import 'package:three_dart/three3d/cameras/index.dart';
import 'package:three_dart/three3d/constants.dart';
import 'package:three_dart/three3d/core/index.dart';
import 'package:three_dart/three3d/jsm/controls/index.dart';
import 'package:three_dart/three3d/math/index.dart';
import 'package:universal_html/html.dart';

var STATE = _TCPSTATE();

class TrackballControlsPlatform with TrackballControls, EventDispatcher {

  bool enabled = true;

  late Camera object;
  late var domElement;

  
  var screen = _TCPSCREEN();

  double rotateSpeed = 1.0;
  double zoomSpeed = 1.2;
  double panSpeed = 0.3;
  bool noRotate = false;
  bool noZoom = false;
  bool noPan = false;
  bool staticMoving = false;
  double dynamicDampingFactor = 0.2;
  double minDistance = 0;
  double maxDistance = double.infinity;
  List<int> keys = [ 65 /*A*/, 83 /*S*/, 68 /*D*/ ];

  Vector3 target = new Vector3.init();
  double EPS = 0.000001;
  Vector3 lastPosition = new Vector3.init();
  double lastZoom = 1;

  late Vector3 target0;
  late Vector3 position0;
  late Vector3 up0;
  late double zoom0;


  var _state = STATE.NONE,
      _keyState = STATE.NONE,

      _eye = new Vector3.init(),

      _movePrev = new Vector2(null,null),
      _moveCurr = new Vector2(null,null),

      _lastAxis = new Vector3.init();
      num _lastAngle = 0;

      var _zoomStart = new Vector2(null,null),
      _zoomEnd = new Vector2(null,null);

      num _touchZoomDistanceStart = 0;
      num _touchZoomDistanceEnd = 0;

      var _panStart = new Vector2(null,null),
      _panEnd = new Vector2(null,null);



  var mouseButtons = { "LEFT": MOUSE["ROTATE"], "MIDDLE": MOUSE["ZOOM"], "RIGHT": MOUSE["PAN"] };

  // events
  var changeEvent = Event({ "type": 'change' });
  var startEvent = Event({ "type": 'start' });
  var endEvent = Event({ "type": 'end' });


  TrackballControlsPlatform( Object3D object, domElement ) {
    this.object = object as Camera;
    this.domElement = domElement;



    // internals

    

    // for reset

    this.target0 = this.target.clone();
    this.position0 = this.object.position.clone();
    this.up0 = this.object.up.clone();
    this.zoom0 = this.object.zoom;




    this.domElement.addEventListener( 'contextmenu', contextmenu, false );

    this.domElement.addEventListener( 'pointerdown', onPointerDown, false );
    this.domElement.addEventListener( 'wheel', mousewheel, false );

    this.domElement.addEventListener( 'touchstart', touchstart, false );
    this.domElement.addEventListener( 'touchend', touchend, false );
    this.domElement.addEventListener( 'touchmove', touchmove, false );

    this.domElement.ownerDocument.addEventListener( 'pointermove', onPointerMove, false );
    this.domElement.ownerDocument.addEventListener( 'pointerup', onPointerUp, false );

    window.addEventListener( 'keydown', keydown, false );
    window.addEventListener( 'keyup', keyup, false );

    this.handleResize();

    // force an update at start
    this.update();
  }




	// methods

	handleResize () {

		var box = this.domElement.getBoundingClientRect();
		// adjustments come from similar code in the jquery offset() function
		var d = this.domElement.ownerDocument.documentElement;
		this.screen.left = box.left + window.pageXOffset - d.clientLeft;
		this.screen.top = box.top + window.pageYOffset - d.clientTop;
		this.screen.width = box.width;
		this.screen.height = box.height;

	}


  var _vectorGetMouseOnScreen = Vector2(null, null);
	getMouseOnScreen( pageX, pageY ) {
    _vectorGetMouseOnScreen.set(
      ( pageX - this.screen.left ) / this.screen.width,
      ( pageY - this.screen.top ) / this.screen.height
    );

    return _vectorGetMouseOnScreen;
  }

  var _vectorGetMouseOnCircle = new Vector2(null, null);
	getMouseOnCircle(pageX, pageY) {

    _vectorGetMouseOnCircle.set(
        ( ( pageX - this.screen.width * 0.5 - this.screen.left ) / ( this.screen.width * 0.5 ) ),
        ( ( this.screen.height + 2 * ( this.screen.top - pageY ) ) / this.screen.width ) // screen.width intentional
      );

    return _vectorGetMouseOnCircle;
  }



  var axis = new Vector3.init(),
  quaternion = new Quaternion(),
  eyeDirection = new Vector3.init(),
  objectUpDirection = new Vector3.init(),
  objectSidewaysDirection = new Vector3.init(),
  moveDirection = new Vector3.init(),
  angle;
  rotateCamera() {

 
    moveDirection.set( _moveCurr.x - _movePrev.x, _moveCurr.y - _movePrev.y, 0 );
    angle = moveDirection.length();


    // print("rotateCamera angle: ${angle}  ");
  
    if ( angle != 0 ) {

      _eye.copy( this.object.position ).sub( this.target );

      eyeDirection.copy( _eye ).normalize();
      objectUpDirection.copy( this.object.up ).normalize();
      objectSidewaysDirection.crossVectors( objectUpDirection, eyeDirection ).normalize();

      objectUpDirection.setLength( _moveCurr.y - _movePrev.y );
      objectSidewaysDirection.setLength( _moveCurr.x - _movePrev.x );

      moveDirection.copy( objectUpDirection.add( objectSidewaysDirection ) );

      axis.crossVectors( moveDirection, _eye ).normalize();

      angle *= this.rotateSpeed;
      quaternion.setFromAxisAngle( axis, angle );

      _eye.applyQuaternion( quaternion );
      this.object.up.applyQuaternion( quaternion );

      _lastAxis.copy( axis );
      _lastAngle = angle;

    } else if ( ! this.staticMoving && _lastAngle != 0 ) {

      _lastAngle *= Math.sqrt( 1.0 - this.dynamicDampingFactor );
      _eye.copy( this.object.position ).sub( this.target );
      quaternion.setFromAxisAngle( _lastAxis, _lastAngle );
      _eye.applyQuaternion( quaternion );
      this.object.up.applyQuaternion( quaternion );

    }

    _movePrev.copy( _moveCurr );

  }


	zoomCamera() {

		var factor;

		if ( _state == STATE.TOUCH_ZOOM_PAN ) {

			factor = _touchZoomDistanceStart / _touchZoomDistanceEnd;
			_touchZoomDistanceStart = _touchZoomDistanceEnd;

			if ( this.object.isPerspectiveCamera ) {

				_eye.multiplyScalar( factor );

			} else if ( this.object.isOrthographicCamera ) {

				this.object.zoom *= factor;
				this.object.updateProjectionMatrix();

			} else {

				print( 'THREE.TrackballControls: Unsupported camera type' );

			}

		} else {

			factor = 1.0 + ( _zoomEnd.y - _zoomStart.y ) * this.zoomSpeed;

			if ( factor != 1.0 && factor > 0.0 ) {

				if ( this.object.isPerspectiveCamera ) {

					_eye.multiplyScalar( factor );

				} else if ( this.object.isOrthographicCamera ) {

					this.object.zoom /= factor;
					this.object.updateProjectionMatrix();

				} else {

					print( 'THREE.TrackballControls: Unsupported camera type' );

				}

			}

			if ( this.staticMoving ) {

				_zoomStart.copy( _zoomEnd );

			} else {

				_zoomStart.y += ( _zoomEnd.y - _zoomStart.y ) * this.dynamicDampingFactor;

			}

		}

	}



  var mouseChange = new Vector2(null, null),
    objectUp = new Vector3.init(),
    pan = new Vector3.init();

	panCamera() {

    mouseChange.copy( _panEnd ).sub( _panStart );

    if ( mouseChange.lengthSq() != 0 ) {

      if ( this.object.isOrthographicCamera ) {

        var scale_x = ( this.object.right - this.object.left ) / this.object.zoom / this.domElement.clientWidth;
        var scale_y = ( this.object.top - this.object.bottom ) / this.object.zoom / this.domElement.clientWidth;

        mouseChange.x *= scale_x;
        mouseChange.y *= scale_y;

      }

      mouseChange.multiplyScalar( _eye.length() * this.panSpeed );

      pan.copy( _eye ).cross( this.object.up ).setLength( mouseChange.x );
      pan.add( objectUp.copy( this.object.up ).setLength( mouseChange.y ) );

      this.object.position.add( pan );
      this.target.add( pan );

      if ( this.staticMoving ) {

        _panStart.copy( _panEnd );

      } else {

        _panStart.add( mouseChange.subVectors( _panEnd, _panStart ).multiplyScalar( this.dynamicDampingFactor ) );

      }

    }

  }


	checkDistances() {

		if ( ! this.noZoom || ! this.noPan ) {

			if ( _eye.lengthSq() > this.maxDistance * this.maxDistance ) {

				this.object.position.addVectors( this.target, _eye.setLength( this.maxDistance ) );
				_zoomStart.copy( _zoomEnd );

			}

			if ( _eye.lengthSq() < this.minDistance * this.minDistance ) {

				this.object.position.addVectors( this.target, _eye.setLength( this.minDistance ) );
				_zoomStart.copy( _zoomEnd );

			}

		}

	}

	update() {

		_eye.subVectors( this.object.position, this.target );

    // print(" update: noRotate: ${this.noRotate} ");

		if ( ! this.noRotate ) {

			this.rotateCamera();

		}

		if ( ! this.noZoom ) {

			this.zoomCamera();

		}

		if ( ! this.noPan ) {

			this.panCamera();

		}

		this.object.position.addVectors( this.target, _eye );

		if ( this.object.isPerspectiveCamera ) {

			this.checkDistances();

			this.object.lookAt( this.target );

			if ( lastPosition.distanceToSquared( this.object.position ) > EPS ) {

				this.dispatchEvent( changeEvent );

				lastPosition.copy( this.object.position );

			}

		} else if ( this.object.isOrthographicCamera ) {

			this.object.lookAt( this.target );

			if ( lastPosition.distanceToSquared( this.object.position ) > EPS || lastZoom != this.object.zoom ) {

				this.dispatchEvent( changeEvent );

				lastPosition.copy( this.object.position );
				lastZoom = this.object.zoom;

			}

		} else {

			print( 'THREE.TrackballControls: Unsupported camera type' );

		}

	}

	reset() {

		_state = STATE.NONE;
		_keyState = STATE.NONE;

		this.target.copy( this.target0 );
		this.object.position.copy( this.position0 );
		this.object.up.copy( this.up0 );
		this.object.zoom = this.zoom0;

		this.object.updateProjectionMatrix();

		_eye.subVectors( this.object.position, this.target );

		this.object.lookAt( this.target );

		this.dispatchEvent( changeEvent );

		lastPosition.copy( this.object.position );
		lastZoom = this.object.zoom;

	}

	// listeners

	onPointerDown( event ) {

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

		if ( this.enabled == false ) return;

		switch ( event.pointerType ) {

			case 'mouse':
			case 'pen':
				onMouseUp( event );
				break;

			// TODO touch

		}

	}

	keydown( event ) {

		if ( this.enabled == false ) return;

		window.removeEventListener( 'keydown', keydown );

		if ( _keyState != STATE.NONE ) {

			return;

		} else if ( event.keyCode == this.keys[ STATE.ROTATE ] && ! this.noRotate ) {

			_keyState = STATE.ROTATE;

		} else if ( event.keyCode == this.keys[ STATE.ZOOM ] && ! this.noZoom ) {

			_keyState = STATE.ZOOM;

		} else if ( event.keyCode == this.keys[ STATE.PAN ] && ! this.noPan ) {

			_keyState = STATE.PAN;

		}

	}

	keyup(event) {

		if ( this.enabled == false ) return;

		_keyState = STATE.NONE;

		window.addEventListener( 'keydown', keydown, false );

   

	}

	onMouseDown( event ) {

		event.preventDefault();
		event.stopPropagation();

		if ( _state == STATE.NONE ) {

			if( event.button == this.mouseButtons["LEFT"] ) {
        _state = STATE.ROTATE;
      } else if( event.button == this.mouseButtons["MIDDLE"] ) {
				_state = STATE.ZOOM;
      } else if( event.button == this.mouseButtons["RIGHT"] ) {
        _state = STATE.PAN;
      } else {  
        _state = STATE.NONE;
			}

		}

		var state = ( _keyState != STATE.NONE ) ? _keyState : _state;


    var _pageX = event.page.x;
    var _pageY = event.page.y;


		if ( state == STATE.ROTATE && ! this.noRotate ) {

			_moveCurr.copy( getMouseOnCircle( _pageX, _pageY ) );
			_movePrev.copy( _moveCurr );

		} else if ( state == STATE.ZOOM && ! this.noZoom ) {

			_zoomStart.copy( getMouseOnScreen( _pageX, _pageY ) );
			_zoomEnd.copy( _zoomStart );

		} else if ( state == STATE.PAN && ! this.noPan ) {

			_panStart.copy( getMouseOnScreen( _pageX, _pageY ) );
			_panEnd.copy( _panStart );

		}

		// this.domElement.ownerDocument.addEventListener( 'pointermove', onPointerMove, false );
		// this.domElement.ownerDocument.addEventListener( 'pointerup', onPointerUp, false );

		this.dispatchEvent( startEvent );

	}

	onMouseMove( event ) {

		if ( this.enabled == false ) return;

		event.preventDefault();
		event.stopPropagation();

		var state = ( _keyState != STATE.NONE ) ? _keyState : _state;

    // var _pageX = event.page.x;
    // var _pageY = event.page.y;
    
    var _pageX = event.offset.x;
    var _pageY = event.offset.y;

		if ( state == STATE.ROTATE && ! this.noRotate ) {

			_movePrev.copy( _moveCurr );
			_moveCurr.copy( getMouseOnCircle( _pageX, _pageY ) );

     
		} else if ( state == STATE.ZOOM && ! this.noZoom ) {

			_zoomEnd.copy( getMouseOnScreen( _pageX, _pageY ) );

		} else if ( state == STATE.PAN && ! this.noPan ) {

			_panEnd.copy( getMouseOnScreen( _pageX, _pageY ) );

		}

	}

	onMouseUp( event ) {

		if ( this.enabled == false ) return;

		event.preventDefault();
		event.stopPropagation();

		_state = STATE.NONE;
     
		this.domElement.ownerDocument.removeEventListener( 'pointermove', onPointerMove );
		this.domElement.ownerDocument.removeEventListener( 'pointerup', onPointerUp );

		this.dispatchEvent( endEvent );

	}

	mousewheel( event ) {

		if ( this.enabled == false ) return;

		if ( this.noZoom == true ) return;

		event.preventDefault();
		event.stopPropagation();

		switch ( event.deltaMode ) {

			case 2:
				// Zoom in pages
				_zoomStart.y -= event.deltaY * 0.025;
				break;

			case 1:
				// Zoom in lines
				_zoomStart.y -= event.deltaY * 0.01;
				break;

			default:
				// undefined, 0, assume pixels
				_zoomStart.y -= event.deltaY * 0.00025;
				break;

		}

		this.dispatchEvent( startEvent );
		this.dispatchEvent( endEvent );

	}

	touchstart( event ) {

		if ( this.enabled == false ) return;

		event.preventDefault();

		switch ( event.touches.length ) {

			case 1:
				_state = STATE.TOUCH_ROTATE;
				_moveCurr.copy( getMouseOnCircle( event.touches[ 0 ].pageX, event.touches[ 0 ].pageY ) );
				_movePrev.copy( _moveCurr );
				break;

			default: // 2 or more
				_state = STATE.TOUCH_ZOOM_PAN;
				var dx = event.touches[ 0 ].pageX - event.touches[ 1 ].pageX;
				var dy = event.touches[ 0 ].pageY - event.touches[ 1 ].pageY;
				_touchZoomDistanceEnd = _touchZoomDistanceStart = Math.sqrt( dx * dx + dy * dy );

				var x = ( event.touches[ 0 ].pageX + event.touches[ 1 ].pageX ) / 2;
				var y = ( event.touches[ 0 ].pageY + event.touches[ 1 ].pageY ) / 2;
				_panStart.copy( getMouseOnScreen( x, y ) );
				_panEnd.copy( _panStart );
				break;

		}

		this.dispatchEvent( startEvent );

	}

	touchmove( event ) {

		if ( this.enabled == false ) return;

		event.preventDefault();
		event.stopPropagation();

		switch ( event.touches.length ) {

			case 1:
				_movePrev.copy( _moveCurr );
				_moveCurr.copy( getMouseOnCircle( event.touches[ 0 ].pageX, event.touches[ 0 ].pageY ) );
				break;

			default: // 2 or more
				var dx = event.touches[ 0 ].pageX - event.touches[ 1 ].pageX;
				var dy = event.touches[ 0 ].pageY - event.touches[ 1 ].pageY;
				_touchZoomDistanceEnd = Math.sqrt( dx * dx + dy * dy );

				var x = ( event.touches[ 0 ].pageX + event.touches[ 1 ].pageX ) / 2;
				var y = ( event.touches[ 0 ].pageY + event.touches[ 1 ].pageY ) / 2;
				_panEnd.copy( getMouseOnScreen( x, y ) );
				break;

		}

	}

	touchend( event ) {

		if ( this.enabled == false ) return;

		switch ( event.touches.length ) {

			case 0:
				_state = STATE.NONE;
				break;

			case 1:
				_state = STATE.TOUCH_ROTATE;
				_moveCurr.copy( getMouseOnCircle( event.touches[ 0 ].pageX, event.touches[ 0 ].pageY ) );
				_movePrev.copy( _moveCurr );
				break;

		}

		this.dispatchEvent( endEvent );

	}

	contextmenu( event ) {

		if ( this.enabled == false ) return;

		event.preventDefault();

	}

	dispose() {

		this.domElement.removeEventListener( 'contextmenu', contextmenu, false );

		this.domElement.removeEventListener( 'pointerdown', onPointerDown, false );
		this.domElement.removeEventListener( 'wheel', mousewheel, false );

		this.domElement.removeEventListener( 'touchstart', touchstart, false );
		this.domElement.removeEventListener( 'touchend', touchend, false );
		this.domElement.removeEventListener( 'touchmove', touchmove, false );

		this.domElement.ownerDocument.removeEventListener( 'pointermove', onPointerMove, false );
		this.domElement.ownerDocument.removeEventListener( 'pointerup', onPointerUp, false );

		window.removeEventListener( 'keydown', keydown, false );
		window.removeEventListener( 'keyup', keyup, false );

	}


}


class _TCPSTATE {
  const _TCPSTATE();

  final int NONE = - 1;
  final int ROTATE = 0;
  final int ZOOM = 1;
  final int PAN = 2;
  final int TOUCH_ROTATE = 3;
  final int TOUCH_ZOOM_PAN = 4;
}

class _TCPSCREEN {
  int left = 0;
  int top = 0;
  int width = 0;
  int height = 0;

  _TCPSCREEN({int left = 0, int top = 0, int width = 0, int height = 0}) {
    this.left = left;
    this.top = top;
    this.width = width;
    this.height = height;
  }
}