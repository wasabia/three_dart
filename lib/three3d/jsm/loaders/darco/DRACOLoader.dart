part of darco;



class DRACOLoader {


  factory DRACOLoader(manager) {
    return DRACOLoaderPlatform(manager);
  }


  setDecoderPath( path ) {}
  setDecoderConfig( Map<String, dynamic> config ) {}


}