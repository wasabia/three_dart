
class Clock {
  late bool autoStart;
  late num startTime;
  late num oldTime;
  late num elapsedTime;
  late bool running;

  Clock([bool? autoStart]) {
    this.autoStart = (autoStart != null) ? autoStart : true;

    startTime = 0;
    oldTime = 0;
    elapsedTime = 0;

    running = false;
  }

  void start() {
    startTime = now();

    oldTime = startTime;
    elapsedTime = 0;
    running = true;
  }

  void stop() {
    getElapsedTime();
    running = false;
    autoStart = false;
  }

  num getElapsedTime() {
    getDelta();
    return elapsedTime;
  }

  num getDelta() {
    num diff = 0;

    if (autoStart && !running) {
      start();
      return 0;
    }

    if (running) {
      var newTime = now();

      diff = (newTime - oldTime) / 1000;
      oldTime = newTime;

      elapsedTime += diff;
    }

    return diff;
  }
}

int now() {
  return DateTime.now().millisecondsSinceEpoch; // see #10732
}
