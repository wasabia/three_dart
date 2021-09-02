import 'dart:async';

import 'dart:typed_data';

import 'dart:ui' as ui;

import 'package:example/EventListener.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:flutter/widgets.dart';
import 'package:flutter_gl/flutter_gl.dart';


import 'package:three_dart/three_dart.dart' as THREE;




class Webgl_interactive_voxelpainter extends StatefulWidget {
  Webgl_interactive_voxelpainter({Key? key}) : super(key: key);

  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<Webgl_interactive_voxelpainter> {


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

  late var matLine, line;

  var mixers = [];
  var objects = [];
  dynamic? sourceTexture;
  dynamic? controls;

 
  var positions, colors;
  var particles;
  var pointCloud;
  var particlePositions;
  var linesMesh;

  var maxParticleCount = 1000;
  var particleCount = 500;
  var r = 400;
  var rHalf = 200;
   var particlesData = [];
  var showDots = true;
  var showLines = true;
  var minDistance = 150;
  var limitConnections = false;
  var maxConnections = 20;
  // var particleCount = 500;
  
  var myText = THREE.Text();

  var plane;
  var pointer, raycaster, isShiftDown = false;

  var rollOverMesh, rollOverMaterial;
  var cubeGeo, cubeMaterial;


  ui.Image? _image;


  Map<String, List<Function>> _listeners = {};


  addEventListener(String name, Function callback, bool flag) {
    var _cls = _listeners[name] ?? [];
    _cls.add(callback);
    _listeners[name] = _cls;
  }

  @override
  void initState() {
    super.initState();
    
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    width = screenSize!.width;
    height = width;

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

  _onTapDown(TapDownDetails details) {
    var event = Event.fromJSON({
      "touches": [],
      "clientX": details.localPosition.dx, 
      "clientY": details.localPosition.dy,
      "page": {
        "x": details.globalPosition.dx,
        "y": details.globalPosition.dy
      }
    });
    emit("pointerdown", event);
  }

  _onPanStart(DragStartDetails details) {
    var event = Event.fromJSON({
      "touches": [
        {"clientX": details.localPosition.dx, "clientY": details.localPosition.dy}
      ],
      "clientX": details.localPosition.dx, 
      "clientY": details.localPosition.dy,
      "page": {
        "x": details.globalPosition.dx,
        "y": details.globalPosition.dy
      }
    });

    emit("pointerdown", event);
  }

  _onPanUpdate(DragUpdateDetails details) {
    var event = Event.fromJSON({
      "touches": [
        {
          "clientX": details.localPosition.dx, 
          "clientY": details.localPosition.dy,
          "pageX": details.globalPosition.dx, 
          "pageY": details.globalPosition.dy
        }
      ],
      "clientX": details.localPosition.dx, 
      "clientY": details.localPosition.dy,
      "deltaX": details.delta.dx,
      "deltaY": details.delta.dy,
      "page": {
        "x": details.globalPosition.dx,
        "y": details.globalPosition.dy
      }
    });

    emit("pointerupdate", event);

    render();
  }
  emit(String name, event) {
    var _callbacks = _listeners[name];
    if(_callbacks != null) {
      for(var _cb in _callbacks) {
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
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onPanStart: (DragStartDetails details) {
                    _onPanStart(details);
                  },
                  onPanUpdate: (DragUpdateDetails details) {
                    _onPanUpdate(details);
                  },
                  onTapDown: (TapDownDetails details) {
                    _onTapDown(details);
                  },
                  child: Container(
                    width: width,
                    height: width
                  ),
                ),
              ),
            ],
          ),
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
   


    render();
  }
  _addY() {
    mesh.rotation.y = mesh.rotation.y + 0.1;
    render();
  }
  _addZ() {
    mesh.rotation.z = mesh.rotation.z + 0.1;
    render();
  }

  _fn1() {
    mesh.morphTargetInfluences![ 0 ] = mesh.morphTargetInfluences![ 0 ] + 0.1;
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
    renderer!.shadowMap.enabled = false;
    
    if(!kIsWeb) {
      var pars = THREE.WebGLRenderTargetOptions({ "minFilter": THREE.LinearFilter, "magFilter": THREE.LinearFilter, "format": THREE.RGBAFormat });
      renderTarget = THREE.WebGLMultisampleRenderTarget((width * dpr).toInt(), (height * dpr).toInt(), pars);
      renderer!.setRenderTarget(renderTarget);
      sourceTexture = renderer!.getRenderTargetGLTexture(renderTarget);
    }
  }


  
  initScene() async {
    initRenderer();
    

    scene = new THREE.Scene();
    camera = new THREE.PerspectiveCamera( fov: 45, aspect: 1, near: 1, far: 10000 );

    camera.position.set( 500, 800, 1300 );
    camera.lookAt( scene.position );


    scene.background = THREE.Color.fromHex( 0xf0f0f0 );

    // roll-over helpers

    var rollOverGeo = new THREE.BoxGeometry( width: 50, height: 50, depth: 50 );
    rollOverMaterial = new THREE.MeshBasicMaterial( { "color": 0xff0000, "opacity": 0.5, "transparent": true } );
    rollOverMesh = new THREE.Mesh( rollOverGeo, rollOverMaterial );
    scene.add( rollOverMesh );

    // cubes

    cubeGeo = new THREE.BoxGeometry( width: 50, height: 50, depth: 50 );
    cubeMaterial = new THREE.MeshLambertMaterial( { "color": 0xfeb74c } );

    // cubeMaterial = new THREE.MeshLambertMaterial( { color: 0xfeb74c, map: new THREE.TextureLoader().load( 'textures/square-outline-textured.png' ) } );

    // grid

    var gridHelper = new THREE.GridHelper( size: 1000, divisions: 20 );
    scene.add( gridHelper );


    var mesh1 = new THREE.Mesh( cubeGeo, cubeMaterial );
    mesh1.position.set(25, 25, 25);
    scene.add( mesh1 );

    var mesh2 = new THREE.Mesh( cubeGeo, cubeMaterial );
    mesh2.position.set(75, 25, 25);
    scene.add( mesh2 );

    //

    raycaster = new THREE.Raycaster(null, null, null, null);
    pointer = new THREE.Vector2(0, 0);

    var geometry = new THREE.PlaneGeometry( width: 1000, height: 1000 );
    geometry.rotateX( - THREE.Math.PI / 2 );

    plane = new THREE.Mesh( geometry, new THREE.MeshBasicMaterial( { "visible": false } ) );
    scene.add( plane );

    objects.add( plane );

    // lights

    var ambientLight = new THREE.AmbientLight( THREE.Color.fromHex( 0x606060 ), 1 );
    scene.add( ambientLight );

    var directionalLight = new THREE.DirectionalLight( THREE.Color.fromHex( 0xffffff ), 1 );
    directionalLight.position.set( 1, 0.75, 0.5 ).normalize();
    scene.add( directionalLight );


    controls = new THREE.OrbitControls( camera, (widget.key as GlobalKey).currentState);
    // controls.listenToKeyEvents( window ); // optional

    //controls.addEventListener( 'change', render ); // call this only in static scenes (i.e., if there is no animation loop)

    // controls.enableDamping = true; // an animation loop is required when either damping or auto-rotation are enabled
    controls.dampingFactor = 0.05;

    controls.screenSpacePanning = false;

    controls.minDistance = 100.0;
    controls.maxDistance = 500.0;

    controls.maxPolarAngle = THREE.Math.PI / 2;
   
  }


  animate() {
    render();

  }



 
}
