part of three_core;

/**
 * https://github.com/mrdoob/eventdispatcher.js/
 */

class Event {
  late String? type;
  late dynamic? target;
  late dynamic? attachment;
  late dynamic? action;
  late dynamic? direction;

  Event(Map<String, dynamic> json) {
    this.type = json["type"];
    this.target = json["target"];
    this.attachment = json["attachment"];
    this.action = json["action"];
    this.direction = json["direction"];
  }
}

mixin EventDispatcher {
  Map<String, List<Function>> _listeners = {};

  addEventListener(String type, Function listener) {
    if (this._listeners == null) this._listeners = {};

    var listeners = this._listeners;

    if (listeners[type] == null) {
      listeners[type] = [];
    }

    if (listeners[type]!.indexOf(listener) == -1) {
      listeners[type]!.add(listener);
    }
  }

  hasEventListener(String type, Function listener) {
    if (this._listeners == null) return false;

    var listeners = this._listeners;

    return listeners[type] != null && listeners[type]!.indexOf(listener) != -1;
  }

  removeEventListener(String type, Function listener) {
    if (this._listeners == null) return;

    var listeners = this._listeners;
    var listenerArray = listeners[type];

    if (listenerArray != null) {
      var index = listenerArray.indexOf(listener);

      if (index != -1) {
        listenerArray.removeRange(index, index + 1);
      }
    }
  }

  dispatchEvent(Event event) {
    if (this._listeners.keys.length == 0) return;

    var listeners = this._listeners;
    var listenerArray = listeners[event.type];

    // print("dispatchEvent event: ${event.type} ");

    if (listenerArray != null) {
      event.target = this;

      // Make a copy, in case listeners are removed while iterating.
      var array = listenerArray.sublist(0);

      for (var i = 0, l = array.length; i < l; i++) {
        Function _fn = array[i];

        _fn(event);
      }
    }
  }

  clearListeners() {
    _listeners.clear();
  }
}
