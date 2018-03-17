import toxi.geom.*;
import toxi.geom.mesh.*;
import peasy.*;
import toxi.processing.*;
import processing.dxf.*;
import plethora.core.*;
import processing.dxf.*;


PeasyCam cam;

ArrayList allVertices= new ArrayList();
ArrayList allFaces= new ArrayList();
ArrayList allEdges= new ArrayList();
ArrayList allAgents= new ArrayList();
ArrayList allSeeds= new ArrayList();
ArrayList allGSeeds= new ArrayList();
ArrayList allVoxels= new ArrayList();
ArrayList allAtts= new ArrayList();
ArrayList allMeshComponents= new ArrayList();

float tolerence= 0.5; //test duplicate vertices

boolean blFillFace= false;
boolean blDisplayFace= true;
boolean blDisplayEdge= true;
boolean blDisplayVert= false;
boolean blUpdateAgents= false;
boolean blDisplayAgent= true;
boolean blSnap= false;
boolean blDisplayGoal= false;
boolean blDisplayVoxel= false;
boolean blDisplayAgentPts= true;
boolean blDisplayBox= false;
boolean blDisplayAtt= false;
boolean blDisplaySeed= false;
boolean blDisplayMeshComp= true;

boolean blrecordDXF = false;
boolean blUpdateSpring= false;
boolean blUpdateSpringRL= false;
boolean blUpdateAtt= false;
boolean blDisplayPipe= false;
boolean blGrow= false;

color tronBlue;
color tronDarkBlue;
color tronOrange;
color tronGreen;
color tronLightBlue;
color tronMidBlue;
color tronPurple;

String stTime;

//Functions ==================================================================================

void drawTestConnection(int id) {
  Vertex v = (Vertex) allVertices.get(id);
  for (int i=0; i<v.cids.length; i++) {
    stroke(0, 0, 255); 
    strokeWeight(2);
    Vertex vOther = (Vertex) allVertices.get(v.cids[i]);
    line(v.v.x, v.v.y, v.v.z, vOther.v.x, vOther.v.y, vOther.v.z);
  }

  stroke(0, 100, 255); 
  strokeWeight(10);
  point(v.v.x, v.v.y, v.v.z);
}


void drawVertices() {
  for (int i = 0; i < allVertices.size(); i++) {
    Vertex v = (Vertex) allVertices.get(i);
    v.display();
  }
}

void drawEdges() {
  for (int i = 0; i < allEdges.size(); i++) {
    Edge e = (Edge) allEdges.get(i);
    e.display();
  }
}

void drawEdgePipes() {
  for (int i = 0; i < allEdges.size(); i++) {
    Edge e = (Edge) allEdges.get(i);
    e.drawPipe();
  }
}

void drawFaces() {
  for (int i = 0; i < allFaces.size(); i++) {
    Face f = (Face) allFaces.get(i);
    f.display();
  }
}

void drawSeeds() {
  for (int i=0; i< allSeeds.size(); i++) {
    Seed s= (Seed) allSeeds.get(i);
    s.display();
  }

  for (int i=0; i< allGSeeds.size(); i++) {
    Seed s= (Seed) allGSeeds.get(i);
    if (blDisplaySeed)s.displayG();
  }
}

void drawVoxels() {
  for (int i = 0; i < allVoxels.size(); i++) {
    Voxel vx = (Voxel) allVoxels.get(i);
    vx.display();
  }
}

void drawAgents() {
  for (int i = 0; i < allAgents.size(); i++) {
    Agent a = (Agent) allAgents.get(i);
    a.display();
  }
}

void drawAtts() {
  for (int i = 0; i < allAtts.size(); i++) {
    Attractor att = (Attractor) allAtts.get(i);
    att.display();
  }
}

void drawMeshComponents() {
  for (int j=0; j<allMeshComponents.size(); j++) {
    Mesh m= (Mesh) allMeshComponents.get(j);
    m.display();
  }
}

void updateAtts() {
  for (int i = 0; i < allAtts.size(); i++) {
    Attractor att = (Attractor) allAtts.get(i);
    att.updateAttractor();
  }
}

