/// Fake Blob for fit web code when in App & Desktop
///
/// TODO
class Blob {
  dynamic data;
  late Map<String, dynamic> options;

  Blob(data, options) {
    this.data = data;
    this.options = options;
  }
}

/// TODO
createObjectURL(blob) {
  return blob;
}
