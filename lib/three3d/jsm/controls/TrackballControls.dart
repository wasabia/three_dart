part of jsm_controls;



class TrackballControls {

  factory TrackballControls(Object3D object, domElement) {
    return TrackballControlsPlatform(object, domElement);
  }


}