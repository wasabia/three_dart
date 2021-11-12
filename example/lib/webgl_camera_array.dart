import 'dart:async';

import 'dart:typed_data';

import 'dart:ui' as ui;


import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:flutter/widgets.dart';
import 'package:flutter_gl/flutter_gl.dart';


import 'package:three_dart/three_dart.dart' as THREE;




class webgl_camera_array extends StatefulWidget {
  String fileName;
  webgl_camera_array({Key? key, required this.fileName}) : super(key: key);

  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<webgl_camera_array> {


  late FlutterGlPlugin three3dRender;
  THREE.WebGLRenderer? renderer;

  int? fboId;
  late double width;
  late double height;

  Size? screenSize;

  late THREE.Scene scene;
  late THREE.Camera camera;
  late THREE.Mesh mesh;
  
  num dpr = 1.0;

  var AMOUNT = 4;

  bool verbose = true;



  late THREE.WebGLRenderTarget renderTarget;

  dynamic? sourceTexture;

  @override
  void initState() {
    super.initState();
    
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    width = screenSize!.width;
    height = screenSize!.height;

    three3dRender = FlutterGlPlugin(width.toInt(), height.toInt(), dpr: dpr);

    Map<String, dynamic> _options = {
      "antialias": true,
      "alpha": false
    };
    
    await three3dRender.initialize(options: _options);

    setState(() { });

    // TODO web wait dom ok!!!
    Future.delayed(Duration(milliseconds: 100), () async {
      await three3dRender.prepareContext();

      initScene();
      animate();
      
    });
  
  }

  

  initSize(BuildContext context) {
    if (screenSize != null) {
      return;
    }

    final mqd = MediaQuery.of(context);

    screenSize = mqd.size;
    dpr = mqd.devicePixelRatio;

    initPlatformState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text(widget.fileName),
        ),
        body: Builder(
          builder: (BuildContext context) {
            initSize(context);  
            return SingleChildScrollView(
              child: _build(context)
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          child: Text("render"),
          onPressed: () {
            render();
          },
        ),
      ),
    );
  }

  
  
  Widget _build(BuildContext context) {
    return Column(
      children: [
        Container(
          child: Stack(
            children: [
              Container(
                width: width,
                height: height,
                color: Colors.black,
                child: Builder(
                  builder: (BuildContext context) {
                    if(kIsWeb) {
                      return three3dRender.isInitialized ? HtmlElementView(viewType: three3dRender.textureId!.toString()) : Container();
                    } else {
                      return three3dRender.isInitialized ? Texture(textureId: three3dRender.textureId!) : Container();
                    }
                  }
                )
              ),
              
            ],
          ),
        ),

      ],
    );
  }

  render() {

    int _t = DateTime.now().millisecondsSinceEpoch;

    final _gl = three3dRender.gl;

     

    renderer!.render(scene, camera);

   
    int _t1 = DateTime.now().millisecondsSinceEpoch;

    if(verbose) {
      print("render cost: ${_t1 - _t} ");
      print(renderer!.info.memory);
      print(renderer!.info.render);
    }
    
   
    // 重要 更新纹理之前一定要调用 确保gl程序执行完毕
    _gl.finish();

    if(verbose) print(" render: sourceTexture: ${sourceTexture} ");

    if(!kIsWeb) {
      three3dRender.updateTexture(sourceTexture);
    }
    
  }

  initRenderer() {
    Map<String, dynamic> _options = {
      "width": width, 
      "height": height,
      "gl":  three3dRender.gl,
      "antialias": true,
      "canvas": three3dRender.element
    };
    renderer = THREE.WebGLRenderer(_options);
    renderer!.setPixelRatio(dpr);
    renderer!.setSize( width, height, false );
    renderer!.shadowMap.enabled = false;
    
    if(!kIsWeb) {
      var pars = THREE.WebGLRenderTargetOptions({ "minFilter": THREE.LinearFilter, "magFilter": THREE.LinearFilter, "format": THREE.RGBAFormat });
      renderTarget = THREE.WebGLMultisampleRenderTarget((width * dpr).toInt(), (height * dpr).toInt(), pars);
      renderer!.setRenderTarget(renderTarget);
      sourceTexture = renderer!.getRenderTargetGLTexture(renderTarget);
    }
  }


  
  initScene() {
    initRenderer();
    initPage();
  }

  initPage() {

    var ASPECT_RATIO = width / height;

    var WIDTH = ( width / AMOUNT ) * dpr;
    var HEIGHT = ( height / AMOUNT ) * dpr;

    List<THREE.Camera> cameras = [];

    for ( var y = 0; y < AMOUNT; y ++ ) {

      for ( var x = 0; x < AMOUNT; x ++ ) {

        var subcamera = new THREE.PerspectiveCamera( 40, ASPECT_RATIO, 0.1, 10 );
        subcamera.viewport = new THREE.Vector4( THREE.Math.floor( x * WIDTH ), THREE.Math.floor( y * HEIGHT ), THREE.Math.ceil( WIDTH ), THREE.Math.ceil( HEIGHT ) );
        subcamera.position.x = ( x / AMOUNT ) - 0.5;
        subcamera.position.y = 0.5 - ( y / AMOUNT );
        subcamera.position.z = 1.5;
        subcamera.position.multiplyScalar( 2 );
        subcamera.lookAt( THREE.Vector3(0,0,0) );
        subcamera.updateMatrixWorld(false);
        cameras.add( subcamera );

      }

    }

    camera = new THREE.ArrayCamera( cameras );
    // camera = new THREE.PerspectiveCamera( 40, 1, 0.1, 10 );
    camera.position.z = 3;

    scene = new THREE.Scene();

    camera.lookAt(scene.position);

    scene.background = THREE.Color(1.0, 1.0, 1.0);

    scene.add( new THREE.AmbientLight( 0x222244, null ) );

    var light = new THREE.DirectionalLight(0xffffff, null);
    light.position.set( 0.5, 0.5, 1 );
    light.castShadow = true;
    light.shadow!.camera!.zoom = 4; // tighter shadow map
    scene.add( light );

    var geometryBackground = new THREE.PlaneGeometry( 100, 100 );
    var materialBackground = new THREE.MeshPhongMaterial( { "color": 0x000066 } );

    var background = new THREE.Mesh( geometryBackground, materialBackground );
    background.receiveShadow = true;
    background.position.set( 0, 0, - 1 );
    scene.add( background );

    var geometryCylinder = new THREE.CylinderGeometry( 0.5, 0.5, 1, 32 );
    var materialCylinder = new THREE.MeshPhongMaterial( { "color": 0xff0000 } );

    mesh = new THREE.Mesh( geometryCylinder, materialCylinder );
    mesh.castShadow = true;
    mesh.receiveShadow = true;
    scene.add( mesh );
  }

  animate() {

    if(!mounted) {
      return;
    }

    mesh.rotation.x += 0.005;
    mesh.rotation.z += 0.01;


    render();

    Future.delayed(Duration(milliseconds: 40), () {
      animate();
    });
  }


  @override
  void dispose() {
    
    print(" dispose ............. ");

    three3dRender.dispose();

    super.dispose();
  }


 
}
