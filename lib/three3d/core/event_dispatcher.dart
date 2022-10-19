/// https://github.com/mrdoob/eventdispatcher.js/

class Event {
  late String? type;
  late dynamic target;
  late dynamic attachment;
  late dynamic action;
  late dynamic direction;
  String? mode;

  Event(Map<String, dynamic> json) {
    type = json["type"];
    target = json["target"];
    attachment = json["attachment"];
    action = json["action"];
    direction = json["direction"];
    mode = json["mode"];
  }
}

mixin EventDispatcher {
  Map<String, List<Function>>? _listeners = {};

  void addEventListener(String type, Function listener) {
    _listeners ??= {};

    Map<String, List<Function>> listeners = _listeners!;

    if (listeners[type] == null) {
      listeners[type] = [];
    }

    if (!listeners[type]!.contains(listener)) {
      listeners[type]!.add(listener);
    }
  }

  bool hasEventListener(String type, Function listener) {
    if (_listeners == null) return false;

    var listeners = _listeners!;

    return listeners[type] != null && listeners[type]!.contains(listener);
  }

  void removeEventListener(String type, Function listener) {
    if (_listeners == null) return;

    var listeners = _listeners!;
    var listenerArray = listeners[type];

    if (listenerArray != null) {
      var index = listenerArray.indexOf(listener);

      if (index != -1) {
        listenerArray.removeRange(index, index + 1);
      }
    }
  }

  void dispatchEvent(Event event) {
    if (_listeners == null || _listeners!.isEmpty) return;

    var listeners = _listeners!;
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

      event.target = null;
    }
  }

  void clearListeners() {
    _listeners?.clear();
  }
}
