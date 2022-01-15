import 'dart:async';

import 'dart:typed_data';

import 'dart:ui' as ui;
import 'dart:ui';


import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:flutter/widgets.dart';
import 'package:flutter_gl/flutter_gl.dart';


import 'package:three_dart/three_dart.dart' as THREE;

import 'package:three_dart_jsm/three_dart_jsm.dart' as THREE_JSM;



class webgl_debug_for_macos extends StatefulWidget {
  String fileName;
  webgl_debug_for_macos({Key? key, required this.fileName}) : super(key: key);

  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<webgl_debug_for_macos> {


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
  bool disposed = false;

  int count = 1000;

  bool inited = false;

  Uint8List? resultImage;

  late THREE.WebGLRenderTarget renderTarget;

  dynamic? sourceTexture;


  @override
  void initState() {
    super.initState();
    
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    width = screenSize!.width * 0.5;
    height = width;
    // height = screenSize!.height;

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
    return Scaffold(
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

        if(resultImage != null) Image.memory(resultImage!, width: width, height: height,)
      ],
    );
  }

  render() {

    int _t = DateTime.now().millisecondsSinceEpoch;

    final _gl = three3dRender.gl;

    print( _gl.getString(_gl.VENDOR) );
    print( _gl.getString(_gl.RENDERER) );


    renderer!.render(scene, camera);

    int _t1 = DateTime.now().millisecondsSinceEpoch;

    if(verbose) {
      print("render cost: ${_t1 - _t} ");
      print(renderer!.info.memory);
      print(renderer!.info.render);
    }
    
   
    // 重要 更新纹理之前一定要调用 确保gl程序执行完毕
    _gl.flush();

    // var pixels = _gl.readCurrentPixels(0, 0, 10, 10);
    // print(" --------------pixels............. ");
    // print(pixels);

    // var _target = renderer!.getRenderTarget();
    // var buffer = Uint8List(_target.width * _target.height * 4);
    // renderer!.readRenderTargetPixels(_target, 0, 0, _target.width, _target.height, buffer, 0);

    // // print(" --------------buffer............. ");
    // // print(buffer.sublist(0, 100));

    // decodeImageFromPixels(buffer, _target.width, _target.height, ui.PixelFormat.rgba8888, (image) async {
    //   final pngBytes = await image.toByteData(format: ImageByteFormat.png);
      
    //   setState(() {
    //     resultImage = pngBytes!.buffer.asUint8List();
    //   });
    // });

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

    inited = true;
  }

  _initScene() {

    camera = new THREE.PerspectiveCamera( 45, width / height, 1, 1000 );
    camera.position.set( 0, 15, 70 );

    scene = new THREE.Scene();
    scene.background = THREE.Color(1.0, 0.0, 0.0);

    camera.lookAt(scene.position);

    dirLight = new THREE.DirectionalLight( 0xffffff, 1 );
    dirLight.name = 'Dir. Light';
    dirLight.position.set( 0, 20, 40 );
    scene.add(dirLight);

    var geometry = new THREE.BoxGeometry( 10, 10, 10 );
    var material = new THREE.MeshLambertMaterial( {
      "color": 0xffffff
    } );

    var box = new THREE.Mesh( geometry, material );

    scene.add( box );

  }



  animate() {

    if(!mounted || disposed) {
      return;
    }

    if(!inited) {
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
    disposed = true;
    three3dRender.dispose();

    super.dispose();
  }


 
}
