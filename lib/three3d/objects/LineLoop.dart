part of three_objects;

class LineLoop extends Line {
  LineLoop(BufferGeometry? geometry, Material? material)
      : super(geometry, material) {
    type = 'LineLoop';
    isLineLoop = true;
  }
}
