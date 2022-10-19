class Layers {
  int mask = 1 | 0;

  Layers();

  void set(int channel) => mask = (1 << channel | 0) >> 0;

  void enable(int channel) => mask = mask | (1 << channel | 0);

  void enableAll() => mask = 0xffffffff | 0;

  void toggle(int channel) => mask ^= 1 << channel | 0;

  void disable(int channel) => mask &= ~(1 << channel | 0);

  void disableAll() => mask = 0;

  bool test(Layers layers) => (mask & layers.mask) != 0;

  bool isEnabled(int channel) => (mask & (1 << channel | 0)) != 0;
}
