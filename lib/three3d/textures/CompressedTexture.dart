part of three_textures;

class CompressedTexture extends Texture {

  late List mipmaps;
  bool isCompressedTexture = true;

  CompressedTexture( mipmaps, width, height, format, type, mapping, wrapS, wrapT, magFilter, minFilter, anisotropy, encoding ) : super(null, mapping, wrapS, wrapT, magFilter, minFilter, format, type, anisotropy, encoding) {
    
    // this.image = ImageDataInfo(null, width, height, null);

    print(" CompressedTexture todo ============ ");

    this.image = ImageElement(width: width, height: height);



    this.mipmaps = mipmaps;

    // no flipping for cube textures
    // (also flipping doesn't work for compressed textures )

    this.flipY = false;

    // can't generate mipmaps for compressed textures
    // mips must be embedded in DDS files

    this.generateMipmaps = false;
  }

}
