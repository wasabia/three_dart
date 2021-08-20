import 'dart:async';
import 'dart:html';
import 'dart:typed_data';

import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:flutter/widgets.dart';
import 'package:flutter_gl/flutter_gl.dart';


import 'package:three_dart/three_dart.dart' as THREE;




class ExampleModifierCurve extends StatefulWidget {
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<ExampleModifierCurve> {
  


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

  ui.Image? _image;

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

  Widget _build(BuildContext context) {


    return Column(
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
   
    update();

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
    mesh.morphTargetInfluences[ 0 ] = mesh.morphTargetInfluences[ 0 ] + 0.1;
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


  update() {
    var vertexpos = 0;
    var colorpos = 0;
    var numConnected = 0;

    for ( var i = 0; i < particleCount; i ++ )
      particlesData[ i ]["numConnections"] = 0;

    for ( var i = 0; i < particleCount; i ++ ) {

      // get the particle
      var particleData = particlesData[ i ];

      particlePositions[ i * 3 ] += particleData["velocity"].x;
      particlePositions[ i * 3 + 1 ] += particleData["velocity"].y;
      particlePositions[ i * 3 + 2 ] += particleData["velocity"].z;

      if ( particlePositions[ i * 3 + 1 ] < - rHalf || particlePositions[ i * 3 + 1 ] > rHalf )
        particleData["velocity"].y = - particleData["velocity"].y;

      if ( particlePositions[ i * 3 ] < - rHalf || particlePositions[ i * 3 ] > rHalf )
        particleData["velocity"].x = - particleData["velocity"].x;

      if ( particlePositions[ i * 3 + 2 ] < - rHalf || particlePositions[ i * 3 + 2 ] > rHalf )
        particleData["velocity"].z = - particleData["velocity"].z;

      if ( limitConnections && particleData["numConnections"] >= maxConnections )
        continue;

      // Check collision
      for ( var j = i + 1; j < particleCount; j ++ ) {

        var particleDataB = particlesData[ j ];
        if ( limitConnections && particleDataB["numConnections"] >= maxConnections )
          continue;

        var dx = particlePositions[ i * 3 ] - particlePositions[ j * 3 ];
        var dy = particlePositions[ i * 3 + 1 ] - particlePositions[ j * 3 + 1 ];
        var dz = particlePositions[ i * 3 + 2 ] - particlePositions[ j * 3 + 2 ];
        var dist = THREE.Math.sqrt( dx * dx + dy * dy + dz * dz );

        if ( dist < minDistance ) {

          particleData["numConnections"] ++;
          particleDataB["numConnections"] ++;

          var alpha = 1.0 - dist / minDistance;

          positions[ vertexpos ++ ] = particlePositions[ i * 3 ];
          positions[ vertexpos ++ ] = particlePositions[ i * 3 + 1 ];
          positions[ vertexpos ++ ] = particlePositions[ i * 3 + 2 ];

          positions[ vertexpos ++ ] = particlePositions[ j * 3 ];
          positions[ vertexpos ++ ] = particlePositions[ j * 3 + 1 ];
          positions[ vertexpos ++ ] = particlePositions[ j * 3 + 2 ];

          colors[ colorpos ++ ] = alpha;
          colors[ colorpos ++ ] = alpha;
          colors[ colorpos ++ ] = alpha;

          colors[ colorpos ++ ] = alpha;
          colors[ colorpos ++ ] = alpha;
          colors[ colorpos ++ ] = alpha;

          numConnected ++;

        }

      }

    }


    linesMesh.geometry.setDrawRange( 0, numConnected * 2 );
    linesMesh.geometry.attributes["position"].needsUpdate = true;
    linesMesh.geometry.attributes["color"].needsUpdate = true;

    // linesMesh.geometry.attributes["instanceStart"].needsUpdate = true;
    // linesMesh.geometry.attributes["instanceEnd"].needsUpdate = true;
    // linesMesh.geometry.attributes["instanceColorStart"].needsUpdate = true;
    // linesMesh.geometry.attributes["instanceColorEnd"].needsUpdate = true;


    pointCloud.geometry.attributes["position"].needsUpdate = true;
  }

  initScene() async {
    initRenderer();
    

    scene = new THREE.Scene();
    camera = new THREE.PerspectiveCamera( fov: 40, aspect: 1, near: 1, far: 1000 );

    camera.position.set( 2, 2, 4 );
    camera.lookAt( scene.position );

    var initialPoints = [
      { "x": 1, "y": 0, "z": - 1 },
      { "x": 1, "y": 0, "z": 1 },
      { "x": - 1, "y": 0, "z": 1 },
      { "x": - 1, "y": 0, "z": - 1 },
    ];

    var boxGeometry = new THREE.BoxBufferGeometry( width: 0.1, height: 0.1, depth: 0.1 );
    var boxMaterial = new THREE.MeshBasicMaterial();


    var x = 0, y = 0;
    var heartShape = new THREE.Shape(null) // From http://blog.burlock.org/html5/130-paths
					.moveTo( x + 25, y + 25 )
					.bezierCurveTo( x + 25, y + 25, x + 20, y, x, y )
					.bezierCurveTo( x - 30, y, x - 30, y + 35, x - 30, y + 35 )
					.bezierCurveTo( x - 30, y + 55, x - 10, y + 77, x + 25, y + 95 )
					.bezierCurveTo( x + 60, y + 77, x + 80, y + 55, x + 80, y + 35 )
					.bezierCurveTo( x + 80, y + 35, x + 80, y, x + 50, y )
					.bezierCurveTo( x + 35, y, x + 25, y + 25, x + 25, y + 25 );

     var points = heartShape.getPoints( divisions: 50 );

    // var points = curve.getPoints( divisions: 50 );
    var line = new THREE.LineLoop(
      new THREE.BufferGeometry().setFromPoints( points ),
      new THREE.LineBasicMaterial( { "color": 0x00ff00 } )
    );

    scene.add( line );

    //


    //
   
  }


  animate() {
    render();

  }



 
}
