import 'dart:async';
import 'dart:typed_data';

import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:flutter/widgets.dart';
import 'package:flutter_gl/flutter_gl.dart';


import 'package:three_dart/three_dart.dart' as THREE;
import 'package:three_bas/three_bas.dart' as THREE_BAS;

import 'Slide.dart';



class ExampleSlide extends StatefulWidget {
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<ExampleSlide> {
  


  late FlutterGlPlugin three3dRender;
  THREE.WebGLRenderer? renderer;

  int? fboId;
  late double width;
  late double height;

  Size? screenSize;

  late THREE.Scene scene;
  late THREE.Camera camera;
  late THREE.Mesh mesh;
  late THREE.Mesh background;
  late THREE.Light light2;
  num _rotateV = 0;
  int ii = 0;
  num dpr = 1.0;
  num delta = 0.0;

  late THREE.Group group;
  late THREE.Object3D object;
  
  late THREE.EffectComposer composer;
  late THREE.GlitchPass glitchPass;
  late THREE.LUTPass lutPass;
  late THREE.AnimationMixer mixer;
  late THREE.Clock clock;
  late THREE.WebGLRenderTarget renderTarget;
  late Slide slide;
  late Slide slide2;

  var mixers = [];
  var objects = [];
  dynamic? sourceTexture;
  dynamic? controls;


  ui.Image? _image;

  @override
  void initState() {
    super.initState();
    
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    width = 500;
    height = 500;

    three3dRender = FlutterGlPlugin(width.toInt(), height.toInt(), dpr: dpr);


    

    Map<String, dynamic> _options = {
      "antialias": true,
      "alpha": false
    };
    
    await three3dRender.initialize(options: _options);

    setState(() { });

    // TODO web wait dom ok!!!
    Future.delayed(Duration(milliseconds: 100), () {
      three3dRender.prepareContext();
    });
  
  }

  

  initSize(BuildContext context) {
    if (screenSize != null) {
      return;
    }

    final mqd = MediaQuery.of(context);

    screenSize = mqd.size;
    dpr = mqd.devicePixelRatio;

    print(" screenSize: ${screenSize} dpr: ${dpr} ");

    initPlatformState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('ShaderMaterial example app'),
        ),
        body: Builder(
          builder: (BuildContext context) {
            initSize(context);  
            return SingleChildScrollView(
              child: _build(context)
            );
          },
        ),
      ),
    );
  }

  Widget _build(BuildContext context) {


    return Column(
      children: [
        Container(
          width: width,
          height: width,
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
        _buildRow(context),
        _image != null ? Container(
          child: RawImage(
            image: _image
          ),
        ) : Container(
          width: 20,
          height: 20,
          color: Colors.yellow,
        )
      ],
    );
  }

  Widget _buildRow(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Row(
            children: [
              RaisedButton(
                onPressed: () async {
                  _onPressed();
                },
                child: Text("Render", style: TextStyle(fontSize: 13)),
              ),
              
            ],
          ),
          Container(
            margin: EdgeInsets.only(top: 20),
            child: Row(
              children: [
                RaisedButton(
                  onPressed: () async {
                    _addX();
                  },
                  child: Text("+X", style: TextStyle(fontSize: 13)),
                ),
                RaisedButton(
                  onPressed: () async {
                    _addY();
                  },
                  child: Text("+Y", style: TextStyle(fontSize: 13)),
                ),
                RaisedButton(
                  onPressed: () async {
                    _addZ();
                  },
                  child: Text("+Z", style: TextStyle(fontSize: 13)),
                ),

                RaisedButton(
                  onPressed: () async {
                    _fn1();
                  },
                  child: Text("FN1", style: TextStyle(fontSize: 13)),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  _onPressed() async {
    render();
  }

  _addX() {
   
    slide.mesh.material.uniforms["uTime"]["value"] += 0.1;

    render();
  }
  _addY() {
    slide.mesh.material.uniforms["uTime"]["value"] -= 0.1;

    render();
  }
  _addZ() {
    mesh.rotation.z = mesh.rotation.z + 0.1;
    render();
  }

  _fn1() {
    mesh.morphTargetInfluences[ 0 ] = mesh.morphTargetInfluences[ 0 ] + 0.1;
    render();
  }


  render() async {
    if(renderer == null) {
      await initScene();
    }

    int _t = DateTime.now().millisecondsSinceEpoch;

    final _gl = three3dRender.gl;
  


    renderer!.render(scene, camera);
   
    int _t1 = DateTime.now().millisecondsSinceEpoch;

    print("render cost: ${_t1 - _t} ");
    print(renderer!.info.memory);
    print(renderer!.info.render);
   
    // 重要 更新纹理之前一定要调用 确保gl程序执行完毕
    _gl.finish();

    // int glWidth = (width * dpr).toInt();
    // int glHeight = (height * dpr).toInt();

    // renderTarget
    // Uint8List buffer = Uint8List((width * height * 4).toInt());
    // renderer!.readRenderTargetPixels(renderTarget, 0, 0, width.toInt(), height.toInt(), buffer, null);

    // Uint8List pixels = _gl.readCurrentPixels(0,0,glWidth,glHeight);
    // print(" ------------------- pixels ---------------- ");
    // print(buffer);
    
    // _image = await makeImage(pixels, glWidth, glHeight);
    // print(" _image: ${_image!.width} ${_image!.height} ");
    // setState(() {});

  
    print(" render: sourceTexture: ${sourceTexture} ");

   

    if(!kIsWeb) {
      three3dRender.updateTexture(sourceTexture);
    }
    



  }

  Future<ui.Image> makeImage(Uint8List pixels, int width, int height) {
    final c = Completer<ui.Image>();
    ui.decodeImageFromPixels(
      pixels,
      width,
      height,
      ui.PixelFormat.rgba8888,
      c.complete,
    );
    return c.future;
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
    
    if(!kIsWeb) {
      var pars = THREE.WebGLRenderTargetOptions({ "minFilter": THREE.LinearFilter, "magFilter": THREE.LinearFilter, "format": THREE.RGBAFormat });
      renderTarget = THREE.WebGLMultisampleRenderTarget((width * dpr).toInt(), (height * dpr).toInt(), pars);
      renderer!.setRenderTarget(renderTarget);
      sourceTexture = renderer!.getRenderTargetGLTexture(renderTarget);
    }
  }

  initScene() async {
    initRenderer();
    

    // camera = new THREE.PerspectiveCamera( fov: 60, aspect: 1, near: 1, far: 10000 );

    var width = 128;
    var height = 80;

    int w = width ~/ 2;
    int h = height ~/ 2;
    camera = new THREE.OrthographicCamera(left: -w, right: w, top: h, bottom: -h);
    camera.position.z = 60;


    scene = new THREE.Scene();
    // scene.background = THREE.Color.fromHex( 0xFF00FF );

    camera.lookAt(scene.position);

    var loader = THREE.TextureLoader(null);
    var _texture = await loader.loadAsync("assets/winter.jpg", null);
   

    slide = new Slide(width, height, "in", null);
    // slide.setImage(_texture.image);
    slide.setTexture(_texture);

    
    // var l1 = new THREE.ImageLoader(null);
    // var img1 = await l1.loadAsync("assets/winter.jpg", null);
    // slide.setImage(img1);




    scene.add(slide.mesh);

  
    // slide2 = new Slide(width, height, "in");
    // var l2 = new THREE.ImageLoader(null);
    // l2.setCrossOrigin("Anonymous");
    // var img2 = await l2.loadAsync(
    //   "https://s3-us-west-2.amazonaws.com/s.cdpn.io/175711/spring.jpg",
    //   null
    // );

    // slide2.setImage(img2);
    // scene.add(slide2.mesh);

    print("renderer!.setSize width: ${width} height: ${height}  ");
  }

  animate() {
    render();

  }



 
}




