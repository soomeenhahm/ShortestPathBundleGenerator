class Attractor {
  Vec3D loc;
  float attRadius;
  float attStrength;

  Attractor(Vec3D _loc, float _attRadius, float _attStrength) {
    loc= _loc;
    attRadius= _attRadius;
    attStrength= _attStrength;
  }


  void display() {
    if (attStrength<0) {
      stroke(tronPurple, map(abs(attStrength), 0, 2, 10, 150));
    }
    else{
      stroke(tronOrange, map(abs(attStrength), 0, 2, 10, 150));
    }
    strokeWeight(map(attRadius, 0, 1000, 2, 30));
    point(loc.x, loc.y, loc.z);
  }


  void updateAttractor() {

    for (int i= 0; i< allVertices.size(); i++) {
      Vertex v= (Vertex) allVertices.get(i);

      applyAttractionBehaviour(v, loc, attRadius, attStrength, 0, 0.3);
    }
  }

  void applyAttractionBehaviour(Vertex v, Vec3D attractor, float attRadius, float attrStrength, float jitter, float force) {
    //Code Referenced from: Toxiclibs AttractorBehaviour: toxiclibs.org
    if (v.lock == false) {
      float radiusSquared= attRadius * attRadius;
      Vec3D delta = attractor.sub(v.v);

      float dist = delta.magSquared();
      if (dist < radiusSquared) {
        Vec3D f = delta.normalizeTo((1.0f - dist / radiusSquared)).jitter(jitter).scaleSelf(attrStrength);
        //p.addForce(f);
        v.v.addSelf(f.scale(force));
      }
    }
  }
}