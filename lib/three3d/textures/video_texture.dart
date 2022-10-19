import 'package:three_dart/three3d/constants.dart';
import 'package:three_dart/three3d/textures/texture.dart';

class VideoTexture extends Texture {
  VideoTexture(video, mapping, wrapS, wrapT, magFilter, minFilter, format, type, anisotropy)
      : super(video, mapping, wrapS, wrapT, magFilter, minFilter, format, type, anisotropy, null) {
    isVideoTexture = true;
    this.minFilter = minFilter ?? LinearFilter;
    this.magFilter = magFilter ?? LinearFilter;

    generateMipmaps = false;
  }

  @override
  VideoTexture clone() {
    return VideoTexture(image, null, null, null, null, null, null, null, null)..copy(this);
  }

  void update() {
    // var video = this.image;
    // var hasVideoFrameCallback = 'requestVideoFrameCallback' in video;
    // if ( hasVideoFrameCallback == false && video.readyState >= video.HAVE_CURRENT_DATA ) {
    // 	this.needsUpdate = true;
    // }
  }

  // updateVideo() {

  // 	this.needsUpdate = true;
  // 	video.requestVideoFrameCallback( updateVideo );

  // }

  // if ( 'requestVideoFrameCallback' in video ) {

  // 	video.requestVideoFrameCallback( updateVideo );

  // }

}
