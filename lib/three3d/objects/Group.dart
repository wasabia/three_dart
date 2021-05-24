part of three_objects;


class Group extends Object3D {

	String type = 'Group';
  bool isGroup = true;

  Group(): super() {

  }

  Group.fromJSON(Map<String, dynamic> json, Map<String, dynamic> rootJSON) : super.fromJSON(json, rootJSON) {
   
  }

}
