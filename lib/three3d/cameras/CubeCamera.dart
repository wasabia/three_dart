part of three_camera;

var fov = 90, aspect = 1;

class CubeCamera extends Object3D {

  late WebGLCubeRenderTarget renderTarget;

  late PerspectiveCamera cameraPX;
  late PerspectiveCamera cameraNX;
  late PerspectiveCamera cameraPY;
  late PerspectiveCamera cameraNY;
  late PerspectiveCamera cameraPZ;
  late PerspectiveCamera cameraNZ;

  CubeCamera( num near, num far, WebGLCubeRenderTarget renderTarget ) {

    this.type = 'CubeCamera';

    if ( renderTarget.isWebGLCubeRenderTarget != true ) {

      print( 'THREE.CubeCamera: The constructor now expects an instance of WebGLCubeRenderTarget as third parameter.' );
      return;

    }

    this.renderTarget = renderTarget;

    var cameraPX = new PerspectiveCamera( fov: fov, aspect: aspect, near: near, far: far );
    cameraPX.layers = this.layers;
    cameraPX.up.set( 0, - 1, 0 );
    cameraPX.lookAt(  Vector3(1, 0, 0) );
    this.add( cameraPX );

    var cameraNX = new PerspectiveCamera( fov: fov, aspect: aspect, near: near, far: far );
    cameraNX.layers = this.layers;
    cameraNX.up.set( 0, - 1, 0 );
    cameraNX.lookAt( Vector3(- 1, 0, 0) );
    this.add( cameraNX );

    var cameraPY = new PerspectiveCamera( fov: fov, aspect: aspect, near: near, far: far );
    cameraPY.layers = this.layers;
    cameraPY.up.set( 0, 0, 1 );
    cameraPY.lookAt(  Vector3(0, 1, 0) );
    this.add( cameraPY );

    var cameraNY = new PerspectiveCamera( fov: fov, aspect: aspect, near: near, far: far );
    cameraNY.layers = this.layers;
    cameraNY.up.set( 0, 0, - 1 );
    cameraNY.lookAt( Vector3(0, - 1, 0) );
    this.add( cameraNY );

    var cameraPZ = new PerspectiveCamera( fov: fov, aspect: aspect, near: near, far: far );
    cameraPZ.layers = this.layers;
    cameraPZ.up.set( 0, - 1, 0 );
    cameraPZ.lookAt( Vector3(0, 0, 1) );
    this.add( cameraPZ );

    var cameraNZ = new PerspectiveCamera( fov: fov, aspect: aspect, near: near, far: far );
    cameraNZ.layers = this.layers;
    cameraNZ.up.set( 0, - 1, 0 );
    cameraNZ.lookAt( Vector3(0, 0, - 1) );
    this.add( cameraNZ );
  }


	update( renderer, scene ) {

		if ( this.parent == null ) this.updateMatrixWorld(false);

		var currentXrEnabled = renderer.xr.enabled;
		var currentRenderTarget = renderer.getRenderTarget();

		renderer.xr.enabled = false;

		var generateMipmaps = renderTarget.texture.generateMipmaps;

		renderTarget.texture.generateMipmaps = false;

		renderer.setRenderTarget( renderTarget, 0 );
		renderer.render( scene, cameraPX );

		renderer.setRenderTarget( renderTarget, 1 );
		renderer.render( scene, cameraNX );

		renderer.setRenderTarget( renderTarget, 2 );
		renderer.render( scene, cameraPY );

		renderer.setRenderTarget( renderTarget, 3 );
		renderer.render( scene, cameraNY );

		renderer.setRenderTarget( renderTarget, 4 );
		renderer.render( scene, cameraPZ );

		renderTarget.texture.generateMipmaps = generateMipmaps;

		renderer.setRenderTarget( renderTarget, 5 );
		renderer.render( scene, cameraNZ );

		renderer.setRenderTarget( currentRenderTarget );

		renderer.xr.enabled = currentXrEnabled;

	}

}