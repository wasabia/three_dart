part of three_materials;

class GroupMaterial extends Material {
  List<Material>? children;

  GroupMaterial() : super() {
    type = "GroupMaterial";
  }
}
