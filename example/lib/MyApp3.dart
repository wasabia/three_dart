import 'dart:async';
import 'dart:typed_data';

import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:flutter/widgets.dart';
import 'package:flutter_gl/flutter_gl.dart';


import 'package:three_dart/three_dart.dart' as THREE;




class MyApp3 extends StatefulWidget {
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp3> {
  


  late FlutterGlPlugin three3dRender;
  THREE.WebGLRenderer? renderer;

  int? fboId;
  late double width;
  late double height;

  Size? screenSize;

  THREE.Scene? scene;
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

  var mixers = [];
  var objects = [];
  dynamic? sourceTexture;
  dynamic? controls;

  var uniforms = {

    "amplitude": { "value": 0.0 }

  };
  
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
    group.rotation.x = group.rotation.x + 0.1;
    mesh.rotation.x = mesh.rotation.x + 0.1;

    render();
  }
  _addY() {
    group.rotation.y = group.rotation.y + 0.1;
    render();
  }
  _addZ() {
    group.rotation.z = group.rotation.z + 0.1;
    render();
  }

  _fn1() {
    mesh.morphTargetInfluences[ 0 ] = mesh.morphTargetInfluences[ 0 ] + 0.1;
    render();
  }


  render() async {
    
    final _gl = three3dRender.gl;

    
    // final cfbo = _gl.getIntegerv(GL_DRAW_FRAMEBUFFER_BINDING);
    // print(" cfbo: ${cfbo} ");

    if(renderer == null) {
      await initScene();
    }

    if(scene == null) {
      return;
    }
        
    // uniforms["amplitude"]!["value"] = uniforms["amplitude"]!["value"]! + 0.1;

    print("render start 0: ${DateTime.now().millisecondsSinceEpoch} ");

    var delta = 0.04;

    for ( var i = 0; i < mixers.length; i ++ ) {

      mixers[ i ].update( delta );

    }

    // controls.update();

    renderer!.render(scene, camera);
   

   

    // 重要 更新纹理之前一定要调用 确保gl程序执行完毕
    _gl.finish();

  
    print(" render: sourceTexture: ${sourceTexture} ");

    if(!kIsWeb) {
      three3dRender.updateTexture(sourceTexture);
    }
    
    print("render start 1: ${DateTime.now().millisecondsSinceEpoch} ");

    // Future.delayed(Duration(milliseconds: 40), () {
    //   render();
    // });

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
    renderer!.shadowMap.enabled = true;
    
    if(!kIsWeb) {
      var pars = THREE.WebGLRenderTargetOptions({ "minFilter": THREE.LinearFilter, "magFilter": THREE.LinearFilter, "format": THREE.RGBAFormat });
      renderTarget = THREE.WebGLMultisampleRenderTarget((width * dpr).toInt(), (height * dpr).toInt(), pars);
      renderer!.setRenderTarget(renderTarget);
      sourceTexture = renderer!.getRenderTargetGLTexture(renderTarget);
    }
  }

  initScene() async {
    initRenderer();
    


    var loader = new THREE.FontLoader(null);
    loader.responseType = "text";
    await loader.load( 'assets/helvetiker_bold.typeface.json', ( font ) {

      init( font );
      // animate();

    }, null, null );

  }


  init( font ) {

    var vertexshader = """
uniform float amplitude;

attribute vec3 customColor;
attribute vec3 displacement;

varying vec3 vNormal;
varying vec3 vColor;

void main() {

  vNormal = normal;
  vColor = customColor;

  vec3 newPosition = position + normal * amplitude * displacement;
  gl_Position = projectionMatrix * modelViewMatrix * vec4( newPosition, 1.0 );

}
    """;

    var fragmentshader = """
    varying vec3 vNormal;
    varying vec3 vColor;

    void main() {

      const float ambient = 0.4;

      vec3 light = vec3( 1.0 );
      light = normalize( light );

      float directional = max( dot( vNormal, light ), 0.0 );

      gl_FragColor = vec4( ( directional + ambient ) * vColor, 1.0 );

    }
    """;

    camera = new THREE.PerspectiveCamera( fov: 40, aspect: 1, near: 1, far: 10000 );
    camera.position.set( - 100, 100, 200 );

    scene = new THREE.Scene();
    scene!.background = THREE.Color.fromHex( 0x050505 );

    camera.lookAt(scene!.position);

    //

    var geometry = new THREE.TextGeometry( "FLUTTER GL", {

      "font": font,

      "size": 40,
      "height": 5,
      "curveSegments": 3,

      "bevelThickness": 2,
      "bevelSize": 1,
      "bevelEnabled": true

    } );

    geometry.center();

    var tessellateModifier = new THREE.TessellateModifier(maxEdgeLength: 8, maxIterations: 6 );

    var geometry3 = tessellateModifier.modify( geometry );

    //

    var geometry2 = new THREE.BufferGeometry().fromGeometry( geometry3 );

    var numFaces = (geometry2.attributes["position"].count / 3).toInt();

    var colors = List<num>.filled( numFaces * 3 * 3, 0 );
    var displacement = List<num>.filled( numFaces * 3 * 3, 0 );

    var color = THREE.Color(1,1,1);

    for ( var f = 0; f < numFaces; f ++ ) {

      var index = 9 * f;

      var h = 0.2 * THREE.Math.random();
      var s = 0.5 + 0.5 * THREE.Math.random();
      var l = 0.5 + 0.5 * THREE.Math.random();

      color.setHSL( h, s, l );

      var d = 10 * ( 0.5 - THREE.Math.random() );

      for ( var i = 0; i < 3; i ++ ) {

        colors[ index + ( 3 * i ) ] = color.r;
        colors[ index + ( 3 * i ) + 1 ] = color.g;
        colors[ index + ( 3 * i ) + 2 ] = color.b;

        displacement[ index + ( 3 * i ) ] = d;
        displacement[ index + ( 3 * i ) + 1 ] = d;
        displacement[ index + ( 3 * i ) + 2 ] = d;

      }

    }

    geometry2.setAttribute( 'customColor', new THREE.Float32BufferAttribute( colors, 3, false ) );
    geometry2.setAttribute( 'displacement', new THREE.Float32BufferAttribute( displacement, 3, false ) );

    //

 

    var shaderMaterial = new THREE.ShaderMaterial( {

      "uniforms": uniforms,
      "vertexShader": vertexshader,
      "fragmentShader": fragmentshader

    } );

    //

    mesh = new THREE.Mesh( geometry2, shaderMaterial );

    group = THREE.Group();

    group.add( mesh );

    group.scale.set(0.5, 0.5, 1);

    scene!.add( group );


    // controls = new THREE.TrackballControls( camera, renderer!.domElement );


  }


  animate() {
    render();

    Future.delayed(Duration(milliseconds: 50), () {
      animate();
    });
  }



 
}
