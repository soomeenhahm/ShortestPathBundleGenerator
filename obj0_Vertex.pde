class Vertex {
  Vec3D v;
  int id;
  int[] cids; //connection ids
  int[] cids_e; //connection ids edge id
  Vec3D targetDir; //the rainflow direction to test
  int tID; //rainflow target id
  float tA; //rainflow target angle
  int tID_e; //rainflow target id edge
  boolean blIsSeed= false;
  boolean lock= false;
  
  //dijkstra:
  float fdist=999999; //final distance
  int pid= 999999; //previous node id
  boolean blsettle= false;

  Vertex(Vec3D _v, int _id) {
    v= _v;
    id= _id;

    targetDir= new Vec3D (1, 0, 0);
  }

  Vertex() {
  }

  //Creation==============================================================================
  //======================================================================================

  //Initiation============================================================================
  //======================================================================================
  void initiate() {
    initiateConnection();
    getTargetVertex(targetDir); //the connection id if rainflow direction
  }

  void initiateConnection() {
    //collect all edge connections
    String st= "";
    String st_e= "";
    for (int i=0; i<allEdges.size(); i++) {
      Edge e= (Edge) allEdges.get(i);
      if (id==e.a.id) {
        st= st + e.b.id + ";";
        st_e= st_e + e.id + ";";
      } else if (id==e.b.id) {
        st= st + e.a.id + ";";
        st_e= st_e + e.id + ";";
      }
    }

    //store in a index list
    int[] cidsT= int(split(st, ';'));
    cids= new int[cidsT.length-1];

    int[] cids_eT= int(split(st_e, ';'));
    cids_e= new int[cids_eT.length-1];
    for (int i=0; i<cidsT.length-1; i++) {
      cids[i]= cidsT[i];
      cids_e[i]= cids_eT[i];
    }
  }

  int getTargetVertexID(Vec3D tDir) { //target direction
    float angleMin=999999;
    int idMin=0;
    for (int i=0; i< cids.length; i++) {
      Vertex vn= (Vertex) allVertices.get(cids[i]); //neighbour vertex
      Vec3D vnDir= vn.v.sub(v); //neighbour vertex direction
      float angle= tDir.angleBetween(vnDir, true);
      if (angle < angleMin) {
        angleMin= angle;
        idMin= cids[i];
      }
    }
    return idMin;
  }

  void getTargetVertex(Vec3D tDir) { //target direction
    float angleMin=999999;
    int idMin=0;
    int idMin_e= 0;
    for (int i=0; i< cids.length; i++) {
      Vertex vn= (Vertex) allVertices.get(cids[i]); //neighbour vertex
      Vec3D vnDir= vn.v.sub(v); //neighbour vertex direction

      float angle= tDir.angleBetween(vnDir, true);

      if (angle < angleMin) {
        angleMin= angle;
        idMin= cids[i];
        idMin_e= cids_e[i];
      }
    }

    tA= angleMin;
    tID= idMin;
    tID_e= idMin_e;
  }

  //Setup=================================================================================
  //======================================================================================

  //Update================================================================================
  //======================================================================================

  //Draw==================================================================================
  //======================================================================================
  void display() {
    stroke(255, 0, 0); 
    strokeWeight(4);
    point(v.x, v.y, v.z);

    if (pid != 999999) {
      stroke(255, 366, 0); 
      strokeWeight(4);
      Vertex vpre= (Vertex) allVertices.get(pid);
      line(v.x, v.y, v.z, vpre.v.x, vpre.v.y, vpre.v.z);
    }
  }

  void displayRainflowDir_vector() {
    stroke(0); 
    strokeWeight(2);
    Vertex vnT= (Vertex) allVertices.get(tID);
    Vec3D vnDir= vnT.v.sub(v);
    Vec3D vT= v.add(vnDir.normalizeTo(10));
    line(v.x, v.y, v.z, vT.x, vT.y, vT.z);
  }

  void displayRainflowDir() {
    stroke(0); 
    strokeWeight(2);
    Vertex vnT= (Vertex) allVertices.get(tID);
    line(v.x, v.y, v.z, vnT.v.x, vnT.v.y, vnT.v.z);
  }

  void displayTargetDir() {
    stroke(255, 0, 0); 
    strokeWeight(1);
    Vec3D vt= v.add(targetDir.scale(10));
    line(v.x, v.y, v.z, vt.x, vt.y, vt.z);
  }

  //======================================================================================
}