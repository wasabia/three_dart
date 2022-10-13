// import 'dart:async';

// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';

// import 'package:flutter_gl/flutter_gl.dart';
// import 'package:three_dart/three3d/objects/index.dart';
// import 'package:three_dart/three_dart.dart' as three;
// import 'package:three_dart_jsm/three_dart_jsm.dart' as THREE_JSM;

// class webxr_vr_dragging extends StatefulWidget {
//   String fileName;
//   webxr_vr_dragging({Key? key, required this.fileName}) : super(key: key);

//   @override
//   _MyAppState createState() => _MyAppState();
// }

// class _MyAppState extends State<webxr_vr_dragging> {
//   late FlutterGlPlugin three3dRender;
//   three.WebGLRenderer? renderer;

//   int? fboId;
//   late double width;
//   late double height;

//   Size? screenSize;

//   late three.Scene scene;
//   late three.Camera camera;
//   late three.Mesh mesh;

//   double dpr = 1.0;

//   var AMOUNT = 4;

//   bool verbose = true;
//   bool disposed = false;

//   late three.Object3D object;

//   late three.Texture texture;

//   late three.WebGLRenderTarget renderTarget;

//   dynamic? sourceTexture;

//   final GlobalKey<THREE_JSM.DomLikeListenableState> _globalKey =
//       GlobalKey<THREE_JSM.DomLikeListenableState>();

//   late THREE_JSM.OrbitControls controls;

//   dynamic controller1;
//   dynamic controller2;
//   dynamic controllerGrip1;
//   dynamic controllerGrip2;

//   late three.Raycaster raycaster;

//   var intersected = [];
//   var tempMatrix = new three.Matrix4();

// 	dynamic group;

//   @override
//   void initState() {
//     super.initState();
//   }

//   // Platform messages are asynchronous, so we initialize in an async method.
//   Future<void> initPlatformState() async {
//     width = screenSize!.width;
//     height = screenSize!.height;

//     three3dRender = FlutterGlPlugin();

//     Map<String, dynamic> _options = {
//       "antialias": true,
//       "alpha": false,
//       "width": width.toInt(),
//       "height": height.toInt(),
//       "dpr": dpr
//     };

//     await three3dRender.initialize(options: _options);

//     setState(() {});

//     // TODO web wait dom ok!!!
//     Future.delayed(const Duration(milliseconds: 100), () async {
//       await three3dRender.prepareContext();

//       initScene();
//     });
//   }

//   initSize(BuildContext context) {
//     if (screenSize != null) {
//       return;
//     }

//     final mqd = MediaQuery.of(context);

//     screenSize = mqd.size;
//     dpr = mqd.devicePixelRatio;

//     initPlatformState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(widget.fileName),
//       ),
//       body: Builder(
//         builder: (BuildContext context) {
//           initSize(context);
//           return SingleChildScrollView(child: _build(context));
//         },
//       ),
//       floatingActionButton: FloatingActionButton(
//         child: const Text("render"),
//         onPressed: () {
//           render();
//         },
//       ),
//     );
//   }

//   Widget _build(BuildContext context) {
//     return Column(
//       children: [
//         Container(
//           child: Stack(
//             children: [
//               THREE_JSM.DomLikeListenable(
//                   key: _globalKey,
//                   builder: (BuildContext context) {
//                     return Container(
//                         width: width,
//                         height: height,
//                         color: Colors.black,
//                         child: Builder(builder: (BuildContext context) {
//                           if (kIsWeb) {
//                             return three3dRender.isInitialized
//                                 ? HtmlElementView(
//                                     viewType:
//                                         three3dRender.textureId!.toString())
//                                 : Container();
//                           } else {
//                             return three3dRender.isInitialized
//                                 ? Texture(textureId: three3dRender.textureId!)
//                                 : Container();
//                           }
//                         }));
//                   }),
//             ],
//           ),
//         ),
//       ],
//     );
//   }

//   render() {
//     int _t = DateTime.now().millisecondsSinceEpoch;

