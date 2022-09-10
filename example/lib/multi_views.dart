import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide Matrix4;

import 'package:flutter_gl/flutter_gl.dart';
import 'package:three_dart/three_dart.dart' as THREE;

class multi_views extends StatefulWidget {
  String fileName;
  multi_views({Key? key, required this.fileName}) : super(key: key);

  @override
  createState() => _MyAppState();
}


class _MyAppState extends State<multi_views> {
  
  THREE.WebGLRenderer? renderer;
  bool show = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    if(!kIsWeb) {
      init();
    }
  }

  init() async {
    var three3dRender = FlutterGlPlugin();
    await three3dRender.initialize(options: {"width": 1024, "height": 1024, "dpr": 1.0});
    await three3dRender.prepareContext();

    Map<String, dynamic> _options = {
      "width": 1024,
      "height": 1024,
      "gl": three3dRender.gl,
      "antialias": true,
    };
    renderer = THREE.WebGLRenderer(_options);
    renderer!.autoClear = true;

    setState(() {
      
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.fileName),
      ),
      body: SingleChildScrollView(child: _build(context)),
    );

  }

  Widget _build(BuildContext context) {
    return Column(
      children: [
        multi_views1(renderer: renderer),
        Container(height: 2, color: Colors.red,),
        multi_views2(renderer: renderer)
      ],
    );
  }

}



class multi_views1 extends StatefulWidget {
  THREE.WebGLRenderer? renderer;

  multi_views1({Key? key, this.renderer}) : super(key: key);

  @override
  createState() => _multi_views1_State();
}

class _multi_views1_State extends State<multi_views1> {
 
  THREE.WebGLRenderer? renderer;

  double width = 300;
  double height = 300;

  Size? screenSize;

  late THREE.Scene scene;
  late THREE.Camera camera;
  late THREE.Mesh mesh;

  double dpr = 1.0;

  var AMOUNT = 4;

  bool verbose = true;
  bool disposed = false;

  bool loaded = false;

  late THREE.Object3D object;

  late THREE.Texture texture;

  late THREE.WebGLMultisampleRenderTarget renderTarget;

  THREE.AnimationMixer? mixer;
  THREE.Clock clock = THREE.Clock();

  dynamic? sourceTexture;

  late FlutterGlPlugin three3dRender;

  Future<void> initPlatformState() async {
    width = screenSize!.width;
    height = width;

    three3dRender = FlutterGlPlugin();

    Map<String, dynamic> _options = {
      "antialias": true,
      "alpha": false,
      "width": width.toInt(),
      "height": height.toInt(),
      "dpr": dpr
    };

    await three3dRender.initialize(options: _options);

    setState(() {});

    // TODO web wait dom ok!!!
    Future.delayed(const Duration(milliseconds: 100), () async {
      await three3dRender.prepareContext();

      initScene();
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
    return Container(
     
      child: Builder(
        builder: (BuildContext context) {
          initSize(context);
          return SingleChildScrollView(child: _build(context));
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
                  width: 300,
                  height: 300,
                  color: Colors.black,
                  child: Builder(builder: (BuildContext context) {
                    if (kIsWeb) {
                      return three3dRender.isInitialized
                          ? HtmlElementView(
                              viewType: three3dRender.textureId!.toString())
                          : Container();
                    } else {
                      return three3dRender.isInitialized
                          ? Texture(textureId: three3dRender.textureId!)
                          : Container();
                    }
                  })),
            ],
          ),
        ),


        
      ],
    );
  }

  clickRender() {
    print(" click render... ");
    animate();
  }

  render() {
    
    int _t = DateTime.now().millisecondsSinceEpoch;

    final _gl = three3dRender.gl;


    if (!kIsWeb) renderer!.setRenderTarget(renderTarget);
    renderer!.render(scene, camera);

    int _t1 = DateTime.now().millisecondsSinceEpoch;

    if (verbose) {
      // print("render cost: ${_t1 - _t} ");
      // print(renderer!.info.memory);
      // print(renderer!.info.render);
    }

    // 重要 更新纹理之前一定要调用 确保gl程序执行完毕
    _gl.flush();

    // print("three3dRender 1: ${three3dRender.textureId} render: sourceTexture: $sourceTexture ");

    if (!kIsWeb) {
      three3dRender.updateTexture(sourceTexture);
    }
  }

  initRenderer() {

    
    renderer = widget.renderer;

    if(renderer == null) {
      Map<String, dynamic> _options = {
        "width": width,
        "height": height,
        "gl": three3dRender.gl,
        "antialias": true,
      };
      renderer = THREE.WebGLRenderer(_options);
      renderer!.autoClear = true;
    }
    

    if (!kIsWeb) {
      var pars = THREE.WebGLRenderTargetOptions({"format": THREE.RGBAFormat});
      renderTarget = THREE.WebGLMultisampleRenderTarget(
          (width * dpr).toInt(), (height * dpr).toInt(), pars);
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
    camera = THREE.PerspectiveCamera(45, width / height, 1, 2200);
    camera.position.set(3, 6, 100);

    // scene

    scene = THREE.Scene();

    var ambientLight = THREE.AmbientLight(0xffffff, 0.9);
    scene.add(ambientLight);

    var pointLight = THREE.PointLight(0xffffff, 0.8);

    pointLight.position.set(0, 0, 0);

    camera.add(pointLight);
    scene.add(camera);

    camera.lookAt(scene.position);

    var geometry = THREE.BoxGeometry(20, 20, 20);
    var material = THREE.MeshBasicMaterial({"color": 0xff0000});

    object = THREE.Mesh(geometry, material);

    scene.add(object);

    // scene.overrideMaterial = new THREE.MeshBasicMaterial();

    loaded = true;

    setState(() {
      
    });

    animate();
  }

  animate() {
    if (!mounted || disposed) {
      return;
    }

    if (!loaded) {
      return;
    }
    object.rotation.x = object.rotation.x + 0.01;

    render();

    Future.delayed(const Duration(milliseconds: 40), () {
      animate();
    });
  }

  @override
  void dispose() {
    print(" dispose ............. ");
    disposed = true;
    three3dRender.dispose();

    super.dispose();
  }
}




