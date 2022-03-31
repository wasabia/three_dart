import 'dart:async';



import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:flutter_gl/flutter_gl.dart';

import 'package:three_dart/three_dart.dart' as THREE;
import 'package:three_dart_jsm/three_dart_jsm.dart' as THREE_JSM;

class webgl_geometry_text extends StatefulWidget {
  String fileName;
  webgl_geometry_text({Key? key, required this.fileName}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<webgl_geometry_text> {
  late FlutterGlPlugin three3dRender;
  THREE.WebGLRenderer? renderer;

  int? fboId;
  late double width;
  late double height;

  Size? screenSize;

  late THREE.Scene scene;
  late THREE.Camera camera;
  late THREE.Mesh mesh;
  late THREE.Group group;
  late List<THREE.Material> materials;

  double dpr = 1.0;

  var AMOUNT = 4;

  bool verbose = true;
  bool disposed = false;

  String text = "Three Dart";

  late THREE.WebGLRenderTarget renderTarget;

  dynamic? sourceTexture;

  double fontHeight = 20,
      size = 70,
      hover = 30,
      curveSegments = 4,
      bevelThickness = 2,
      bevelSize = 1.5;
  bool bevelEnabled = true;
  bool mirror = true;

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

      await initScene();
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
    renderer = THREE.WebGLRenderer(_options);
    renderer!.setPixelRatio(dpr);
    renderer!.setSize(width, height, false);
    renderer!.shadowMap.enabled = false;

    if (!kIsWeb) {
      var pars = THREE.WebGLRenderTargetOptions({
        "minFilter": THREE.LinearFilter,
        "magFilter": THREE.LinearFilter,
        "format": THREE.RGBAFormat
      });
      renderTarget = THREE.WebGLMultisampleRenderTarget(
          (width * dpr), (height * dpr), pars);
      renderer!.setRenderTarget(renderTarget);
      sourceTexture = renderer!.getRenderTargetGLTexture(renderTarget);
    }
  }

  initScene() async {
    initRenderer();
    await initPage();
  }

  initPage() async {
    // CAMERA

    camera = THREE.PerspectiveCamera(30, width / height, 1, 1500);
    camera.position.set(0, 400, 700);

    var cameraTarget = THREE.Vector3(0, 50, 0);
    camera.lookAt(cameraTarget);

    // SCENE

    scene = THREE.Scene();
    scene.background = THREE.Color.fromHex(0x000000);
    scene.fog = THREE.Fog(THREE.Color.fromHex(0x000000), 250, 1400);
    // LIGHTS

    var dirLight = THREE.DirectionalLight(0xffffff, 0.125);
    dirLight.position.set(0, 0, 1).normalize();
    scene.add(dirLight);

    var pointLight = THREE.PointLight(0xffffff, 1.5);
    pointLight.position.set(0, 100, 90);
    scene.add(pointLight);

    // Get text from hash

    pointLight.color!.setHSL(THREE.Math.random(), 1, 0.5);
    // hex = decimalToHex( pointLight.color!.getHex() );

    materials = [
      THREE.MeshPhongMaterial(
          {"color": 0xffffff, "flatShading": true}), // front
      THREE.MeshPhongMaterial({"color": 0xffffff}) // side
    ];

    group = THREE.Group();

    // change size position fit mobile
    group.position.y = 50;
    group.scale.set(1, 1, 1);

    scene.add(group);

    var font = await loadFont();

    createText(font);

    var plane = THREE.Mesh(
        THREE.PlaneGeometry(10000, 10000),
        THREE.MeshBasicMaterial(
            {"color": 0xffffff, "opacity": 0.5, "transparent": true}));
    plane.position.y = -100;
    plane.rotation.x = -THREE.Math.PI / 2;
    scene.add(plane);

    animate();
  }

  loadFont() async {
    var loader = THREE_JSM.TYPRLoader(null);
    var fontJson = await loader.loadAsync("assets/pingfang.ttf");

    print("loadFont successs ............ ");
    print(fontJson);

    return THREE.TYPRFont(fontJson);
  }

  createText(font) {
    var textGeo = THREE.TextGeometry(text, {
      "font": font,
      "size": size,
      "height": fontHeight,
      "curveSegments": curveSegments,
      "bevelThickness": bevelThickness,
      "bevelSize": bevelSize,
      "bevelEnabled": bevelEnabled
    });

    textGeo.computeBoundingBox();

    var centerOffset =
        -0.5 * (textGeo.boundingBox!.max.x - textGeo.boundingBox!.min.x);

    var textMesh1 = THREE.Mesh(textGeo, materials);

    textMesh1.position.x = centerOffset;
    textMesh1.position.y = hover;
    textMesh1.position.z = 0;

    textMesh1.rotation.x = 0;
    textMesh1.rotation.y = THREE.Math.PI * 2;

    group.add(textMesh1);

    if (mirror) {
      var textMesh2 = THREE.Mesh(textGeo, materials);

      textMesh2.position.x = centerOffset;
      textMesh2.position.y = -hover;
      textMesh2.position.z = height;

      textMesh2.rotation.x = THREE.Math.PI;
      textMesh2.rotation.y = THREE.Math.PI * 2;

      group.add(textMesh2);
    }
  }

  // decimalToHex( d ) {

  //   var hex = Number( d ).toString( 16 );
  //   hex = "000000".substring( 0, 6 - hex.length ) + hex;
  //   return hex.toUpperCase();

  // }

  animate() {
    if (!mounted || disposed) {
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