//     final _gl = three3dRender.gl;

//     renderer!.render(scene, camera);

//     int _t1 = DateTime.now().millisecondsSinceEpoch;

//     if (verbose) {
//       print("render cost: ${_t1 - _t} ");
//       print(renderer!.info.memory);
//       print(renderer!.info.render);
//     }

//     // 重要 更新纹理之前一定要调用 确保gl程序执行完毕
//     _gl.flush();

//     if (verbose) print(" render: sourceTexture: $sourceTexture ");

//     if (!kIsWeb) {
//       three3dRender.updateTexture(sourceTexture);
//     }
//   }

//   initRenderer() {
//     Map<String, dynamic> _options = {
//       "width": width,
//       "height": height,
//       "gl": three3dRender.gl,
//       "antialias": true,
//       "canvas": three3dRender.element
//     };
//     renderer = three.WebGLRenderer(_options);
//     renderer!.setPixelRatio(dpr);
//     renderer!.setSize(width, height, false);
//     renderer!.shadowMap.enabled = true;
//     renderer!.xr.enabled = true;

//     if (!kIsWeb) {
//       var pars = three.WebGLRenderTargetOptions({"format": three.RGBAFormat});
//       renderTarget =
//           three.WebGLRenderTarget((width * dpr).toInt(), (height * dpr).toInt(), pars);
//       renderTarget.samples = 4;
//       renderer!.setRenderTarget(renderTarget);
//       sourceTexture = renderer!.getRenderTargetGLTexture(renderTarget);
//     }
//   }

//   initScene() {
//     initRenderer();
//     initPage();
//   }

//   initPage() async {
//     scene = new three.Scene();
//     scene.background = new three.Color( 0x808080 );

//     camera = new three.PerspectiveCamera( 50, width / height, 0.1, 10 );
//     camera.position.set( 0, 1.6, 3 );

//     controls = new THREE_JSM.OrbitControls( camera, _globalKey );
//     controls.target.set( 0, 1.6, 0 );
//     controls.update();

//     var floorGeometry = new three.PlaneGeometry( 4, 4 );
//     var floorMaterial = new three.MeshStandardMaterial( {
//       "color": 0xeeeeee,
//       "roughness": 1.0,
//       "metalness": 0.0
//     } );
//     var floor = new three.Mesh( floorGeometry, floorMaterial );
//     floor.rotation.x = - three.Math.PI / 2;
//     floor.receiveShadow = true;
//     scene.add( floor );

//     scene.add( new three.HemisphereLight( 0x808080, 0x606060 ) );

//     var light = new three.DirectionalLight( 0xffffff );
//     light.position.set( 0, 6, 0 );
//     light.castShadow = true;
//     light.shadow!.camera!.top = 2;
//     light.shadow!.camera!.bottom = - 2;
//     light.shadow!.camera!.right = 2;
//     light.shadow!.camera!.left = - 2;
//     light.shadow!.mapSize.set( 4096, 4096 );
//     scene.add( light );

//     group = new three.Group();
//     scene.add( group );

//     var geometries = [
//       new three.BoxGeometry( 0.2, 0.2, 0.2 ),
//       new three.ConeGeometry( 0.2, 0.2, 64 ),
//       new three.CylinderGeometry( 0.2, 0.2, 0.2, 64 ),
//       new three.IcosahedronGeometry( 0.2, 8 ),
//       new three.TorusGeometry( 0.2, 0.04, 64, 32 )
//     ];

//     for ( var i = 0; i < 50; i ++ ) {

//       var geometry = geometries[ three.Math.floor( three.Math.random() * geometries.length ) ];
//       var material = new three.MeshStandardMaterial( {
//         "color": three.Math.random() * 0xffffff,
//         "roughness": 0.7,
//         "metalness": 0.0
//       } );

//       var object = new three.Mesh( geometry, material );

