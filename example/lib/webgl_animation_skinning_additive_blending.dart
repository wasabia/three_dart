import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:flutter_gl/flutter_gl.dart';
import 'package:three_dart/three3d/objects/index.dart';
import 'package:three_dart/three_dart.dart' as three;
import 'package:three_dart_jsm/three_dart_jsm.dart' as THREE_JSM;

class webgl_animation_skinning_additive_blending extends StatefulWidget {
  String fileName;

  webgl_animation_skinning_additive_blending({Key? key, required this.fileName}) : super(key: key);

  @override
  createState() => _State();
}

class _State extends State<webgl_animation_skinning_additive_blending> {
  late FlutterGlPlugin three3dRender;
  three.WebGLRenderer? renderer;

  int? fboId;
  late double width;
  late double height;

  Size? screenSize;

  late three.Scene scene;
  late three.Camera camera;
  late three.Mesh mesh;

  late three.AnimationMixer mixer;
  late three.Clock clock;
  THREE_JSM.OrbitControls? controls;

  double dpr = 1.0;

  var AMOUNT = 4;

  bool verbose = true;
  bool disposed = false;

  late three.Object3D object;

  late three.Texture texture;

  late three.WebGLMultisampleRenderTarget renderTarget;

  dynamic? sourceTexture;

  bool loaded = false;

  late three.Object3D model;

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
        child: const Text("render"),
        onPressed: () {
          clickRender();
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
                  child: Container(
                      width: width,
                      height: height,
                      color: Colors.black,
                      child: Builder(builder: (BuildContext context) {
                        if (kIsWeb) {
                          return three3dRender.isInitialized
                              ? HtmlElementView(viewType: three3dRender.textureId!.toString())
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

    if (verbose) print(" render: sourceTexture: $sourceTexture ");

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
    renderer = three.WebGLRenderer(_options);
    renderer!.setPixelRatio(dpr);
    renderer!.setSize(width, height, false);
    renderer!.shadowMap.enabled = true;
    renderer!.outputEncoding = three.sRGBEncoding;

    if (!kIsWeb) {
      var pars = three.WebGLRenderTargetOptions({"format": three.RGBAFormat});
      renderTarget = three.WebGLMultisampleRenderTarget((width * dpr).toInt(), (height * dpr).toInt(), pars);
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
    camera = three.PerspectiveCamera(45, width / height, 0.1, 1000);
    camera.position.set(-1, 2, 3);
    camera.lookAt(three.Vector3(0, 1, 0));

    clock = three.Clock();

    scene = three.Scene();
    scene.background = three.Color.fromHex(0xa0a0a0);
    // scene.fog = three.Fog(0xa0a0a0, 10, 50);

    // var hemiLight = three.HemisphereLight(0xffffff, 0x444444);
    // hemiLight.position.set(0, 20, 0);
    // scene.add(hemiLight);

    // var dirLight = three.DirectionalLight(0xffffff);
    // dirLight.position.set(3, 10, 10);
    // dirLight.castShadow = true;
    // dirLight.shadow!.camera!.top = 2;
    // dirLight.shadow!.camera!.bottom = -2;
    // dirLight.shadow!.camera!.left = -2;
    // dirLight.shadow!.camera!.right = 2;
    // dirLight.shadow!.camera!.near = 0.1;
    // dirLight.shadow!.camera!.far = 40;
    // scene.add(dirLight);

    // var mesh = three.Mesh(three.PlaneGeometry(100, 100),
    //     three.MeshPhongMaterial({"color": 0x999999, "depthWrite": false}));
    // mesh.rotation.x = -three.Math.PI / 2;
    // mesh.receiveShadow = true;
    // scene.add(mesh);

    var loader = THREE_JSM.GLTFLoader(null);
    var gltf = await loader.loadAsync('assets/models/gltf/Xbot.gltf');

    model = gltf["scene"];
    scene.add(model);

    model.traverse((object) {
      if (object is Mesh) {
        object.castShadow = true;
      }
    });

    // var skeleton = three.SkeletonHelper(model);
    // skeleton.visible = true;
    // scene.add(skeleton);

    var animations = gltf["animations"];

    mixer = three.AnimationMixer(model);

    var idleAction = mixer.clipAction(animations[0]);
    var walkAction = mixer.clipAction(animations[3]);
    var runAction = mixer.clipAction(animations[1]);

    // var actions = [ idleAction, walkAction, runAction ];
    walkAction!.play();
    // activateAllActions();

    loaded = true;

    animate();

    // scene.overrideMaterial = new three.MeshBasicMaterial();
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

    var delta = clock.getDelta();

    mixer.update(delta);

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
