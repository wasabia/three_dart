class Event {

  String pointerType = "pen";
  int button = 0;

  List<Touch> touches = [];
  
  num? clientX;
  num? clientY;

  num? deltaX;
  num? deltaY;

  EventPage? page;

  Event() {

  }

  factory Event.fromJSON(Map<String, dynamic> json) {
    var _e = Event();
    var _touchesJSON = json["touches"];

    List<Touch> _touches = [];
    for(var _touch in _touchesJSON) {
      _touches.add( Touch.fromJSON(_touch) );
    }
    _e.touches = _touches;

    _e.clientX = json["clientX"];
    _e.clientY = json["clientY"];

    _e.deltaX = json["deltaX"];
    _e.deltaY = json["deltaY"];

    if(json["page"] != null) {
      _e.page = EventPage.fromJSON(json["page"]);
    }


    return _e;
  }

}

class EventPage {
  num? x;
  num? y;
  EventPage(){ }
  factory EventPage.fromJSON(Map<String, dynamic> json) {
    var _ep = EventPage();
    _ep.x = json["x"];
    _ep.y = json["y"];
   
    return _ep;
  }
}

class Touch {
  num? pageX;
  num? pageY;

  num? clientX;
  num? clientY;



  Touch() {}

  factory Touch.fromJSON(Map<String, dynamic> json) {
    var _touch = Touch();
    _touch.pageX = json["pageX"];
    _touch.pageY = json["pageY"];

    _touch.clientX = json["clientX"];
    _touch.clientY = json["clientY"];
   
    return _touch;
  }

}