//       object.position.x = three.Math.random() * 4 - 2;
//       object.position.y = three.Math.random() * 2;
//       object.position.z = three.Math.random() * 4 - 2;

//       object.rotation.x = three.Math.random() * 2 * three.Math.PI;
//       object.rotation.y = three.Math.random() * 2 * three.Math.PI;
//       object.rotation.z = three.Math.random() * 2 * three.Math.PI;

//       object.scale.setScalar( three.Math.random() + 0.5 );

//       object.castShadow = true;
//       object.receiveShadow = true;

//       group.add( object );

//     }


//     // controllers

//     controller1 = renderer!.xr.getController( 0 );
//     controller1.addEventListener( 'selectstart', onSelectStart );
//     controller1.addEventListener( 'selectend', onSelectEnd );
//     scene.add( controller1 );

//     controller2 = renderer!.xr.getController( 1 );
//     controller2.addEventListener( 'selectstart', onSelectStart );
//     controller2.addEventListener( 'selectend', onSelectEnd );
//     scene.add( controller2 );

//     var controllerModelFactory = new XRControllerModelFactory();

//     controllerGrip1 = renderer!.xr.getControllerGrip( 0 );
//     controllerGrip1.add( controllerModelFactory.createControllerModel( controllerGrip1 ) );
//     scene.add( controllerGrip1 );

//     controllerGrip2 = renderer!.xr.getControllerGrip( 1 );
//     controllerGrip2.add( controllerModelFactory.createControllerModel( controllerGrip2 ) );
//     scene.add( controllerGrip2 );

//     //

//     var geometry = new three.BufferGeometry().setFromPoints( [ new three.Vector3( 0, 0, 0 ), new three.Vector3( 0, 0, - 1 ) ] );

//     var line = new three.Line( geometry, null );
//     line.name = 'line';
//     line.scale.z = 5;

//     controller1.add( line.clone() );
//     controller2.add( line.clone() );

//     raycaster = new three.Raycaster();


//     animate();
//   }

//   animate() {
//     if (!mounted || disposed) {
//       return;
//     }

//     render();

//     // Future.delayed(Duration(milliseconds: 40), () {
//     //   animate();
//     // });
//   }


//   onSelectStart( event ) {

//     var controller = event.target;

//     var intersections = getIntersections( controller );

//     if ( intersections.length > 0 ) {

//       var intersection = intersections[ 0 ];

//       var object = intersection.object;
//       object.material.emissive.b = 1;
//       controller.attach( object );

//       controller.userData.selected = object;

//     }

//   }

//   onSelectEnd( event ) {

//     var controller = event.target;

//     if ( controller.userData.selected != null ) {

//       var object = controller.userData.selected;
//       object.material.emissive.b = 0;
//       group.attach( object );

//       controller.userData.selected = null;

//     }


//   }

//   getIntersections( controller ) {

//     tempMatrix.identity().extractRotation( controller.matrixWorld );

//     raycaster.ray.origin.setFromMatrixPosition( controller.matrixWorld );
//     raycaster.ray.direction.set( 0, 0, - 1 ).applyMatrix4( tempMatrix );

//     return raycaster.intersectObjects( group.children, false );

//   }

//   intersectObjects( controller ) {

//     // Do not highlight when already selected

//     if ( controller.userData.selected != null ) return;

//     var line = controller.getObjectByName( 'line' );
//     var intersections = getIntersections( controller );

//     if ( intersections.length > 0 ) {

//       var intersection = intersections[ 0 ];

//       var object = intersection.object;
//       object.material.emissive.r = 1;
//       intersected.add( object );

//       line.scale.z = intersection.distance;

//     } else {

//       line.scale.z = 5;

//     }

//   }

//   cleanIntersected() {

//     while ( intersected.length > 0 ) {

//       var object = intersected.removeLast();
//       object.material.emissive.r = 0;

//     }

//   }

//   @override
//   void dispose() {
//     print(" dispose ............. ");
//     disposed = true;
//     three3dRender.dispose();

//     super.dispose();
//   }
// }
