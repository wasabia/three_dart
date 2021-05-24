

part of three_materials;




class GroupMaterial extends Material {
  
  String type = "GroupMaterial";
  List<Material>? children;

  GroupMaterial() : super() {
  }

}
