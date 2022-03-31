import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:flutter_gl/flutter_gl.dart';
import 'package:three_dart/three_dart.dart' as THREE;
import 'package:three_dart_jsm/three_dart_jsm.dart' as THREE_JSM;

class webgl_animation_cloth extends StatefulWidget {
  String fileName;

  webgl_animation_cloth({Key? key, required this.fileName}) : super(key: key);

  @override
  createState() => _State();
}

double restDistance = 25;

int xSegs = 10;
int ySegs = 10;

var DRAG = 1 - 0.03;

var DAMPING = 0.03;
var MASS = 0.1;

class _State extends State<webgl_animation_cloth> {
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
  THREE_JSM.OrbitControls? controls;

  double dpr = 1.0;

  var AMOUNT = 4;

  int startTime = 0;

  bool verbose = true;
  bool disposed = false;

  late THREE.Object3D object;

  late THREE.Texture texture;

  late THREE.WebGLMultisampleRenderTarget renderTarget;

  dynamic? sourceTexture;

  bool loaded = false;

  late THREE.Object3D model;

  late THREE.ParametricGeometry clothGeometry;

  Map<String, dynamic> params = {"enableWind": true, "showBall": true};

  var pins = [];

  var windForce = THREE.Vector3(0, 0, 0);

  var ballPosition = THREE.Vector3(0, -45, 0);
  var ballSize = 60; //40

  var tmpForce = THREE.Vector3();
  var diff = THREE.Vector3();

  late Cloth cloth;

  var GRAVITY = 981 * 1.4;
  var gravity = THREE.Vector3(0, -981 * 1.4, 0).multiplyScalar(0.1);

  var TIMESTEP = 18 / 1000;
  var TIMESTEP_SQ = (18 / 1000) * (18 / 1000);

  var sphere;

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
    renderer!.shadowMap.enabled = true;

