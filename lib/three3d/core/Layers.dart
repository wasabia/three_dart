part of three_core;

class Layers {
  int mask = 1 | 0;

  Layers() {}

  set(channel) {
    this.mask = (1 << channel | 0) >> 0 ;
  }

  enable(channel) {
    this.mask = this.mask | (1 << channel | 0);
  }

  enableAll() {
    this.mask = 0xffffffff | 0;
  }

  toggle(channel) {
    this.mask ^= 1 << channel | 0;
  }

  disable(channel) {
    this.mask &= ~(1 << channel | 0);
  }

  disableAll() {
    this.mask = 0;
  }

  bool test(layers) {
    return (this.mask & layers.mask) != 0;
  }
}
