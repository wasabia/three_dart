
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';


class EventTouch {
  late int pointer;
  num? pageX;
  num? pageY;

  num? clientX;
  num? clientY;

}

class EventPage {
  num? x;
  num? y;

  EventPage(this.x, this.y) {}


}

class TouchEvent {
  int? button;
  num? pageX;
  num? pageY;
  num? clientX;
  num? clientY;

  EventPage? page;

  num? deltaX;
  num? deltaY;

  String pointerType = "pen";

  List<EventTouch> touches = [];
  List<EventTouch> changedTouches = [];

}


class TouchListener extends StatefulWidget {

  late Widget child;
  Function? touchstart;
  Function? touchmove;
  Function? touchend;
  Function? pointerdown;
  Function? pointermove;
  Function? pointerup;
  Function? wheel;

  TouchListener({
    Key? key, 
    required this.child,
    this.touchstart,
    this.touchmove,
    this.touchend,
    this.pointerdown,
    this.pointermove,
    this.pointerup,
    this.wheel
  }) : super(key: key);

  @override
  TouchListenerState createState() => TouchListenerState();
}

class TouchListenerState extends State<TouchListener> {
  
  late TouchEvent touchEvent;

  bool moved = false;

  @override
  void initState() {
    super.initState();

    touchEvent = TouchEvent();
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (PointerDownEvent event) {
        RenderBox getBox = context.findRenderObject() as RenderBox;
        var local = getBox.globalToLocal(event.position);

        var _touch = EventTouch();
        _touch.pointer = event.pointer;
        _touch.pageX = event.position.dx;
        _touch.pageY = event.position.dy;



        _touch.clientX = local.dx;
        _touch.clientY = local.dy;

        touchEvent.touches.add( _touch );
        touchEvent.changedTouches = [_touch];

        touchEvent.clientX = local.dx;
        touchEvent.clientY = local.dy;

        touchEvent.pageX = event.position.dx;
        touchEvent.pageY = event.position.dy;

        touchEvent.button = event.buttons;

        touchEvent.page = EventPage(touchEvent.pageX, touchEvent.pageY);

        // print("onPointerDown ${_touch.clientX} ${_touch.clientY}  ");

        if(widget.touchstart != null) widget.touchstart!(touchEvent);
        if(widget.pointerdown != null) widget.pointerdown!(touchEvent);
      },
      onPointerMove: (PointerMoveEvent event) {
        RenderBox getBox = context.findRenderObject() as RenderBox;
        var local = getBox.globalToLocal(event.position);
        
        var _touches = touchEvent.touches.where((t) => t.pointer == event.pointer).toList();
        if(_touches == null || _touches.length == 0) {
          return;
        }
        var _touch = _touches[0];
        _touch.pageX = event.position.dx;
        _touch.pageY = event.position.dy;
        _touch.clientX = local.dx;
        _touch.clientY = local.dy;

        // print("onPointerMove ${_touch.clientX} ${_touch.clientY}  ");

        touchEvent.deltaX = event.delta.dx;
        touchEvent.deltaY = event.delta.dy;

        touchEvent.clientX = local.dx;
        touchEvent.clientY = local.dy;

        touchEvent.pageX = event.position.dx;
        touchEvent.pageY = event.position.dy;

        touchEvent.page = EventPage(touchEvent.pageX, touchEvent.pageY);

        touchEvent.button = event.buttons;

        if(widget.touchmove != null) widget.touchmove!(touchEvent);
        if(widget.pointermove != null) widget.pointermove!(touchEvent);
      },
      onPointerUp: (PointerUpEvent event) {
        var _touch = touchEvent.touches.firstWhere((t) => t.pointer == event.pointer);
        touchEvent.touches.remove(_touch);
        

        RenderBox getBox = context.findRenderObject() as RenderBox;
        var local = getBox.globalToLocal(event.position);
        _touch.pageX = event.position.dx;
        _touch.pageY = event.position.dy;
        _touch.clientX = local.dx;
        _touch.clientY = local.dy;
        touchEvent.changedTouches = [_touch];

        touchEvent.clientX = local.dx;
        touchEvent.clientY = local.dy;

        touchEvent.pageX = event.position.dx;
        touchEvent.pageY = event.position.dy;

        touchEvent.page = EventPage(touchEvent.pageX, touchEvent.pageY);

        // print("onPointerUp ${_touch.clientX} ${_touch.clientY}  ");
        touchEvent.button = event.buttons;
     
        if(widget.touchend != null) widget.touchend!(touchEvent);
        if(widget.pointerup != null) widget.pointerup!(touchEvent);
      },
      onPointerSignal: (pointerSignal) {
        if(pointerSignal is PointerScrollEvent){
          // do something when scrolled

          var event = pointerSignal;
          
          var _touch = EventTouch();
          _touch.pointer = event.pointer;
          _touch.pageX = event.position.dx;
          _touch.pageY = event.position.dy;

          touchEvent.deltaX = event.delta.dx;
          touchEvent.deltaY = event.delta.dy;

          touchEvent.touches.add( _touch );

          // print("onPointerUp ${_touch.clientX} ${_touch.clientY}  ");
          touchEvent.button = event.buttons;
         
          if(widget.wheel != null) widget.wheel!(touchEvent);
        }
      },
      onPointerCancel: (PointerCancelEvent event) {
        print(" onPointerCancel event: ${event.pointer} ");
      },
      child: widget.child,
    );
  }

}

