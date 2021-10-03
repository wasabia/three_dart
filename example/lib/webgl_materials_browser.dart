import 'dart:async';

import 'dart:typed_data';

import 'dart:ui' as ui;


import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:flutter/widgets.dart';
import 'package:flutter_gl/flutter_gl.dart';


import 'package:three_dart/three_dart.dart' as THREE;
import 'package:three_dart_jsm/three_dart_jsm.dart' as THREE_JSM;



class webgl_materials_browser extends StatefulWidget {
  String fileName;
  webgl_materials_browser({Key? key, required this.fileName}) : super(key: key);

  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<webgl_materials_browser> {


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

  late THREE.Object3D object;

  late THREE.Texture texture;

  late THREE.WebGLMultisampleRenderTarget renderTarget;

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
      var pars = THREE.WebGLRenderTargetOptions({ "format": THREE.RGBAFormat });
      renderTarget = THREE.WebGLMultisampleRenderTarget((width * dpr).toInt(), (height * dpr).toInt(), pars);
      renderTarget.samples = 4;
      renderer!.setRenderTarget(renderTarget);
      sourceTexture = renderer!.getRenderTargetGLTexture(renderTarget);
    }
  }


  
  initScene() {
    initRenderer();
    initPage();
  }

  initPage() async {

    camera = new THREE.PerspectiveCamera( 45, width / height, 1, 2000 );
    camera.position.z = 250;

    // scene

    scene = new THREE.Scene();

    // var pmremGenerator = new THREE.PMREMGenerator( renderer );
    // scene.environment = pmremGenerator.fromScene( THREE_JSM.RoomEnvironment(), sigma: 0.04 ).texture;

    var ambientLight = new THREE.AmbientLight( 0xcccccc, 0.4 );
    scene.add( ambientLight );

    var pointLight = new THREE.PointLight( 0xffffff, 0.8 );
    camera.add( pointLight );
    scene.add( camera );

    
    // texture
    var geometry = new THREE.TorusKnotGeometry( 10, 3, 200, 32 ).toNonIndexed();
    var material = new THREE.MeshPhysicalMaterial({
      "color": 0xff0abb,
      "roughness": 0
    });

    var object = THREE.Mesh(geometry, material);

    scene.add( object );
  }

  animate() {

    if(!mounted) {
      return;
    }

    

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
