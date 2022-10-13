// import 'dart:async';

// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';

// import 'package:flutter/widgets.dart';

// import 'package:three_dart/three_dart.dart' as three;
// import 'package:three_dart_jsm/three_dart_jsm.dart' as THREE_JSM;

// class webgpu_rtt extends StatefulWidget {
//   String fileName;
//   webgpu_rtt({Key? key, required this.fileName}) : super(key: key);

//   _MyAppState createState() => _MyAppState();
// }

// class _MyAppState extends State<webgpu_rtt> {
//   three.WebGPURenderer? renderer;

//   int? fboId;
//   late double width;
//   late double height;

//   Size? screenSize;

//   late three.Scene scene;
//   late three.Camera camera;
//   late three.Mesh mesh;

//   num dpr = 1.0;


//   bool verbose = true;
//   bool disposed = false;

//   bool loaded = false;

//   late three.Object3D box;

//   late three.Texture texture;

//   late three.WebGLMultisampleRenderTarget renderTarget;

//   @override
//   void initState() {
//     super.initState();
//   }

//   // Platform messages are asynchronous, so we initialize in an async method.
//   Future<void> initPlatformState() async {
//     width = screenSize!.width;
//     height = screenSize!.height;

//     init();
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
//           clickRender();
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
//               Container(
//                   width: width,
//                   height: height,
//                   color: Colors.black,
//               )
//             ],
//           ),
//         ),
//       ],
//     );
//   }

//   init() {
//     camera = new three.PerspectiveCamera( 70, width / height, 0.1, 10 );
//     camera.position.z = 4;

//     scene = new three.Scene();
//     scene.background = new three.Color( 0x222222 );

//     // textured mesh

//     var geometryBox = new three.BoxGeometry();
//     var materialBox = new three.MeshBasicNodeMaterial(null);
//     materialBox.colorNode = new three.ColorNode( new three.Color(1.0, 1.0, 0.5) );

//     box = new three.Mesh( geometryBox, materialBox );
//     scene.add( box );

//     renderer = new three.WebGPURenderer({
//       "width": 300,
//       "height": 300,
//       "antialias": true
//     });
//     renderer!.setPixelRatio( dpr );
//     renderer!.setSize( width.toInt(), height.toInt() );
//     renderer!.init();

//     var pars = three.WebGLRenderTargetOptions({"format": three.RGBAFormat});
//     renderTarget = three.WebGLMultisampleRenderTarget(
//         (width * dpr), (height * dpr), pars);
//     renderTarget.samples = 4;
//     renderer!.setRenderTarget(renderTarget);
//     // sourceTexture = renderer!.getRenderTargetGLTexture(renderTarget);
//   }

//   animate() {
//     box.rotation.x += 0.01;
//     box.rotation.y += 0.02;

//     renderer!.render( scene, camera );

//     Future.delayed(const Duration(milliseconds: 33), () {
//       animate();
//     });
//   }

//   clickRender() {
//     box.rotation.x += 0.01;
//     box.rotation.y += 0.02;

//     renderer!.render( scene, camera );
//   }

//   @override
//   void dispose() {
//     print(" dispose ............. ");
//     disposed = true;

//     super.dispose();
//   }
// }
