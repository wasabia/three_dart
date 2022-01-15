part of three_webgl;

class WebGLAnimation {
  var context = null;
  var isAnimating = false;
  var animationLoop = null;
  var requestId = null;

  WebGLAnimation() {}

  onAnimationFrame(time, frame) {
    animationLoop(time, frame);

    requestId = context.requestAnimationFrame(onAnimationFrame);
  }

  start() {
    if (isAnimating == true) return;
    if (animationLoop == null) return;

    requestId = context.requestAnimationFrame(onAnimationFrame);

    isAnimating = true;
  }

  stop() {
    context.cancelAnimationFrame(requestId);

    isAnimating = false;
  }

  setAnimationLoop(callback) {
    animationLoop = callback;
  }

  setContext(value) {
    context = value;
  }
}
