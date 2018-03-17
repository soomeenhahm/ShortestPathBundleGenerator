class Voxel {
  Vec3D loc;

  Voxel(Vec3D _loc) {
    loc= _loc;
  }

  void display() {
    stroke(155);
    strokeWeight(1);
    point(loc.x, loc.y, loc.z);
  }
}