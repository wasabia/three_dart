import 'dart:async';

import 'dart:typed_data';

import 'dart:ui' as ui;


import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:flutter/widgets.dart';
import 'package:flutter_gl/flutter_gl.dart';


import 'package:three_dart/three_dart.dart' as THREE;

import 'package:three_dart_jsm/three_dart_jsm.dart' as THREE_JSM;



class webgl_debug extends StatefulWidget {
  String fileName;
  webgl_debug({Key? key, required this.fileName}) : super(key: key);

  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<webgl_debug> {


  late FlutterGlPlugin three3dRender;
  THREE.WebGLRenderer? renderer;

  int? fboId;
  late double width;
  late double height;

  Size? screenSize;

  late THREE.Scene scene;
  late THREE.Camera camera;
  late THREE.Mesh mesh;

  late THREE.Light spotLight;
  late THREE.Light dirLight;
  late THREE.Light pointLight;
  late THREE.Mesh torusKnot;
  late THREE.Mesh cube;

  int delta = 0;

  late THREE.Material material;
  
  num dpr = 1.0;

  var AMOUNT = 4;

  bool verbose = true;

  int count = 1000;

  bool inited = false;

  late THREE.WebGLRenderTarget renderTarget;

  dynamic? sourceTexture;

  late THREE_JSM.ShadowMapViewer dirLightShadowMapViewer;
  late THREE_JSM.ShadowMapViewer spotLightShadowMapViewer;
  late THREE_JSM.ShadowMapViewer pointLightShadowMapViewer;

  @override
  void initState() {
    super.initState();
    
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    width = screenSize!.width;
    height = screenSize!.height;

    three3dRender = FlutterGlPlugin();

    Map<String, dynamic> _options = {
      "antialias": true,
      "alpha": false,
      "width": width.toInt(), 
      "height": height.toInt(), 
      "dpr": dpr
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



    renderShadowMapViewers();

   
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
    renderer!.shadowMap.enabled = true;
    renderer!.shadowMap.type = THREE.BasicShadowMap;
    
    if(!kIsWeb) {
      var pars = THREE.WebGLRenderTargetOptions({ "minFilter": THREE.LinearFilter, "magFilter": THREE.LinearFilter, "format": THREE.RGBAFormat });
      renderTarget = THREE.WebGLMultisampleRenderTarget((width * dpr).toInt(), (height * dpr).toInt(), pars);
      renderer!.setRenderTarget(renderTarget);
      sourceTexture = renderer!.getRenderTargetGLTexture(renderTarget);
    }
  }


  
  initScene() async {
    initRenderer();
    await initPage();
  }

  initPage() async {

    _initScene();
    _initShadowMapViewers();

    inited = true;
  }

  _initScene() {

    camera = new THREE.PerspectiveCamera( 45, width / height, 1, 1000 );
    camera.position.set( 0, 15, 70 );

    scene = new THREE.Scene();
    scene.background = THREE.Color.fromHex(0x333333);

    camera.lookAt(scene.position);

    // Lights

    scene.add( new THREE.AmbientLight( 0x404040, 0.5 ) );

    spotLight = new THREE.SpotLight( 0xffffff, 1 );
    spotLight.name = 'Spot Light';
    spotLight.angle = THREE.Math.PI / 5;
    spotLight.penumbra = 0.3;
    spotLight.position.set( 10, 10, 5 );
    spotLight.castShadow = true;
    // spotLight.shadow!.camera!.near = 1;
    // spotLight.shadow!.camera!.far = 30;
    // spotLight.shadow!.mapSize.width = 1024;
    // spotLight.shadow!.mapSize.height = 1024;
    scene.add( spotLight );

    // scene.add( new THREE.CameraHelper( spotLight.shadow!.camera ) );


    pointLight = new THREE.PointLight( 0xffffff, 1 );
    pointLight.name = 'Point Light';
    pointLight.position.set( 1, 10, 1 );
    pointLight.castShadow = true;
    // scene.add( pointLight );
    // scene.add( new THREE.CameraHelper( pointLight.shadow!.camera ) );

    var _light = THREE.HemisphereLight(0xffffff, 0xaaaaaa, 1.0);
    _light.name = 'HemisphereLight Light';
    _light.position.set( 1, 10, 1 );
    _light.castShadow = true;
    // scene.add( _light );


    dirLight = new THREE.DirectionalLight( 0xffffff, 1 );
    dirLight.name = 'Dir. Light';
    dirLight.position.set( 0, 10, 0 );
    dirLight.castShadow = true;
    // dirLight.shadow!.camera!.near = 1;
    // dirLight.shadow!.camera!.far = 10;
    // dirLight.shadow!.camera!.right = 15;
    // dirLight.shadow!.camera!.left = - 15;
    // dirLight.shadow!.camera!.top	= 15;
    // dirLight.shadow!.camera!.bottom = - 15;
    // dirLight.shadow!.mapSize.width = 1024;
    // dirLight.shadow!.mapSize.height = 1024;
    // scene.add( dirLight );

    // scene.add( new THREE.CameraHelper( dirLight.shadow!.camera ) );

    // Geometry
    var geometry = new THREE.TorusKnotGeometry( 25, 8, 75, 20 );
    var material = new THREE.MeshPhongMaterial( {
      "color": 0xff0000,
      "shininess": 150,
      "specular": 0x222222
    } );

    torusKnot = new THREE.Mesh( geometry, material );
    torusKnot.scale.multiplyScalar( 1 / 18 );
    torusKnot.position.y = 3;
    torusKnot.castShadow = true;
    torusKnot.receiveShadow = true;
    scene.add( torusKnot );


    var geometry3 = new THREE.BoxGeometry( 10, 0.15, 10 );
    var material2 = new THREE.MeshStandardMaterial( {
      "color": 0xaa2299,
      "shininess": 150,
      "specular": 0x111111
    } );

    var ground = new THREE.Mesh( geometry3, material2 );
    ground.scale.multiplyScalar( 3 );
    ground.castShadow = false;
    ground.receiveShadow = true;
    scene.add( ground );

  }

  _initShadowMapViewers() {

    dirLightShadowMapViewer = new THREE_JSM.ShadowMapViewer( dirLight, width, height );
    spotLightShadowMapViewer = new THREE_JSM.ShadowMapViewer( spotLight, width, height );
    pointLightShadowMapViewer = new THREE_JSM.ShadowMapViewer( pointLight, width, height );
    resizeShadowMapViewers();

  }

  renderShadowMapViewers() {

    // dirLightShadowMapViewer.render( renderer );
    // spotLightShadowMapViewer.render( renderer );
    // pointLightShadowMapViewer.render( renderer );

  }

  resizeShadowMapViewers() {

    var size = width * 0.15;

    dirLightShadowMapViewer.position["x"] = 10;
    dirLightShadowMapViewer.position["y"] = 10;
    dirLightShadowMapViewer.size["width"] = size;
    dirLightShadowMapViewer.size["height"] = size;
    dirLightShadowMapViewer.update(); //Required when setting position or size directly

    spotLightShadowMapViewer.setSize( size, size );
    spotLightShadowMapViewer.setPosition( size + 20, 10 );
    // spotLightShadowMapViewer.update();	//NOT required because .set updates automatically

    pointLightShadowMapViewer.setSize( size, size );
    pointLightShadowMapViewer.setPosition( size + 80, 10 );
  }



  animate() {

    if(!mounted) {
      return;
    }

    if(!inited) {
      return;
    }

  
    torusKnot.rotation.x += 0.025;
    torusKnot.rotation.y += 0.2;
    torusKnot.rotation.z += 0.1;



    render();

    // Future.delayed(Duration(milliseconds: 40), () {
    //   animate();
    // });
  }


  @override
  void dispose() {
    
    print(" dispose ............. ");

    three3dRender.dispose();

    super.dispose();
  }


 
}
