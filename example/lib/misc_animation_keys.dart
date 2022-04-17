import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:flutter_gl/flutter_gl.dart';
import 'package:three_dart/three_dart.dart' as THREE;

class misc_animation_keys extends StatefulWidget {
  String fileName;

  misc_animation_keys({Key? key, required this.fileName}) : super(key: key);

  @override
  createState() => _State();
}

class _State extends State<misc_animation_keys> {
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
  THREE.Clock clock = THREE.Clock();

  double dpr = 1.0;

  var AMOUNT = 4;

  bool verbose = true;

  late THREE.Object3D object;

  late THREE.Texture texture;

  late THREE.WebGLMultisampleRenderTarget renderTarget;

  dynamic sourceTexture;

  bool loaded = false;

  late THREE.Object3D model;

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
    _gl.finish();

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
    scene = THREE.Scene();

    //

    camera = THREE.PerspectiveCamera(40, width / height, 1, 1000);
    camera.position.set(25, 25, 50);
    camera.lookAt(scene.position);

    //

    var axesHelper = THREE.AxesHelper(10);
    scene.add(axesHelper);

    //

    var geometry = THREE.BoxGeometry(5, 5, 5);
    var material =
        THREE.MeshBasicMaterial({"color": 0xffffff, "transparent": true});
    var mesh = THREE.Mesh(geometry, material);
    scene.add(mesh);

    // create a keyframe track (i.e. a timed sequence of keyframes) for each animated property
    // Note: the keyframe track type should correspond to the type of the property being animated

    // POSITION
    var positionKF = THREE.VectorKeyframeTrack(
        '.position', [0, 1, 2], [0, 0, 0, 30, 0, 0, 0, 0, 0], null);

    // SCALE
    var scaleKF = THREE.VectorKeyframeTrack(
        '.scale', [0, 1, 2], [1, 1, 1, 2, 2, 2, 1, 1, 1], null);

    // ROTATION
    // Rotation should be performed using quaternions, using a THREE.QuaternionKeyframeTrack
    // Interpolating Euler angles (.rotation property) can be problematic and is currently not supported

    // set up rotation about x axis
    var xAxis = THREE.Vector3(1, 0, 0);

    var qInitial = THREE.Quaternion().setFromAxisAngle(xAxis, 0);
    var qFinal = THREE.Quaternion().setFromAxisAngle(xAxis, THREE.Math.PI);
    var quaternionKF = THREE.QuaternionKeyframeTrack(
        '.quaternion',
        [0, 1, 2],
        [
          qInitial.x,
          qInitial.y,
          qInitial.z,
          qInitial.w,
          qFinal.x,
          qFinal.y,
          qFinal.z,
          qFinal.w,
          qInitial.x,
          qInitial.y,
          qInitial.z,
          qInitial.w
        ],
        null);

    // COLOR
    var colorKF = THREE.ColorKeyframeTrack('.material.color', [0, 1, 2],
        [1, 0, 0, 0, 1, 0, 0, 0, 1], THREE.InterpolateDiscrete);

    // OPACITY
    var opacityKF = THREE.NumberKeyframeTrack(
        '.material.opacity', [0, 1, 2], [1, 0, 1], null);

    // create an animation sequence with the tracks
    // If a negative time value is passed, the duration will be calculated from the times of the passed tracks array
    var clip = THREE.AnimationClip(
        'Action', 3, [scaleKF, positionKF, quaternionKF, colorKF, opacityKF]);

    // setup the THREE.AnimationMixer
    mixer = THREE.AnimationMixer(mesh);

    // create a ClipAction and set it to play
    var clipAction = mixer.clipAction(clip);
    clipAction!.play();

    //

    loaded = true;

    animate();

    // scene.overrideMaterial = new THREE.MeshBasicMaterial();
  }

  clickRender() {
    print("clickRender..... ");
    animate();
  }

  animate() {
    if (!mounted) {
      return;
    }

    if (!loaded) {
      return;
    }

    var delta = clock.getDelta();

    print(" delat: $delta ");

    mixer.update(delta);

    render();

    Future.delayed(const Duration(milliseconds: 40), () {
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
