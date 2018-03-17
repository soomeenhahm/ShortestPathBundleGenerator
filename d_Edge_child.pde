class Edge_child {
  Vertex a;
  Vertex b;
  Vec3D r;

  Edge_child(Vertex _a, Vertex _b, Vec3D _r) {
    a= _a;
    b= _b;
    r= _r;
  }

  void drawline() {
    Vec3D at= a.v.copy();
    at.addSelf(r);
    Vec3D bt= b.v.copy();
    bt.addSelf(r);
    
    stroke(150,255,155);
    strokeWeight(1);
    line(at.x, at.y, at.z, bt.x, bt.y, bt.z);
  }
  
}