void updateAgents() {
  for (int i = 0; i < allAgents.size(); i++) {
    Agent a = (Agent) allAgents.get(i);
    a.run();
  }
}

void retouchAgents() {
  for (int i = 0; i < allAgents.size(); i++) {
    Agent a = (Agent) allAgents.get(i);
    a.snapToGrid_retouch(50);
  }
}

void gotoGoalAgents() {
  for (int i = 0; i < allAgents.size(); i++) {
    Agent a = (Agent) allAgents.get(i);
    a.trail.add(a.loc);
    a.loc = a.goalSeed.v.v;
    a.trail.add(a.loc);
  }
}

void findShortestPathAgents() {
  for (int i = 0; i < allAgents.size(); i++) {
    Agent a = (Agent) allAgents.get(i);
    a.dijkstra();
  }
}

void findLongestPathAgents() {
  for (int i = 0; i < allAgents.size(); i++) {
    Agent a = (Agent) allAgents.get(i);
    a.dijkstra_flip();
  }
}


void updateEdges() {
  for (int i = 0; i < allEdges.size(); i++) {
    Edge e = (Edge) allEdges.get(i);
    if (blUpdateSpring) e.updateSpring();
    if (blUpdateSpringRL) e.updateRestLength();
  }
  blUpdateSpringRL= false;
}

void updateFaces() {
  for (int i = 0; i < allFaces.size(); i++) {
    Face f = (Face) allFaces.get(i);
    f.update();
  }
}

void updateMesh() { //grow mesh components
  for (int i = 0; i < allMeshComponents.size(); i++) {
    Mesh m = (Mesh) allMeshComponents.get(i);
    //if (m.blon == true) {
    m.update();
    //}
  }
}

void smoothCpath() {
  for (int i = 0; i < allMeshComponents.size(); i++) {
    Mesh m = (Mesh) allMeshComponents.get(i);
    m.smoothCpath();
  }

  for (int i = 0; i < allMeshComponents.size(); i++) {
    Mesh m = (Mesh) allMeshComponents.get(i);
    m.smootheCpath_replaceTempData();
  }
}

void setupVoxels() {
  for (int k=0; k<10; k++) {
    for (int j=0; j<10; j++) {
      for (int i=0; i<10; i++) {
        Voxel vx= new Voxel(new Vec3D (i, j, k));         
        allVoxels. add(vx);
      }
    }
  }
}

void importAtts(float radius, float strength, String filename) {
  String lines[]= loadStrings(filename);
  for (int i=0; i<lines.length; i++) {
    float values[]= float(lines[i].split(","));
    Vec3D loc= new Vec3D(values[0], -1*values[1], values[2]);
    //Vertex v = getClosestVertex(loc);
    Attractor att= new Attractor(loc, radius, strength);
    allAtts. add(att);
  }
}

void importSeeds() {
  String lines[]= loadStrings("input/Seeds.txt");
  for (int i=0; i<lines.length; i++) {
    float values[]= float(lines[i].split(","));
    Vec3D loc= new Vec3D(values[0], -1*values[1], values[2]);
    Vertex v = getClosestVertex(loc);
    Seed s= new Seed(v);
    v.blIsSeed= true;
    allSeeds. add(s);
  }
}

void importGSeeds() {
  String lines[]= loadStrings("input/GSeeds.txt");
  for (int i=0; i<lines.length; i++) {
    float values[]= float(lines[i].split(","));
    Vec3D loc= new Vec3D(values[0], -1*values[1], values[2]);
    Vertex v = getClosestVertex(loc);
    Seed s= new Seed(v);
    v.blIsSeed= true;
    allGSeeds. add(s);
  }
}

Vertex getClosestVertex(Vec3D loc) {
  if (allVertices.size()>0) {
    Vertex vt = (Vertex) allVertices.get(0);
    float distT= 9999999;
    for (int i=0; i< allVertices.size(); i++) {
      Vertex v = (Vertex) allVertices.get(i);
      float dist= loc.distanceTo(v.v);
      if (dist< distT) {
        distT= dist;
        vt= v;
      }
    }
    return vt;
  } 
  else {
    return null;
  }
}

