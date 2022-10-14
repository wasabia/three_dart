import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:flutter_gl/flutter_gl.dart';

import 'package:three_dart/three_dart.dart' as three;

class WebGlGeometryShapes extends StatefulWidget {
  final String fileName;
  const WebGlGeometryShapes({Key? key, required this.fileName}) : super(key: key);

  @override
  State<WebGlGeometryShapes> createState() => _MyAppState();
}

class _MyAppState extends State<WebGlGeometryShapes> {
  late FlutterGlPlugin three3dRender;
  three.WebGLRenderer? renderer;

  int? fboId;
  late double width;
  late double height;

  Size? screenSize;

  late three.Scene scene;
  late three.Camera camera;
  late three.Mesh mesh;
  late three.Group group;
  late three.Texture texture;

  double dpr = 1.0;

  bool verbose = true;
  bool disposed = false;

  late three.WebGLRenderTarget renderTarget;

  dynamic sourceTexture;

  @override
  void initState() {
    super.initState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    width = screenSize!.width;
    height = screenSize!.height;

    three3dRender = FlutterGlPlugin();

    Map<String, dynamic> options = {
      "antialias": true,
      "alpha": false,
      "width": width.toInt(),
      "height": height.toInt(),
      "dpr": dpr
    };

    await three3dRender.initialize(options: options);

    setState(() {});

    // Wait for web
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
          render();
        },
      ),
    );
  }

  Widget _build(BuildContext context) {
    return Column(
      children: [
        Stack(
          children: [
            Container(
                width: width,
                height: height,
                color: Colors.black,
                child: Builder(builder: (BuildContext context) {
                  if (kIsWeb) {
                    return three3dRender.isInitialized
                        ? HtmlElementView(viewType: three3dRender.textureId!.toString())
                        : Container();
                  } else {
                    return three3dRender.isInitialized ? Texture(textureId: three3dRender.textureId!) : Container();
                  }
                })),
          ],
        ),
      ],
    );
  }

  render() {
    int t = DateTime.now().millisecondsSinceEpoch;

    final gl = three3dRender.gl;

    renderer!.render(scene, camera);

    int t1 = DateTime.now().millisecondsSinceEpoch;

    if (verbose) {
      print("render cost: ${t1 - t} ");
      print(renderer!.info.memory);
      print(renderer!.info.render);
    }

    // 重要 更新纹理之前一定要调用 确保gl程序执行完毕
    gl.flush();

    if (verbose) print(" render: sourceTexture: $sourceTexture ");

    if (!kIsWeb) {
      three3dRender.updateTexture(sourceTexture);
    }
  }

  initRenderer() {
    Map<String, dynamic> options = {
      "width": width,
      "height": height,
      "gl": three3dRender.gl,
      "antialias": true,
      "canvas": three3dRender.element
    };
    renderer = three.WebGLRenderer(options);
    renderer!.setPixelRatio(dpr);
    renderer!.setSize(width, height, false);
    renderer!.shadowMap.enabled = false;

    if (!kIsWeb) {
      var pars = three.WebGLRenderTargetOptions(
          {"minFilter": three.LinearFilter, "magFilter": three.LinearFilter, "format": three.RGBAFormat});
      renderTarget = three.WebGLMultisampleRenderTarget((width * dpr).toInt(), (height * dpr).toInt(), pars);
      renderer!.setRenderTarget(renderTarget);
      sourceTexture = renderer!.getRenderTargetGLTexture(renderTarget);
    }
  }

  initScene() {
    initRenderer();
    initPage();
  }

  initPage() async {
    scene = three.Scene();

    camera = three.PerspectiveCamera(50, width / height, 1, 2000);
    // let camra far
    camera.position.set(0, 150, 1500);
    scene.add(camera);

    var light = three.PointLight(0xffffff, 0.8);
    camera.add(light);

    group = three.Group();
    group.position.y = 50;
    scene.add(group);

    var loader = three.TextureLoader(null);
    texture = await loader.loadAsync("assets/textures/uv_grid_opengl.jpg", null);

    // it's necessary to apply these settings in order to correctly display the texture on a shape geometry

    texture.wrapS = texture.wrapT = three.RepeatWrapping;
    texture.repeat.set(0.008, 0.008);

    // California

    var californiaPts = [];

    californiaPts.add(three.Vector2(610, 320));
    californiaPts.add(three.Vector2(450, 300));
    californiaPts.add(three.Vector2(392, 392));
    californiaPts.add(three.Vector2(266, 438));
    californiaPts.add(three.Vector2(190, 570));
    californiaPts.add(three.Vector2(190, 600));
    californiaPts.add(three.Vector2(160, 620));
    californiaPts.add(three.Vector2(160, 650));
    californiaPts.add(three.Vector2(180, 640));
    californiaPts.add(three.Vector2(165, 680));
    californiaPts.add(three.Vector2(150, 670));
    californiaPts.add(three.Vector2(90, 737));
    californiaPts.add(three.Vector2(80, 795));
    californiaPts.add(three.Vector2(50, 835));
    californiaPts.add(three.Vector2(64, 870));
    californiaPts.add(three.Vector2(60, 945));
    californiaPts.add(three.Vector2(300, 945));
    californiaPts.add(three.Vector2(300, 743));
    californiaPts.add(three.Vector2(600, 473));
    californiaPts.add(three.Vector2(626, 425));
    californiaPts.add(three.Vector2(600, 370));
    californiaPts.add(three.Vector2(610, 320));

    for (var i = 0; i < californiaPts.length; i++) {
      californiaPts[i].multiplyScalar(0.25);
    }

    var californiaShape = three.Shape(californiaPts);

    // Triangle

    var triangleShape =
        three.Shape(null).moveTo(80.0, 20.0).lineTo(40.0, 80.0).lineTo(120.0, 80.0).lineTo(80.0, 20.0); // close path

    // Heart

    double x = 0, y = 0;

    var heartShape = three.Shape(null) // From http://blog.burlock.org/html5/130-paths
        .moveTo(x + 25, y + 25)
        .bezierCurveTo(x + 25, y + 25, x + 20, y, x, y)
        .bezierCurveTo(x - 30, y, x - 30, y + 35, x - 30, y + 35)
        .bezierCurveTo(x - 30, y + 55, x - 10, y + 77, x + 25, y + 95)
        .bezierCurveTo(x + 60, y + 77, x + 80, y + 55, x + 80, y + 35)
        .bezierCurveTo(x + 80, y + 35, x + 80, y, x + 50, y)
        .bezierCurveTo(x + 35, y, x + 25, y + 25, x + 25, y + 25);

    // Square

    double sqLength = 80;

    var squareShape = three.Shape(null)
        .moveTo(0.0, 0.0)
        .lineTo(0.0, sqLength)
        .lineTo(sqLength, sqLength)
        .lineTo(sqLength, 0.0)
        .lineTo(0.0, 0.0);

    // Rounded rectangle

    var roundedRectShape = three.Shape(null);

    roundedRect(ctx, num x, num y, num width, num height, num radius) {
      ctx.moveTo(x, y + radius);
      ctx.lineTo(x, y + height - radius);
      ctx.quadraticCurveTo(x, y + height, x + radius, y + height);
      ctx.lineTo(x + width - radius, y + height);
      ctx.quadraticCurveTo(x + width, y + height, x + width, y + height - radius);
      ctx.lineTo(x + width, y + radius);
      ctx.quadraticCurveTo(x + width, y, x + width - radius, y);
      ctx.lineTo(x + radius, y);
      ctx.quadraticCurveTo(x, y, x, y + radius);
    }

    roundedRect(roundedRectShape, 0, 0, 50, 50, 20);

    // Track

    var trackShape = three.Shape(null)
        .moveTo(40.0, 40.0)
        .lineTo(40.0, 160.0)
        .absarc(60.0, 160.0, 20.0, three.Math.PI, 0.0, true)
        .lineTo(80, 40)
        .absarc(60, 40, 20, 2 * three.Math.PI, three.Math.PI, true);

    // Circle

    double circleRadius = 40;
    var circleShape = three.Shape(null)
        .moveTo(0, circleRadius)
        .quadraticCurveTo(circleRadius, circleRadius, circleRadius, 0)
        .quadraticCurveTo(circleRadius, -circleRadius, 0, -circleRadius)
        .quadraticCurveTo(-circleRadius, -circleRadius, -circleRadius, 0)
        .quadraticCurveTo(-circleRadius, circleRadius, 0, circleRadius);

    // Fish

    var fishShape = three.Shape(null)
        .moveTo(x, y)
        .quadraticCurveTo(x + 50, y - 80, x + 90, y - 10)
        .quadraticCurveTo(x + 100, y - 10, x + 115, y - 40)
        .quadraticCurveTo(x + 115, y, x + 115, y + 40)
        .quadraticCurveTo(x + 100, y + 10, x + 90, y + 10)
        .quadraticCurveTo(x + 50, y + 80, x, y);

    // Arc circle

    var arcShape = three.Shape(null).moveTo(50, 10).absarc(10, 10, 40, 0, three.Math.PI * 2, false);

    var holePath = three.Path(null).moveTo(20, 10).absarc(10, 10, 10, 0, three.Math.PI * 2, true);

    arcShape.holes.add(holePath);

    // Smiley

    var smileyShape = three.Shape(null).moveTo(80, 40).absarc(40, 40, 40, 0, three.Math.PI * 2, false);

    var smileyEye1Path = three.Path(null).moveTo(35, 20).absellipse(25, 20, 10, 10, 0, three.Math.PI * 2, true, null);

    var smileyEye2Path = three.Path(null).moveTo(65, 20).absarc(55, 20, 10, 0, three.Math.PI * 2, true);

    var smileyMouthPath = three.Path(null)
        .moveTo(20, 40)
        .quadraticCurveTo(40, 60, 60, 40)
        .bezierCurveTo(70, 45, 70, 50, 60, 60)
        .quadraticCurveTo(40, 80, 20, 60)
        .quadraticCurveTo(5, 50, 20, 40);

    smileyShape.holes.add(smileyEye1Path);
    smileyShape.holes.add(smileyEye2Path);
    smileyShape.holes.add(smileyMouthPath);

    // Spline shape

    List<three.Vector2> splinepts = [];
    splinepts.add(three.Vector2(70, 20));
    splinepts.add(three.Vector2(80, 90));
    splinepts.add(three.Vector2(-30, 70));
    splinepts.add(three.Vector2(0, 0));

    var splineShape = three.Shape(null).moveTo(0, 0).splineThru(splinepts);

    var extrudeSettings = {
      "depth": 8,
      "bevelEnabled": true,
      "bevelSegments": 2,
      "steps": 2,
      "bevelSize": 1,
      "bevelThickness": 1
    };

    // addShape( shape, color, x, y, z, rx, ry,rz, s );

    addShape(californiaShape, extrudeSettings, 0xf08000, -300, -100, 0, 0, 0, 0, 1);
    addShape(triangleShape, extrudeSettings, 0x8080f0, -180, 0, 0, 0, 0, 0, 1);
    addShape(roundedRectShape, extrudeSettings, 0x008000, -150, 150, 0, 0, 0, 0, 1);
    addShape(trackShape, extrudeSettings, 0x008080, 200, -100, 0, 0, 0, 0, 1);
    addShape(squareShape, extrudeSettings, 0x0040f0, 150, 100, 0, 0, 0, 0, 1);
    addShape(heartShape, extrudeSettings, 0xf00000, 60, 100, 0, 0, 0, three.Math.PI, 1);
    addShape(circleShape, extrudeSettings, 0x00f000, 120, 250, 0, 0, 0, 0, 1);
    addShape(fishShape, extrudeSettings, 0x404040, -60, 200, 0, 0, 0, 0, 1);
    addShape(smileyShape, extrudeSettings, 0xf000f0, -200, 250, 0, 0, 0, three.Math.PI, 1);
    addShape(arcShape, extrudeSettings, 0x804000, 150, 0, 0, 0, 0, 0, 1);
    addShape(splineShape, extrudeSettings, 0x808080, -50, -100, 0, 0, 0, 0, 1);

    addLineShape(arcShape.holes[0], 0x804000, 150, 0, 0, 0, 0, 0, 1);

    for (var i = 0; i < smileyShape.holes.length; i += 1) {
      addLineShape(smileyShape.holes[i], 0xf000f0, -200, 250, 0, 0, 0, three.Math.PI, 1);
    }

    //

    animate();
  }

  addShape(shape, extrudeSettings, color, double x, double y, double z, double rx, double ry, double rz, double s) {
    // flat shape with texture
    // note: default UVs generated by THREE.ShapeGeometry are simply the x- and y-coordinates of the vertices

    var geometry = three.ShapeGeometry(shape);

    var mesh = three.Mesh(geometry, three.MeshPhongMaterial({"side": three.DoubleSide, "map": texture}));
    mesh.position.set(x, y, z - 175.0);
    mesh.rotation.set(rx, ry, rz);
    mesh.scale.set(s, s, s);
    group.add(mesh);

    // flat shape

    geometry = three.ShapeGeometry(shape);

    mesh = three.Mesh(geometry, three.MeshPhongMaterial({"color": color, "side": three.DoubleSide}));
    mesh.position.set(x, y, z - 125.0);
    mesh.rotation.set(rx, ry, rz);
    mesh.scale.set(s, s, s);
    group.add(mesh);

    // extruded shape

    var geometry2 = three.ExtrudeGeometry([shape], extrudeSettings);

    mesh = three.Mesh(geometry2, three.MeshPhongMaterial({"color": color}));
    mesh.position.set(x, y, z - 75.0);
    mesh.rotation.set(rx, ry, rz);
    mesh.scale.set(s, s, s);
    group.add(mesh);

    addLineShape(shape, color, x, y, z, rx, ry, rz, s);
  }

  addLineShape(shape, color, double x, double y, double z, double rx, double ry, double rz, double s) {
    // lines

    shape.autoClose = true;

    var points = shape.getPoints();
    var spacedPoints = shape.getSpacedPoints(50);

    var geometryPoints = three.BufferGeometry().setFromPoints(points);
    var geometrySpacedPoints = three.BufferGeometry().setFromPoints(spacedPoints);

    // solid line

    var line = three.Line(geometryPoints, three.LineBasicMaterial({"color": color}));
    line.position.set(x, y, z - 25);
    line.rotation.set(rx, ry, rz);
    line.scale.set(s, s, s);
    group.add(line);

    // line from equidistance sampled points

    line = three.Line(geometrySpacedPoints, three.LineBasicMaterial({"color": color}));
    line.position.set(x, y, z + 25);
    line.rotation.set(rx, ry, rz);
    line.scale.set(s, s, s);
    group.add(line);

    // vertices from real points

    var particles = three.Points(geometryPoints, three.PointsMaterial({"color": color, "size": 4}));
    particles.position.set(x, y, z + 75);
    particles.rotation.set(rx, ry, rz);
    particles.scale.set(s, s, s);
    group.add(particles);

    // equidistance sampled points

    particles = three.Points(geometrySpacedPoints, three.PointsMaterial({"color": color, "size": 4}));
    particles.position.set(x, y, z + 125);
    particles.rotation.set(rx, ry, rz);
    particles.scale.set(s, s, s);
    group.add(particles);
  }

  animate() {
    if (!mounted || disposed) {
      return;
    }

    // mesh.rotation.x += 0.005;
    // mesh.rotation.z += 0.01;

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
