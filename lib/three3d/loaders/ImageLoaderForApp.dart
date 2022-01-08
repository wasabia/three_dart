import 'dart:isolate';
import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart';
import 'package:three_dart/extra/Blob.dart';


class ImageLoaderLoader {

  static Future<Image?> loadImage(url, flipY, {Function? imageDecoder}) async {
   
    Image? image;
    if(imageDecoder == null) {
      Uint8List? bytes;
      if( url is Blob) {
        bytes = url.data;
      } else if( url.startsWith("http") ) {
        var response = await http.get(Uri.parse(url));
        bytes = response.bodyBytes;
      } else if( url.startsWith("assets") ) {
        final fileData = await rootBundle.load(url);
        bytes = Uint8List.view(fileData.buffer);
      } else {
        var file = File(url);
        bytes = await file.readAsBytes();
      }
      
      // print(" load image and decode 1: ${DateTime.now().millisecondsSinceEpoch}............ ");
    
      // var receivePort = ReceivePort();
      // await Isolate.spawn(decodeIsolate, DecodeParam(bytes, receivePort.sendPort));
      // image = await receivePort.first as Image?;

      image = await compute( imageProcess2, DecodeParam(bytes!, flipY, null) );
      // image = imageProcess2( DecodeParam(bytes!, flipY, null) );

      // if(image != null) {
      //   var _pixels = image.getBytes(format: Format.rgb);
      //   imageElement = ImageElement(url: url, data: Uint8Array.from(_pixels) , width: image.width, height: image.height);
      // }

 
      
    } else {

      // print(" imageDecoder is not null..... ");

      image = await imageDecoder(null, url);
      // if(image != null) {
      //   imageElement = ImageElement(url: url, data: image.pixels, width: image.width, height: image.height);
      // }
      
    }
  
    return image;
  }

}


class DecodeParam {
  Uint8List bytes;
  bool flipY;
  SendPort? sendPort;
  DecodeParam(this.bytes, this.flipY, this.sendPort);
}

void decodeIsolate(DecodeParam param) {

  if(param.bytes == null) {
    param.sendPort?.send(null);
    return;
  }


  // Read an image from file (webp in this case).
  // decodeImage will identify the format of the image and use the appropriate
  // decoder.
  var image2 = imageProcess2(param);

  
  param.sendPort?.send(image2);
}

Image imageProcess2(DecodeParam param) {
  var image = decodeImage(param.bytes)!;

  if(param.flipY) {
    image = flipVertical(image);
  }

  return image;
}