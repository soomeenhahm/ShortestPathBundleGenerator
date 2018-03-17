
import java.util.Calendar;

String timestamp() {
  return String.format("%1$ty%1$tm%1$td_%1$tH%1$tM%1$tS", Calendar.getInstance());
}


void exportMesh() { 
  String filename= "MeshOrg";
  PrintWriter output;
  output = createWriter("output_" + stTime + "/" + filename+ ".obj");

  for (int i=0; i< allVertices.size (); i++) {
    Vertex v= (Vertex) allVertices.get (i);
    String st= "v " + v.v.x + " " + v.v.y + " " + v.v.z;
    output.println(st);
  }
  output.println();
  for (int i=0; i<allFaces.size (); i++) {
    Face f= (Face) allFaces.get(i);
    String st= "f ";
    for (int j=0; j<f.vids.length; j++) {
      int id= f.vids[j] +1;
      st= st + id + " ";
    }
    output.println(st);
  }

  output.flush();
  output.close();

  println("mesh_org faces have been exported");
}

void exportMeshComponents() { 
  String foldername= "output_" + stTime + "/";
  saveFrame (foldername + "image.jpg");

  exportComponent(foldername, "A");
  exportComponent(foldername, "B");
  exportComponent(foldername, "C");
  exportComponent(foldername, "D");

  println("mesh_components in 3 types have been exported");
}

void exportComponent(String foldername, String stType) {
  PrintWriter output = createWriter(foldername + "MeshComponents_" + stType + ".obj");

  int vc=1; //vertex count inside this component
  for (int i = 0; i < allMeshComponents.size(); i++) {
    Mesh m = (Mesh) allMeshComponents.get(i);

    if (m.type == stType) {

      for (int j=0; j < m.fids.length; j++) {
        Face f= (Face) allFaces.get(m.fids[j]);
        for (int k=0; k< f.vids.length; k++) {
          Vertex v= (Vertex) allVertices.get(f.vids[k]);
          String st= "v " + v.v.x + " " + v.v.y + " " + v.v.z;
          output.println(st);
        }
      }

      output.println("g component" + i);
      for (int j=0; j < m.fids.length; j++) {
        Face f= (Face) allFaces.get(m.fids[j]);
        String st= "f ";
        for (int k=0; k< f.vids.length; k++) {
          st= st + vc + " ";
          vc++;
        }
        output.println(st);
      }
    }
  }

  output.flush();
  output.close();
}

void exportMeshComponentsAll() { 
  String filename= "MeshComponents";
  PrintWriter output;
  output = createWriter("output_" + stTime + "/" + filename+ ".obj");
  int vc=1; //vertex count inside this component

  for (int i = 0; i < allMeshComponents.size(); i++) {
    Mesh m = (Mesh) allMeshComponents.get(i);
    if (m.blon == true) {
      for (int j=0; j < m.fids.length; j++) {
        Face f= (Face) allFaces.get(m.fids[j]);
        for (int k=0; k< f.vids.length; k++) {
          Vertex v= (Vertex) allVertices.get(f.vids[k]);
          String st= "v " + v.v.x + " " + v.v.y + " " + v.v.z;
          output.println(st);
        }
      }

      output.println("g component" + i);
      for (int j=0; j < m.fids.length; j++) {
        Face f= (Face) allFaces.get(m.fids[j]);
        String st= "f ";
        for (int k=0; k< f.vids.length; k++) {
          st= st + vc + " ";
          vc++;
        }
        output.println(st);
      }
    }
  }

  output.flush();
  output.close();

  println("mesh_components have been exported");
}



void exportTrail() {
  String filename= "AgentTrail";
  PrintWriter output;
  output = createWriter("output_" + stTime + "/" + filename+ ".txt"); 

  for (int i = 0; i < allAgents.size(); i++) {
    Agent a = (Agent) allAgents.get(i);
    String st= "";

    for (int j=0; j<a.trail.size (); j++) {
      Vec3D v= (Vec3D) a.trail.get(j);

      st= st+ v.x + "," + v.y + "," + v.z + ";";
    }

    output.println(st);
  }

  output.flush();
  output.close();
  println("trail have been exported");
}


void exportEdges() {
  String filename= "Edges";
  PrintWriter output;
  output = createWriter("output/" + timestamp() + "_" + filename+ ".txt");

  for (int i = 0; i < allEdges.size(); i++) {
    Edge e = (Edge) allEdges.get(i);
    String st= e.a.v.x + "," + e.a.v.y + "," + e.a.v.z + "," + e.b.v.x + "," + e.b.v.y + "," + e.b.v.z + "," + e.cPath;
    output.println(st);
  }

  output.flush();
  output.close();
  println("edges have been exported");
}

void exportChildEdges() {
  String filename= "ChildEdges"; 
  PrintWriter output;
  output = createWriter("output/" + timestamp() + "_" + filename+ ".txt");

  for (int i = 0; i < allEdges.size(); i++) {
    Edge e = (Edge) allEdges.get(i);
    for (Edge_child et : e.cPathBundles) {
      Vec3D at= et.a.v.copy();
      at.addSelf(et.r);
      Vec3D bt= et.b.v.copy();
      bt.addSelf(et.r);

      String st= at.x + "," + at.y + "," + at.z + "," + bt.x + "," + bt.y + "," + bt.z;
      output.println(st);
    }
  }

  output.flush();
  output.close();
  println("child edges have been exported");
}

void exportDXF() {
  //if (blrecordDXF == true) {
  println("Record DXF started.");
  beginRaw(DXF, "output_" +stTime + "/" + "Edges.dxf"); // Start recording to the file
  blFillFace= false;
  drawFaces();
  endRaw();
  beginRaw(DXF, "output_" +stTime + "/" + "Bundles.dxf"); 
  drawEdges();
  endRaw();
  beginRaw(DXF, "output_" +stTime + "/" + "AgentPathes.dxf");
  drawAgents();
  endRaw();
  saveFrame ("output_" +stTime + "/" + "Capture.png");
  beginRaw(DXF, "output_" +stTime + "/" + "Pipes.dxf");
  drawEdgePipes();
  endRaw();
  beginRaw(DXF, "output_" +stTime + "/" + "Box.dxf"); 
  drawBox();
  endRaw();
  beginRaw(DXF, "output_" +stTime + "/" + "Faces.dxf"); // Start recording to the file
  background(255);
  blFillFace= true;
  drawFaces();
  blFillFace= false;
  endRaw();
  blrecordDXF = false; // Stop recording to the file
  blDisplayBox= false;
  blFillFace= false;
  exportTrail();
  exportMesh();
  println("Record DXF finished.");
  //}
}