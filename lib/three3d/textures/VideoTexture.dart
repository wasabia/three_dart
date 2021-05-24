part of three_textures;

class VideoTexture extends Texture {


  bool isVideoTexture = true;

  VideoTexture( video, mapping, wrapS, wrapT, magFilter, minFilter, format, type, anisotropy ) : super(video, mapping, wrapS, wrapT, magFilter, minFilter, format, type, anisotropy, null) {

    this.format = format != null ? format : RGBFormat;

    this.minFilter = minFilter != null ? minFilter : LinearFilter;
    this.magFilter = magFilter != null ? magFilter : LinearFilter;

    this.generateMipmaps = false;


  }


  clone () {

		return VideoTexture( this.image, null, null, null, null, null, null,null,null ).copy( this );

	}

	

	// update() {

	// 	const video = this.image;
	// 	const hasVideoFrameCallback = 'requestVideoFrameCallback' in video;

	// 	if ( hasVideoFrameCallback == false && video.readyState >= video.HAVE_CURRENT_DATA ) {

	// 		this.needsUpdate = true;

	// 	}

	// }

	// updateVideo() {

	// 	this.needsUpdate = true;
	// 	video.requestVideoFrameCallback( updateVideo );

	// }

	// if ( 'requestVideoFrameCallback' in video ) {

	// 	video.requestVideoFrameCallback( updateVideo );

	// }

}