void setupSeeds() {
  for (int i=0; i< nSeed; i++) {
    Vertex v = (Vertex) allVertices.get(int(random(allVertices.size())));
    Seed s= new Seed(v);
    v.blIsSeed= true;
    allSeeds. add(s);
  }
}

void setupGSeeds() {
  for (int i=0; i< gSeed; i++) {
    Vertex v = (Vertex) allVertices.get(int(random(allVertices.size())));
    Seed s= new Seed(v);
    v.blIsSeed= true;
    allGSeeds. add(s);
  }
}


void setupAgents() {
  for (int i = 0; i < nAgent; i++) {
    //Seed s = (Seed) allSeeds.get(i);
    Seed s = (Seed) allSeeds.get(int(random(allSeeds.size())));
    Agent a = new Agent(this, s.v.v);
    allAgents.add(a);
    a.vID= s.v.id;
    a.goalSeed= (Seed) allGSeeds.get(int(random(allGSeeds.size())));
    //a.goalSeed= (Seed) allSeeds.get(0);
    a.initSeed= s;
  }
}

void setupAgentsOnAllSeeds() {
  for (int i = 0; i < allSeeds.size(); i++) {
    Seed s = (Seed) allSeeds.get(i);
    Agent a = new Agent(this, s.v.v);
    allAgents.add(a);
    a.vID= s.v.id;
    a.goalSeed= (Seed) allGSeeds.get(int(random(allGSeeds.size())));
    a.initSeed= s;
  }
}

void setupAgentsOnAllSeedsInPair() {
  if (allSeeds.size() == allGSeeds.size()) {
    for (int i = 0; i < allSeeds.size(); i++) {
      Seed s = (Seed) allSeeds.get(i);
      Seed g = (Seed) allGSeeds.get(i);

      for (int j=0; j<nAgent; j++) {
        Agent a = new Agent(this, s.v.v);
        allAgents.add(a);
        a.vID= s.v.id;
        a.goalSeed= g;
        a.initSeed= s;
      }
    }
  } 
  else {
    println("the size of the Seed & GSeed needs to match. Please try again.");
  }
}

void setupSeedsOnAllVertex() {
  for (int i=0; i<allVertices.size(); i++) {
    Vertex v= (Vertex) allVertices.get (i);
    Seed s= new Seed(v);
    v.blIsSeed= true;
    allSeeds. add(s);
  }
}

void setupScene() {
  cam = new PeasyCam(this, 500);//3500    
  cam.setMinimumDistance(1);
  cam.setMaximumDistance(5000);
  cam.lookAt(0, 0, 400/2);
  //cam.pan(0, height/2);
  //cam.rotateX(this.radians(-90));
  cam.setActive(true);

  setupColor();
}

void setCamState() {
  String lines[]= loadStrings("input/camera.txt");
  cam= new PeasyCam(this, float(lines[0]), float(lines[1]), float(lines[2]), float(lines[3]));

  cam.rotateX(float(lines[4]));
  cam.rotateY(float(lines[5]));
  cam.rotateZ(float(lines[6]));
}


void getCamState() {  
  float l[]= cam.getLookAt();
  double d= cam.getDistance();
  float r[]= cam.getRotations();

  //println("lookat: " + l[0] + "," + l[1] + "," + l[2] );
  //println("distance: " + d);
  //println("rotation: " + r[0] + "," + r[1] + "," + r[2] );

  PrintWriter output = createWriter("input/camera.txt");
  output.println(l[0]);
  output.println(l[1]);
  output.println(l[2]);
  output.println(d);
  output.println(r[0]);
  output.println(r[1]);
  output.println(r[2]);

  output.flush();
  output.close();

  println("camera is saved");
}

void setupColor() {
  tronBlue=  color(131, 224, 242);
  tronDarkBlue=  color(131, 224, 100);
  tronOrange=  color(31, 255, 250); 
  tronGreen=  color(87, 227, 217);
  tronLightBlue=  color(129, 71, 255);
  tronMidBlue=  color(146, 240, 232); 
  tronPurple=  color(188, 163, 214);
}

void getTimeValue() {
  stTime= timestamp();
}

void drawBox() {
  stroke(200);                
  strokeWeight(1);
  noFill();
  box(3000, 2000, 1500);
}