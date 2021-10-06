import 'dart:isolate';
import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_gl/flutter_gl.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart';
import 'package:three_dart/three3d/textures/index.dart';

class ImageLoaderLoader {

  static Future<ImageElement?> loadImage(String url, {Function? imageDecoder}) async {
  
    ImageElement? imageElement;
    if(imageDecoder == null) {
      Uint8List? bytes;
      if(url.startsWith("http")) {
        var response = await http.get(Uri.parse(url));
        bytes = response.bodyBytes;
      } else if(url.startsWith("assets")) {
        final fileData = await rootBundle.load(url);
        bytes = Uint8List.view(fileData.buffer);
      }
      // var file = File(url);
      // bytes = file.readAsBytesSync();
      // print(" load image and decode 1: ${DateTime.now().millisecondsSinceEpoch}............ ");
      var receivePort = ReceivePort();
      await Isolate.spawn(decodeIsolate, DecodeParam(bytes, receivePort.sendPort));
      // Get the processed image from the isolate.
      var image = await receivePort.first as Image?;

      // print(" load image and decode 2: ${DateTime.now().millisecondsSinceEpoch}............ ");
      if(image != null) {
        var _pixels = image.getBytes(format: Format.rgba);
        imageElement = ImageElement(data: Uint8Array.from(_pixels) , width: image.width, height: image.height);
      }
      
    } else {
      var image = await imageDecoder(null, url);
      if(image != null) {
        imageElement = ImageElement(data: Uint8Array.from(image.pixels), width: image.width, height: image.height);
      }
      
    }
  
    return imageElement;
  }

}


class DecodeParam {
  Uint8List? bytes;
  final SendPort sendPort;
  DecodeParam(this.bytes, this.sendPort);
}

void decodeIsolate(DecodeParam param) {

  if(param.bytes == null) {
    param.sendPort.send(null);
    return;
  }

  // Read an image from file (webp in this case).
  // decodeImage will identify the format of the image and use the appropriate
  // decoder.
  var image = decodeImage(param.bytes!)!;
  // Resize the image to a 120x? thumbnail (maintaining the aspect ratio).
  // var thumbnail = copyResize(image, width: 120);
  var image2 = flipVertical(image);
  param.sendPort.send(image2);
}

