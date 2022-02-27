import 'dart:async';

import 'package:example/TouchListener.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:flutter/widgets.dart';
import 'package:flutter_gl/flutter_gl.dart';
import 'package:three_dart/three_dart.dart' as THREE;
import 'package:three_dart_jsm/three_dart_jsm.dart' as THREE_JSM;

GlobalKey<webgl_animation_keyframesState> webgl_animation_keyframesGlobalKey =
    GlobalKey<webgl_animation_keyframesState>();

class webgl_animation_keyframes extends StatefulWidget {
  String fileName;

  webgl_animation_keyframes({Key? key, required this.fileName})
      : super(key: key);

  createState() => webgl_animation_keyframesState();
}

class webgl_animation_keyframesState extends State<webgl_animation_keyframes> {
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
  bool disposed = false;

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

    setState(() {});

    // TODO web wait dom ok!!!
    Future.delayed(Duration(milliseconds: 100), () async {
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
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.fileName),
      ),
      body: Builder(
        builder: (BuildContext context) {
          initSize(context);
          return SingleChildScrollView(child: _build(context));
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Text("render"),
        onPressed: () {
          clickRender();
        },
      ),
    );
  }

  emit(String name, event) {
    var _callbacks = _listeners[name];
    if (_callbacks != null && _callbacks.length > 0) {
      var _len = _callbacks.length;
      for (int i = 0; i < _len; i++) {
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
                      }))),
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

    if (verbose) {
      print("render cost: ${_t1 - _t} ");
      print(renderer!.info.memory);
      print(renderer!.info.render);
    }

    // 重要 更新纹理之前一定要调用 确保gl程序执行完毕
    _gl.flush();

    if (verbose) print(" render: sourceTexture: ${sourceTexture} ");

    if (!kIsWeb) {
      three3dRender.updateTexture(sourceTexture);
    }
  }

  initRenderer() {
    Map<String, dynamic> _options = {
      "width": width,
      "height": height,
      "gl": three3dRender.gl,
      "antialias": true,
      "canvas": three3dRender.element
    };
    renderer = THREE.WebGLRenderer(_options);
    renderer!.setPixelRatio(dpr);
    renderer!.setSize(width, height, false);
    renderer!.shadowMap.enabled = false;

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
    camera = new THREE.PerspectiveCamera(45, width / height, 1, 100);
    camera.position.set(8, 4, 12);

    // scene

    scene = new THREE.Scene();

    var pmremGenerator = new THREE.PMREMGenerator(renderer);
    scene.background = THREE.Color.fromHex(0xbfe3dd);
    scene.environment = pmremGenerator
        .fromScene(new THREE_JSM.RoomEnvironment(), 0.04)
        .texture;

    // var ambientLight = new THREE.AmbientLight( 0xcccccc, 0.4 );
    // scene.add( ambientLight );

    // var pointLight = new THREE.PointLight( 0xffffff, 0.8 );
    // camera.add( pointLight );

    scene.add(camera);

    camera.lookAt(scene.position);

    var loader = THREE_JSM.GLTFLoader(null).setPath('assets/models/gltf/test/');

    var result = await loader.loadAsync('tokyo.gltf');
    // var result = await loader.loadAsync( 'animate7.gltf', null);
    // var result = await loader.loadAsync( 'untitled22.gltf', null);

    print(result);

    print(" load gltf success result: ${result}  ");

    model = result["scene"];

    print(" load gltf success model: ${model}  ");

    model.position.set(1, 1, 0);
    model.scale.set(0.01, 0.01, 0.01);
    scene.add(model);

    mixer = new THREE.AnimationMixer(model);
    mixer.clipAction(result["animations"][0], null, null).play();

    loaded = true;

    animate();

    // scene.overrideMaterial = new THREE.MeshBasicMaterial();
  }

  clickRender() {
    print("clickRender..... ");
    animate();
  }

  animate() {
    if (!mounted || disposed) {
      return;
    }

    if (!loaded) {
      return;
    }

    if (controls == null) {
      // possible compatible with three.js OrbitControls, wait on progress...
      controls = new THREE_JSM.OrbitControls(
          camera, webgl_animation_keyframesGlobalKey.currentState);
      controls!.target.set(0, 0.5, 0);
      controls!.update();
      controls!.enablePan = false;
      controls!.enableDamping = true;
    }

    var delta = clock.getDelta();

    mixer.update(delta);

    controls?.update();

    render();

    Future.delayed(Duration(milliseconds: 40), () {
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
