part of three_textures;

class DataTexture2DArray extends Texture {

  bool isDataTexture2DArray = true;
  late int wrapR;


  DataTexture2DArray( data , {int width = 1, int height = 1, num depth = 1} ) : super(null, null,null, null,null, null,null, null,null, null) {

    // this.image = ImageDataInfo(data, width, height, depth);

    this.image = ImageElement(width: width, height: height);

    this.magFilter = LinearFilter;
    this.minFilter = LinearFilter;

    this.wrapR = ClampToEdgeWrapping;

    this.generateMipmaps = false;
    this.flipY = false;

    this.needsUpdate = true;
  }




}

