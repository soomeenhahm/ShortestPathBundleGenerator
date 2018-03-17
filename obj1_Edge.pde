class Edge {
  Vertex a;
  Vertex b;
  Vec3D c; //center
  int id;
  int cPath=0;
  ArrayList <Edge_child> cPathBundles= new ArrayList <Edge_child>();
  float restLength;
  String stfids= ""; //temporal list storing face lists (all faces which includes this edge)
  int[] fids;

  Edge(Vertex _a, Vertex _b, int _id) {
    a= _a;
    b= _b;
    c= a.v.interpolateTo(b.v, 0.5);
    id= _id;
    restLength= a.v.distanceTo(b.v) * scRLscale;
  }

  //Creation==============================================================================
  //======================================================================================

  //Initiation============================================================================
  //======================================================================================
  void initiate() {
    int[] fidsT= int(split(stfids, ';'));
    fids= new int[fidsT.length-1];
    for (int i=0; i<fidsT.length-1; i++) {
      fids[i]= fidsT[i];
    }
  }

  //Setup=================================================================================
  //======================================================================================

  //Update================================================================================
  //======================================================================================
  void increaseCPath() {
    cPath++;
    for (int i=0; i< nBundleCount; i++) {
      Vec3D vRan= new Vec3D(random(-1, 1), random(-1, 1), random(-1, 1));
      float tvalue= scBundleThick * random(cPath-scBundleThick, cPath);
      vRan.scaleSelf(min(tvalue, cPathMax));
      Edge_child et= new Edge_child (a, b, vRan);
      cPathBundles.add(et);
    }
    //update cPath to their adjacent faces:
    for (int i=0; i<fids.length; i++) {
      Face f= (Face) allFaces.get(fids[i]);
      f.increaseCPathSum();
    }
  }

  void updateRestLength() {
    restLength= a.v.distanceTo(b.v) * scRLscale;
    lockPathes();
  }

  void lockPathes() {
    if (cPath > 2) {
      a.lock= true; 
      b.lock= true;
    }
  }

  void updateSpring() { //sqr(deform) x strength / sqr(dist)= the further the weaker
    //Code Referenced from: Toxiclibs AttractorBehaviour: toxiclibs.org
    //lockPathes();

    float EPS = 1e-6f;
    Vec3D delta= b.v.sub(a.v);

    float AinvWeight= 1;
    float BinvWeight= 1;

    //float strength= map(cPath, 0, cPathMax, 1, 0.01);
    float strength= 1;
    
    float dist = delta.magnitude() + EPS;
    float normDistStrength = (dist - restLength) / (dist * (AinvWeight+ BinvWeight)) * strength;

    if (a.lock != true) {
      a.v.addSelf(delta.scale(normDistStrength * AinvWeight));
    }  
    if (b.lock != true) {
      b.v.addSelf(delta.invert().scale(normDistStrength * BinvWeight));
    }
  }

  //Draw==================================================================================
  //======================================================================================
  void display() {
    stroke(50);
    strokeWeight(0);
    int style= 3;
    switch(style) { //1- uniformed thickness; 2- draw those with thicknesses; 3- draw random bundles
    case 0:
      strokeWeight(cPath);
      break;
    case 1:
      if (cPath>0) {
        strokeWeight(2);
      } else strokeWeight(0);
      break;
    case 2:
      if (cPath>0) {
        strokeWeight(1+cPath);
      } else strokeWeight(0);
      break;
    case 3:
      drawBundles();
      break;
    }
  }

  void drawPipe() {
    float radius= 5;
    Vec3D vt= new Vec3D (0, 1, 0);
    Vec3D vt1= getRotateVec(vt, 60, radius);
    Vec3D vt2= getRotateVec(vt, 120, radius);
    Vec3D vt3= getRotateVec(vt, 180, radius);
    Vec3D vt4= getRotateVec(vt, 240, radius);
    Vec3D vt5= getRotateVec(vt, 300, radius);

    Vec3D vr0= getAddedVec(a.v, vt);
    Vec3D vr1= getAddedVec(a.v, vt1);
    Vec3D vr2= getAddedVec(a.v, vt2);
    Vec3D vr3= getAddedVec(a.v, vt3);
    Vec3D vr4= getAddedVec(a.v, vt4);
    Vec3D vr5= getAddedVec(a.v, vt5);
    Vec3D vr6= getAddedVec(b.v, vt);
    Vec3D vr7= getAddedVec(b.v, vt1);
    Vec3D vr8= getAddedVec(b.v, vt2);
    Vec3D vr9= getAddedVec(b.v, vt3);
    Vec3D vr10= getAddedVec(b.v, vt4);
    Vec3D vr11= getAddedVec(b.v, vt5);

    stroke(50);
    strokeWeight(1);
    fill(155, 50);
    displayRec(vr0, vr1, vr7, vr6);
    displayRec(vr1, vr2, vr8, vr7);
    displayRec(vr2, vr3, vr9, vr8);
    displayRec(vr3, vr4, vr10, vr9);
    displayRec(vr4, vr5, vr11, vr10);
    displayRec(vr5, vr0, vr6, vr11);
  }

  void displayRec(Vec3D v1, Vec3D v2, Vec3D v3, Vec3D v4) {
    beginShape();
    vertex(v1.x, v1.y, v1.z);  
    vertex(v2.x, v2.y, v2.z); 
    vertex(v3.x, v3.y, v3.z); 
    vertex(v4.x, v4.y, v4.z); 
    endShape(CLOSE);
  }

  Vec3D getAddedVec(Vec3D a, Vec3D b) {
    Vec3D c= a.copy();
    c.addSelf(b);
    return c;
  }

  Vec3D getRotateVec(Vec3D v, float degree, float radius) {
    Vec3D vt;
    vt= v.copy();
    vt= vt.rotateZ(radians(degree));
    vt.scaleSelf(radius);
    return vt;
  }

  void drawBundles() {
    if (cPathBundles.size()>0) {
      for (Edge_child et : cPathBundles) {
        et.drawline();
      }
    }
  }

  //======================================================================================
}