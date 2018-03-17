class Face {
  Vec3D pos= new Vec3D();
  Vec3D faceNormal= new Vec3D();
  Vec3D faceNormal2= new Vec3D();
  ArrayList vertexPoints= new ArrayList(); //temporal list
  int[] vids; //vertex index array
  int[] eids; //edge ids
  int cPathSum=0;
  int cPathAv=0; //average
  ArrayList myDupFaceList= new ArrayList();
  int id;
  int[] mcids= {9999999, 9999999};

  Face(ArrayList _vertexPoints, int _id) {
    vertexPoints= _vertexPoints; 
    id= _id;
    ConvertVListToVIDs();
    Initialize();
  }

  //Creation==============================================================================
  //======================================================================================
  void ConvertVListToVIDs() {
    vids= new int[vertexPoints.size()];
    for (int i=0; i<vertexPoints.size(); i++) {
      Vertex v= (Vertex) vertexPoints.get(i);
      vids[i]= v.id;
    }
  }

  void Initialize() {
    CalculateCentroid();
    CalculateNormal();
  }

  void CalculateCentroid() {
    int count=0;
    for (int i=0; i<vids.length; i++) {
      Vertex v= (Vertex) allVertices.get(vids[i]);
      pos.addSelf(v.v);
      count++;
    }
    pos.scaleSelf(1/float(count));
  }

  void CalculateNormal() {
    //Temporal, using 3 vertices only ============
    Vertex a= (Vertex) allVertices.get(vids[0]);
    Vertex b= (Vertex) allVertices.get(vids[1]);
    Vertex c= (Vertex) allVertices.get(vids[2]);

    Vec3D v1 = b.v.sub(a.v);
    Vec3D v2 = c.v.sub(a.v);
    faceNormal = v1.cross(v2);
    faceNormal.normalize();
    faceNormal.scaleSelf(10); 
    faceNormal2 = pos.sub(c.v); 
    faceNormal2.normalize();
    faceNormal2.scaleSelf(10);
    //============================================
  }

  //Initiation============================================================================
  //======================================================================================
  void initiate() {
    int idSize= vids.length;
    eids= new int[idSize];

    int vtid, vtidn;
    Vertex v;
    Edge e;
    for (int i=0; i< idSize-1; i++) {
      vtid=  vids[i];
      vtidn= vids[i+1];
      v= (Vertex) allVertices.get(vtid);
      eids[i]= v.cids_e[indexOfIds(v.cids, vtidn)];

      e= (Edge) allEdges.get(eids[i]);
      e.stfids= e.stfids + id + ";" ;
    }

    vtid=  vids[idSize-1];
    vtidn= vids[0];
    v= (Vertex) allVertices.get(vtid);
    eids[idSize-1]= v.cids_e[indexOfIds(v.cids, vtidn)];

    e= (Edge) allEdges.get(eids[idSize-1]);
    e.stfids= e.stfids + id + ";" ;
  }

  //Setup=================================================================================
  //======================================================================================

  //Update================================================================================
  //======================================================================================
  void update() {
    display();
    //displayNormal();
  }

  void increaseCPathSum() { //called whenever an edge is updated.
    cPathSum++;   
    cPathAv= int(cPathSum/ eids.length);

    for (int i=0; i<2; i++) {
      if (mcids[i] < allMeshComponents.size()) {
        Mesh m= (Mesh) allMeshComponents.get(mcids[i]);
        m.calculateCPathSum();
      }
    }
  }

  //Draw==================================================================================
  //======================================================================================
  void displaytext() {
    fill(0);
    text(cPathAv, pos.x, pos.y, pos.z);
  }

  int indexOfIds(int[] ids, int id) {
    int index= 0;
    for (int i=0; i<ids.length; i++) {
      if (id == ids[i]) {
        index= i;
      }
    }
    return index;
  }

  void display() { 
    stroke(155); 
    strokeWeight(1);
    //if (blFillFace) fill(220, 100);
    noFill();
    if (blFillFace) {
      if (cPathSum>0) {
        fill(map(cPathSum, 0, 100, 255, 50));
      }
      else{
       noFill(); 
      }
    } 
    beginShape();
    for (int i=0; i<vids.length; i++) {
      Vertex v= (Vertex) allVertices.get(vids[i]);
      vertex(v.v.x, v.v.y, v.v.z);
    }
    endShape(CLOSE);
  }

  void displayNoColor() {
    beginShape();
    for (int i=0; i<vids.length; i++) {
      Vertex v= (Vertex) allVertices.get(vids[i]);
      vertex(v.v.x, v.v.y, v.v.z);
    }
    endShape(CLOSE);
  }

  void displayNormal() {
    Vec3D temp2 = faceNormal.copy();
    temp2.scaleSelf(5); 
    Vec3D temp = pos.add(temp2); 
    stroke(255, 0, 0); 
    strokeWeight(1);
    line(temp.x, temp.y, temp.z, pos.x, pos.y, pos.z);
  }

  //======================================================================================
}