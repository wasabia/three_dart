import 'dart:async';

import 'package:example/TouchListener.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:flutter/widgets.dart';
import 'package:flutter_gl/flutter_gl.dart';
import 'package:three_dart/three_dart.dart' as THREE;
import 'package:three_dart_jsm/three_dart_jsm.dart' as THREE_JSM;

GlobalKey<webgl_debugState> webgl_animation_keyframesGlobalKey = GlobalKey<webgl_debugState>();


class webgl_debug extends StatefulWidget {
  String fileName;

  webgl_debug({Key? key, required this.fileName}) : super(key: key);

  createState() => webgl_debugState();
}

class webgl_debugState extends State<webgl_debug> {


  late FlutterGlPlugin three3dRender;
  THREE.WebGLRenderer? renderer;

  int? fboId;
  late double width;
  late double height;

  Size? screenSize;

  late THREE.Scene scene;
  late THREE.Camera camera;
  late THREE.Mesh mesh;


  late THREE.AnimationMixer mixer;
  THREE.Clock clock = new THREE.Clock();
  THREE_JSM.OrbitControls? controls;
  
  num dpr = 1.0;

  var AMOUNT = 4;

  bool verbose = true;

  late THREE.Object3D object;

  late THREE.Texture texture;

  late THREE.WebGLMultisampleRenderTarget renderTarget;

  dynamic? sourceTexture;
  
  bool loaded = false;

  late THREE.Object3D model;


  Map<String, List<Function>> _listeners = {};

  @override
  void initState() {
    super.initState();   
  }



  addEventListener(String name, Function callback, [bool flag = false]) {
    var _cls = _listeners[name] ?? [];
    _cls.add(callback);
    _listeners[name] = _cls;
  }

  removeEventListener(String name, Function callback, [bool flag = false]) {
    var _cls = _listeners[name] ?? [];
    _cls.remove(callback);
    _listeners[name] = _cls;
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
            clickRender();
          },
        ),
      ),
    );
  }

  emit(String name, event) {
    var _callbacks = _listeners[name];
    if(_callbacks != null && _callbacks.length > 0) {
      var _len = _callbacks.length;
      for(int i = 0; i < _len; i++) {
        var _cb = _callbacks[i];
        _cb(event);
      }
    }
  }
  
  Widget _build(BuildContext context) {
    return Column(
      children: [
        Container(
          child: Stack(
            children: [
              TouchListener(
                touchstart: (event) {
                  emit("touchstart", event);
                },
                touchmove: (event) {
                  emit("touchmove", event);
                },
                touchend: (event) {
                  emit("touchend", event);
                },
                pointerdown: (event) {
                  emit("pointerdown", event);
                },
                pointermove: (event) {
                  emit("pointermove", event);
                },
                pointerup: (event) {
                  emit("pointerup", event);
                },
                wheel: (event) {
                  emit("wheel", event);
                },
                child: Container(
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
    _gl.flush();

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
    renderer = THREE.WebGLRenderer( _options );
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

    camera = new THREE.PerspectiveCamera( 40, 1, 1, 100 );
    camera.position.set( 0, 0, 100 );

    // scene

    scene = new THREE.Scene();

    var ambientLight = new THREE.AmbientLight( 0xcccccc, 0.4 );
    scene.add( ambientLight );

    scene.add( camera );

    camera.lookAt( scene.position );



    var loader = THREE_JSM.GLTFLoader( null ).setPath( 'assets/models/gltf/test/' );
    
    // var result = await loader.loadAsync( 'tokyo.gltf', null );
    var result = await loader.loadAsync( 'animate7.gltf', null );
    // var result = await loader.loadAsync( 'untitled22.gltf', null );

    print(result);

    print(" load gltf success result: ${result}  ");

    model = result["scene"];

    print(" load gltf success model: ${model}  ");

    // model.position.set( 1, 1, 0 );
    // model.scale.set( 0.01, 0.01, 0.01 );
    scene.add( model );

    
    mixer = new THREE.AnimationMixer( model );
    mixer.clipAction( result["animations"][ 0 ], null, null ).play();


    // console.log(model);

    camera = result["cameras"][0];
  
    loaded = true;


    animate();


    // scene.overrideMaterial = new THREE.MeshBasicMaterial();
  }

  clickRender() {
    print("clickRender..... ");
    animate();
  }

  animate() {

    if(!mounted) {
      return;
    }

    if(!loaded) {
      return;
    }



    


    var delta = clock.getDelta();

    print(" delat: ${delta} ");

    mixer.update( delta );

    controls?.update();


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
