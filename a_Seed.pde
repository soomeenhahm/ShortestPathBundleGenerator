class Seed {
  Vertex v;

  Seed(Vertex _v) {
    v=_v;
  }
  
  void display(){
   stroke(tronLightBlue,50);
   strokeWeight(10);
   point(v.v.x, v.v.y, v.v.z);
  }
  
    
  void displayG(){
   stroke(tronOrange,50);
   strokeWeight(10);
   point(v.v.x, v.v.y, v.v.z);
  }
  
}