import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:flutter/widgets.dart';
import 'package:flutter_gl/flutter_gl.dart';
import 'package:three_dart/three_dart.dart' as THREE;
import 'package:three_dart_jsm/three_dart_jsm.dart' as THREE_JSM;

class webgl_loader_svg extends StatefulWidget {
  String fileName;
  webgl_loader_svg({Key? key, required this.fileName}) : super(key: key);

  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<webgl_loader_svg> {
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
  bool disposed = false;

  late THREE.Object3D object;

  late THREE.Texture texture;

  late THREE.WebGLMultisampleRenderTarget renderTarget;

  dynamic? sourceTexture;

  var guiData = {
    "currentURL": 'assets/models/svg/tiger.svg',
    // "currentURL": 'assets/models/svg/energy.svg',
    // "currentURL": 'assets/models/svg/hexagon.svg',
    // "currentURL": 'assets/models/svg/lineJoinsAndCaps.svg',
    // "currentURL": 'assets/models/svg/multiple-css-classes.svg',
    // "currentURL": 'assets/models/svg/threejs.svg',
    // "currentURL": 'assets/models/svg/zero-radius.svg',
    "drawFillShapes": true,
    "drawStrokes": true,
    "fillShapesWireframe": false,
    "strokesWireframe": false
  };

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
    camera = new THREE.PerspectiveCamera(50, width / height, 1, 1000);
    camera.position.set(0, 0, 200);

    loadSVG(guiData["currentURL"]);

    animate();
  }

  loadSVG(url) {
    //

    scene = new THREE.Scene();
    scene.background = new THREE.Color(0xb0b0b0);

    //

    var helper = new THREE.GridHelper(160, 10);
    helper.rotation.x = THREE.Math.PI / 2;
    scene.add(helper);

    //

    var loader = new THREE.SVGLoader(null);

    loader.load(url, (data) {
      var paths = data["paths"];

      print(" paths................ ");
      print(paths);

      var group = new THREE.Group();
      group.scale.multiplyScalar(0.25);
      group.position.x = -70;
      group.position.y = 70;
      group.scale.y *= -1;

      for (var i = 0; i < paths.length; i++) {
        var path = paths[i];

        var fillColor = path.userData["style"]["fill"];
        if (guiData["drawFillShapes"] == true &&
            fillColor != null &&
            fillColor != 'none') {
          var material = new THREE.MeshBasicMaterial({
            "color":
                new THREE.Color().setStyle(fillColor).convertSRGBToLinear(),
            "opacity": path.userData["style"]["fillOpacity"],
            "transparent": true,
            "side": THREE.DoubleSide,
            "depthWrite": false,
            "wireframe": guiData["fillShapesWireframe"]
          });

          var shapes = THREE.SVGLoader.createShapes(path);

          for (var j = 0; j < shapes.length; j++) {
            var shape = shapes[j];

            var geometry = new THREE.ShapeGeometry(shape);
            var mesh = new THREE.Mesh(geometry, material);

            group.add(mesh);
          }
        }

        var strokeColor = path.userData["style"]["stroke"];

        if (guiData["drawStrokes"] == true &&
            strokeColor != null &&
            strokeColor != 'none') {
          var material = new THREE.MeshBasicMaterial({
            "color":
                new THREE.Color().setStyle(strokeColor).convertSRGBToLinear(),
            "opacity": path.userData["style"]["strokeOpacity"],
            "transparent": true,
            "side": THREE.DoubleSide,
            "depthWrite": false,
            "wireframe": guiData["strokesWireframe"]
          });

          for (var j = 0, jl = path.subPaths.length; j < jl; j++) {
            var subPath = path.subPaths[j];

            var geometry = THREE.SVGLoader.pointsToStroke(
                subPath.getPoints(), path.userData["style"]);

            if (geometry != null) {
              var mesh = new THREE.Mesh(geometry, material);

              group.add(mesh);
            }
          }
        }
      }

      scene.add(group);

      render();
    });
  }

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