class multi_views2 extends StatefulWidget {
  THREE.WebGLRenderer? renderer;

  multi_views2({Key? key, this.renderer}) : super(key: key);

  @override
  createState() => _multi_views2_State();
}

class _multi_views2_State extends State<multi_views2> {
  THREE.WebGLRenderer? renderer;
  late FlutterGlPlugin three3dRender;
  int? fboId;
  double width = 300;
  double height = 300;

  Size? screenSize;

  late THREE.Scene scene;
  late THREE.Camera camera;
  late THREE.Mesh mesh;

  double dpr = 1.0;

  var AMOUNT = 4;

  bool verbose = true;
  bool disposed = false;

  bool loaded = false;

  late THREE.Object3D object;

  late THREE.Texture texture;

  late THREE.WebGLMultisampleRenderTarget renderTarget;

  THREE.AnimationMixer? mixer;
  THREE.Clock clock = THREE.Clock();

  dynamic? sourceTexture;

  @override
  void initState() {
    super.initState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    width = screenSize!.width;
    height = width;
    three3dRender = FlutterGlPlugin();

    Map<String, dynamic> _options = {
      "antialias": true,
      "alpha": false,
      "width": width.toInt(),
      "height": height.toInt(),
      "dpr": dpr
    };

    await three3dRender.initialize(options: _options);

    setState(() {});

    // TODO web wait dom ok!!!
    Future.delayed(const Duration(milliseconds: 100), () async {
      await three3dRender.prepareContext();

      initScene();
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
    return SizedBox(
      width: width,
      height: height,
      child: Builder(
        builder: (BuildContext context) {
          initSize(context);
          return SingleChildScrollView(child: _build(context));
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
                  child: Builder(builder: (BuildContext context) {
                    if (kIsWeb) {
                      return three3dRender.isInitialized
                          ? HtmlElementView(
                              viewType: three3dRender.textureId!.toString())
                          : Container();
                    } else {
                      return three3dRender.isInitialized
                          ? Texture(textureId: three3dRender.textureId!)
                          : Container(color: Colors.yellow,);
                    }
                  })),
            ],
          ),
        ),
      ],
    );
  }

  clickRender() {
    print(" click render... ");
    animate();
  }

  render() {
    
    int _t = DateTime.now().millisecondsSinceEpoch;

    final _gl = three3dRender.gl;
    if (!kIsWeb) renderer!.setRenderTarget(renderTarget);
    renderer!.render(scene, camera);

    int _t1 = DateTime.now().millisecondsSinceEpoch;

    if (verbose) {
      print("render cost: ${_t1 - _t} ");
      print(renderer!.info.memory);
      print(renderer!.info.render);
    }

    // 重要 更新纹理之前一定要调用 确保gl程序执行完毕
    _gl.flush();

    print("three3dRender 2: ${three3dRender.textureId} render: sourceTexture: $sourceTexture ");

    if (!kIsWeb) {
      three3dRender.updateTexture(sourceTexture);
    }
  }

  initRenderer() {
    renderer = widget.renderer;

    if(renderer == null) {
      Map<String, dynamic> _options = {
        "width": width,
        "height": height,
        "gl": three3dRender.gl,
        "antialias": true,
      };
      renderer = THREE.WebGLRenderer(_options);
      renderer!.autoClear = true;
    }

    if (!kIsWeb) {
      var pars = THREE.WebGLRenderTargetOptions({"format": THREE.RGBAFormat});
      renderTarget = THREE.WebGLMultisampleRenderTarget(
          (width * dpr).toInt(), (height * dpr).toInt(), pars);
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
    camera = THREE.PerspectiveCamera(45, width / height, 1, 2200);
    camera.position.set(3, 6, 100);

    // scene

    scene = THREE.Scene();

    scene.background = THREE.Color(1, 1, 0);

    var ambientLight = THREE.AmbientLight(0xffffff, 0.9);
    scene.add(ambientLight);

    var pointLight = THREE.PointLight(0xffffff, 0.8);

    pointLight.position.set(0, 0, 0);

    camera.add(pointLight);
    scene.add(camera);

    camera.lookAt(scene.position);



    var geometry = THREE.BoxGeometry(10, 10, 20);
    var material = THREE.MeshBasicMaterial();

    object = THREE.Mesh(geometry, material);


    scene.add(object);


    loaded = true;

    animate();
  }

  animate() {
   
    var delta = clock.getDelta();

    object.rotation.y = object.rotation.y + 0.02;
    object.rotation.x = object.rotation.x + 0.01;


    mixer?.update(delta);

    render();

    Future.delayed(const Duration(milliseconds: 40), () {
      animate();
    });
  }

  @override
  void dispose() {
    print(" dispose ............. ");
    disposed = true;
    three3dRender.dispose();

    super.dispose();
  }
}
