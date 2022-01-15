class Blob {
  dynamic data;
  late Map<String, dynamic> options;

  Blob(data, options) {
    this.data = data;
    this.options = options;
  }
}

createObjectURL(blob) {
  return blob;
}
