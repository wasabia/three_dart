
part of three_textures;

class DataTexture extends Texture {

  bool isDataTexture = true;
  
  
  DataTexture( data, width, height, format, type, mapping, wrapS, wrapT, magFilter, minFilter, anisotropy, encoding ) : super( null, mapping, wrapS, wrapT, magFilter, minFilter, format, type, anisotropy, encoding ) {
    
    // this.image = ImageDataInfo(data, width ?? 1, height ?? 1, null);

    this.image = ImageElement(data: data, width: width ?? 1, height: height ?? 1);


    this.magFilter = magFilter != null ? magFilter : NearestFilter;
    this.minFilter = minFilter != null ? minFilter : NearestFilter;

    this.generateMipmaps = false;
    this.flipY = false;
    this.unpackAlignment = 1;

    this.needsUpdate = true;
  }



}