    if (!kIsWeb) {
      var pars = THREE.WebGLRenderTargetOptions({"format": THREE.RGBAFormat});
      renderTarget = THREE.WebGLMultisampleRenderTarget(
          (width * dpr), (height * dpr), pars);
      renderTarget.samples = 4;
      renderer!.setRenderTarget(renderTarget);
      sourceTexture = renderer!.getRenderTargetGLTexture(renderTarget);
    }
  }

  initScene() {
    initRenderer();
    initPage();
  }

  // plane( width, height ) {

  //   return ( u, v, target ) {

  //     var x = ( u - 0.5 ) * width;
  //     var y = ( v + 0.5 ) * height;
  //     var z = 0;

  //     target.set( x, y, z );

  //   };

  // }

  // var clothFunction = plane( restDistance * xSegs, restDistance * ySegs );

  satisfyConstraints(p1, p2, distance) {
    diff.subVectors(p2.position, p1.position);
    var currentDist = diff.length();
    if (currentDist == 0) return; // prevents division by 0
    var correction = diff.multiplyScalar(1 - distance / currentDist);
    var correctionHalf = correction.multiplyScalar(0.5);
    p1.position.add(correctionHalf);
    p2.position.sub(correctionHalf);
  }

  simulate(now) {
    var windStrength = THREE.Math.cos(now / 7000) * 20 + 40;

    windForce.set(THREE.Math.sin(now / 2000), THREE.Math.cos(now / 3000),
        THREE.Math.sin(now / 1000));
    windForce.normalize();
    windForce.multiplyScalar(windStrength);

    // Aerodynamics forces

    var particles = cloth.particles;

    if (params["enableWind"]) {
      var normal = THREE.Vector3();
      var indices = clothGeometry.index!;
      var normals = clothGeometry.attributes["normal"];

      for (var i = 0, il = indices.count; i < il; i += 3) {
        for (var j = 0; j < 3; j++) {
          int indx = indices.getX(i + j)!.toInt();
          normal.fromBufferAttribute(normals, indx);
          tmpForce
              .copy(normal)
              .normalize()
              .multiplyScalar(normal.dot(windForce));
          particles[indx].addForce(tmpForce);
        }
      }
    }

    for (var i = 0, il = particles.length; i < il; i++) {
      var particle = particles[i];
      particle.addForce(gravity);

      particle.integrate(TIMESTEP_SQ);
    }

    // Start Constraints

    var constraints = cloth.constraints;
    var il = constraints.length;

    for (var i = 0; i < il; i++) {
      var constraint = constraints[i];
      satisfyConstraints(constraint[0], constraint[1], constraint[2]);
    }

    // Ball Constraints

    ballPosition.z = -THREE.Math.sin(now / 600) * 90; //+ 40;
    ballPosition.x = THREE.Math.cos(now / 400) * 70;

    if (params["showBall"]) {
      sphere.visible = true;

      for (var i = 0, il = particles.length; i < il; i++) {
        var particle = particles[i];
        var pos = particle.position;
        diff.subVectors(pos, ballPosition);
        if (diff.length() < ballSize) {
          // collided
          diff.normalize().multiplyScalar(ballSize);
          pos.copy(ballPosition).add(diff);
        }
      }
    } else {
      sphere.visible = false;
    }

    // Floor Constraints

    for (var i = 0, il = particles.length; i < il; i++) {
      var particle = particles[i];
      var pos = particle.position;
      if (pos.y < -250) {
        pos.y = -250;
      }
    }

    // Pin Constraints

    for (var i = 0, il = pins.length; i < il; i++) {
      var xy = pins[i];
      var p = particles[xy];
      p.position.copy(p.original);
      p.previous.copy(p.original);
    }
  }

  initPage() async {
    /* testing cloth simulation */

    cloth = Cloth(xSegs, ySegs);

    var pinsFormation = [];
    pins = [6];

    pinsFormation.add(pins);

    pins = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10];
    pinsFormation.add(pins);

    pins = [0];
    pinsFormation.add(pins);

    pins = []; // cut the rope ;)
    pinsFormation.add(pins);

    pins = [0, cloth.w]; // classic 2 pins
    pinsFormation.add(pins);

    pins = pinsFormation[1];

    togglePins() {
      // pins = pinsFormation[ ~ ~ ( THREE.Math.random() * pinsFormation.length ) ];
    }

    // scene

    scene = THREE.Scene();
    scene.background = THREE.Color.fromHex(0xcce0ff);
    scene.fog = THREE.Fog(0xcce0ff, 500, 10000);

    // camera

    camera = THREE.PerspectiveCamera(30, width / height, 1, 10000);
    camera.position.set(1000, 50, 1500);

    // lights

    camera.lookAt(scene.position);

    scene.add(THREE.AmbientLight(0x666666, 1));

    var light = THREE.DirectionalLight(0xdfebff, 1);
    light.position.set(50, 200, 100);
    light.position.multiplyScalar(1.3);

    light.castShadow = true;

    light.shadow!.mapSize.width = 1024;
    light.shadow!.mapSize.height = 1024;

    var d = 300;

    light.shadow!.camera!.left = -d;
    light.shadow!.camera!.right = d;
    light.shadow!.camera!.top = d;
    light.shadow!.camera!.bottom = -d;

    light.shadow!.camera!.far = 1000;

    scene.add(light);

    // cloth material

    var loader = THREE.TextureLoader(null);
    var clothTexture = await loader.loadAsync(
        'assets/textures/patterns/circuit_pattern.png', null);
    // clothTexture.anisotropy = 16;

    var clothMaterial = THREE.MeshLambertMaterial(
        {"alphaMap": clothTexture, "side": THREE.DoubleSide, "alphaTest": 0.5});

    // cloth geometry

    clothGeometry =
        THREE.ParametricGeometry(clothFunction, cloth.w, cloth.h);

    // cloth mesh

    object = THREE.Mesh(clothGeometry, clothMaterial);
    object.position.set(0, 0, 0);
    object.castShadow = true;
    scene.add(object);

    // sphere

    var ballGeo = THREE.SphereGeometry(ballSize, 32, 16);
    var ballMaterial = THREE.MeshLambertMaterial();

    sphere = THREE.Mesh(ballGeo, ballMaterial);
    sphere.castShadow = true;
    sphere.receiveShadow = true;
    sphere.visible = false;
    scene.add(sphere);

    // ground

    var groundTexture = await loader.loadAsync(
        'assets/textures/terrain/grasslight-big.jpg', null);
    groundTexture.wrapS = groundTexture.wrapT = THREE.RepeatWrapping;
    groundTexture.repeat.set(25, 25);
    groundTexture.anisotropy = 16;
    groundTexture.encoding = THREE.sRGBEncoding;

    var groundMaterial = THREE.MeshLambertMaterial({"map": groundTexture});

    var mesh =
        THREE.Mesh(THREE.PlaneGeometry(20000, 20000), groundMaterial);
    mesh.position.y = -250;
    mesh.rotation.x = -THREE.Math.PI / 2;
    mesh.receiveShadow = true;
    scene.add(mesh);

    // poles

    var poleGeo = THREE.BoxGeometry(5, 375, 5);
    var poleMat = THREE.MeshLambertMaterial();

    mesh = THREE.Mesh(poleGeo, poleMat);
    mesh.position.x = -125;
    mesh.position.y = -62;
    mesh.receiveShadow = true;
    mesh.castShadow = true;
    scene.add(mesh);

    mesh = THREE.Mesh(poleGeo, poleMat);
    mesh.position.x = 125;
    mesh.position.y = -62;
    mesh.receiveShadow = true;
    mesh.castShadow = true;
    scene.add(mesh);

    mesh = THREE.Mesh(THREE.BoxGeometry(255, 5, 5), poleMat);
    mesh.position.y = -250 + (750 / 2);
    mesh.position.x = 0;
    mesh.receiveShadow = true;
    mesh.castShadow = true;
    scene.add(mesh);

    var gg = THREE.BoxGeometry(10, 10, 10);
    mesh = THREE.Mesh(gg, poleMat);
    mesh.position.y = -250;
    mesh.position.x = 125;
    mesh.receiveShadow = true;
    mesh.castShadow = true;
    scene.add(mesh);

    mesh = THREE.Mesh(gg, poleMat);
    mesh.position.y = -250;
    mesh.position.x = -125;
    mesh.receiveShadow = true;
    mesh.castShadow = true;
    scene.add(mesh);

    loaded = true;
    startTime = DateTime.now().millisecondsSinceEpoch;

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

    var delta = clock.getDelta();

    var currentTime = DateTime.now().millisecondsSinceEpoch;

    simulate(currentTime - startTime);

    var p = cloth.particles;

    for (var i = 0, il = p.length; i < il; i++) {
      var v = p[i].position;

      clothGeometry.attributes["position"].setXYZ(i, v.x, v.y, v.z);
    }

    clothGeometry.attributes["position"].needsUpdate = true;

    clothGeometry.computeVertexNormals();

    sphere.position.copy(ballPosition);

    render();

    Future.delayed(const Duration(milliseconds: 33), () {
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

class Particle {
  late THREE.Vector3 position;
  late THREE.Vector3 previous;
  late THREE.Vector3 original;
  late THREE.Vector3 a;

  dynamic mass;
  late num invMass;

  late THREE.Vector3 tmp;
  late THREE.Vector3 tmp2;

  Particle(x, y, z, mass) {
    position = THREE.Vector3();
    previous = THREE.Vector3();
    original = THREE.Vector3();
    a = THREE.Vector3(0, 0, 0); // acceleration
    this.mass = mass;
    invMass = 1 / mass;
    tmp = THREE.Vector3();
    tmp2 = THREE.Vector3();

    // init

    clothFunction(x, y, position); // position
    clothFunction(x, y, previous); // previous
    clothFunction(x, y, original);
  }

  // Force -> Acceleration

  addForce(force) {
    a.add(tmp2.copy(force).multiplyScalar(invMass));
  }

  // Performs Verlet integration

  integrate(timesq) {
    var newPos = tmp.subVectors(position, previous);
    newPos.multiplyScalar(DRAG).add(position);
    newPos.add(a.multiplyScalar(timesq));

    tmp = previous;
    previous = position;
    position = newPos;

    a.set(0, 0, 0);
  }
}

class Cloth {
  late int w;
  late int h;

  late List<Particle> particles;
  late List<dynamic> constraints;

  Cloth([int w = 10, int h = 10]) {
    this.w = w;
    this.h = h;

    List<Particle> particles = [];
    List<dynamic> constraints = [];

    // Create particles

    for (var v = 0; v <= h; v++) {
      for (var u = 0; u <= w; u++) {
        particles.add(Particle(u / w, v / h, 0, MASS));
      }
    }

    // Structural

    for (var v = 0; v < h; v++) {
      for (var u = 0; u < w; u++) {
        constraints.add(
            [particles[index(u, v)], particles[index(u, v + 1)], restDistance]);

        constraints.add(
            [particles[index(u, v)], particles[index(u + 1, v)], restDistance]);
      }
    }

    for (var u = w, v = 0; v < h; v++) {
      constraints.add(
          [particles[index(u, v)], particles[index(u, v + 1)], restDistance]);
    }

    for (var v = h, u = 0; u < w; u++) {
      constraints.add(
          [particles[index(u, v)], particles[index(u + 1, v)], restDistance]);
    }

    this.particles = particles;
    this.constraints = constraints;
  }

  index(u, v) {
    return u + v * (w + 1);
  }
}

clothFunction(u, v, target) {
  double width = restDistance * xSegs;
  double height = restDistance * ySegs;

  double x = (u - 0.5) * width;
  double y = (v + 0.5) * height;
  double z = 0.0;

  target.set(x, y, z);
}
