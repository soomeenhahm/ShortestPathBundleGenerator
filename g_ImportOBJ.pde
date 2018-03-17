void importObj(String meshName) {
  ArrayList allVerticesHasDup= new ArrayList();
  String objStrings[] = loadStrings("input/" + meshName);
  String stpre= "#";
  Mesh m= new Mesh(0);

  for (int i = 0; i<objStrings.length; i++) {
    String[] parts =  split(objStrings[i], ' ');
    if (parts[0].equals("v")) {
      float x1 = float(parts[1]);
      float y1 = float(parts[2]) *(-1);
      float z1 = float(parts[3]);
      Vertex v = new Vertex(new Vec3D(x1, y1, z1), allVertices.size());
      v = testDuplicate(v);
      allVerticesHasDup.add(v);
    }
    if (parts[0].equals("f")) {
      if (stpre.equals("f") != true) {
        m= new Mesh(allMeshComponents.size());
        allMeshComponents.add(m);
      }
      ArrayList vertexPoints = new ArrayList();
      Vertex vpre= new Vertex(new Vec3D(), 0);
      Vertex vfirst= new Vertex(new Vec3D(), 0);
      for (int j=1; j<parts.length; j++) {
        String[] num = split(parts[j], '/');
        int index = int(num[0])-1;
        Vertex v= (Vertex) allVerticesHasDup.get(index);
        vertexPoints.add(v);
        if (j==1) {
          vfirst= v;
        }
        if (j>1) {
          Edge e= new Edge(v, vpre, allEdges.size());
          testDuplicateEdge(e);
          if (j== parts.length-1) {
            Edge e1= new Edge(vfirst, v, allEdges.size());
            testDuplicateEdge(e1);
          }
        }
        vpre= v;
      }
      Face f = new Face(vertexPoints, allFaces.size());
      int intType= 2;
      switch (intType) {
      case 0: //do nothing
        allFaces.add(f);
        m.faces.add(f);
        break;
      case 1: //just find dup and store in an self arraylist, no delete
        findDupFaces(f); 
        m.faces.add(f);
        break;
      case 2: //remain only one from duplication   
        Face fsame= findDupFaceNDelete(f);
        m.faces.add(fsame);
        break;
      case 3: //delete both from duplication
        boolean blDup= findDupFaceNDeleteBoth(f);
        if (blDup == false) {
          m.faces.add(f);
        }
        break;
      }
    }
    println("importing " + (i/float(objStrings.length)) * 100.0 + "%");
    stpre = parts[0];
  }
  println("importing " + 100.0 + "%");
  println("mesh components count = " + allMeshComponents.size());
}

void initiateData() {
  for (int i = 0; i < allVertices.size(); i++) {   //let all vertices store their connected vertices and edges according to the edge connections
    Vertex v = (Vertex) allVertices.get(i);
    v.initiate();
  }
  for (int i = 0; i < allFaces.size(); i++) { //let all faces find and store their adjacent edges from vertex list
    Face f = (Face) allFaces.get(i);
    f.initiate();
  }
  for (int i = 0; i < allEdges.size(); i++) {   //let all edges store their inclusive face list as index array
    Edge e = (Edge) allEdges.get(i);
    e.initiate();
  }
  for (int i = 0; i < allMeshComponents.size(); i++) {   //converts all mesh face lists to face id lists + put mesh into each faces' mComps list
    Mesh mt = (Mesh) allMeshComponents.get(i);
    mt.initializeData();
  }
  for (int i = 0; i < allMeshComponents.size(); i++) {   //let all mesh components store adjacent mesh component list
    Mesh m = (Mesh) allMeshComponents.get(i);
    m.initiate();
  }
}

void sortEdgeList() {
  ArrayList allEdgesT= new ArrayList();
  for (int i = 0; i < allEdges.size(); i++) {
    Edge e = (Edge) allEdges.get(i);
    boolean bldup= false;
    for (int j = 0; j < i; j++) {
      Edge eOther = (Edge) allEdges.get(j);
      if (e.c.distanceTo(eOther.c) < tolerence) {
        bldup= true;
      }
    }
    if (!bldup) {
      allEdgesT.add(e);
    }
  }
  allEdges.clear();
  allEdges.addAll(allEdgesT);
}

void testDuplicateEdge(Edge e) {
  boolean blnSame= false;
  if (allEdges.size()>0) {
    for (int i=0; i< allEdges.size(); i++) {
      Edge eOther= (Edge) allEdges.get (i);
      if (eOther.c.distanceTo(e.c) < tolerence*2) { 
        blnSame= true;
      }
    }
  }
  if (blnSame == false) {
    allEdges.add(e);
  }
}

Vertex testDuplicate(Vertex v) {
  boolean blnSame= false;
  Vertex vSame= v;
  if (allVertices.size()>0) {
    for (int i=0; i< allVertices.size(); i++) {
      Vertex vOther= (Vertex) allVertices.get (i);
      if (vOther.v.distanceTo(v.v) < tolerence) { 
        blnSame= true;
        vSame= vOther;
      }
    }
  }
  if (blnSame == false) {
    allVertices.add(v);
  }
  return vSame;
}

boolean findDupFaceNDeleteBoth(Face f) {
  boolean blDup= false;
  if (allFaces.size()>0) {
    for (int i = 0; i < allFaces.size(); i++) {
      Face fOther = (Face) allFaces.get(i);
      if (f.pos.distanceTo(fOther.pos) < tolerence) {
        allFaces.remove(fOther);
        blDup= true;
      }
    }
  }
  if (blDup== false) {
    allFaces.add(f);
  }
  return blDup;
}

Face findDupFaceNDelete(Face f) {
  Face fsame= f;
  boolean blDup= false;
  if (allFaces.size()>0) {
    for (int i = 0; i < allFaces.size(); i++) {
      Face fOther = (Face) allFaces.get(i);
      if (f.pos.distanceTo(fOther.pos) < tolerence) {
        blDup= true;
        fsame= fOther;
      }
    }
  }
  if (blDup== false) {
    allFaces.add(f);
  }
  return fsame;
}

void findDupFaces(Face f) {
  if (allFaces.size()>0) {
    for (int i = 0; i < allFaces.size(); i++) {
      Face fOther = (Face) allFaces.get(i);
      if (f.pos.distanceTo(fOther.pos) < tolerence) {
        f.myDupFaceList.add(fOther);
      }
    }
  }
  allFaces.add(f);
}

Vertex getClosestVec(Vertex v) {
  Vertex vt= v;
  for (int i=0; i< allVertices.size(); i++) {
    Vertex vOther= (Vertex) allVertices.get (i);
    if (v.v.distanceTo(vOther.v) < tolerence) {
      vt= vOther;
    }
  }
  return vt;
}

void printDupFaces() {
  for (int i = 1; i < allFaces.size(); i++) {
    Face f = (Face) allFaces.get(i);
    if (f.myDupFaceList.size()>0) {
      println(f.myDupFaceList.size());
    }
  }
}