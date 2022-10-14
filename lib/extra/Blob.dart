/// Fake Blob for fit web code when in App & Desktop

class Blob {
  dynamic data;
  late Map<String, dynamic> options;

  Blob(this.data, this.options);
}

createObjectURL(blob) {
  return blob;
}
