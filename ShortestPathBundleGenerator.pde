//Complex Network v.01
//written by Soomeen Hahm & Igor Pantic
//Copyright (c) 2016 Soomeen hahm & Igor Pantic, London UK 
//last modified: Feb 2016
//developed in the Bartlett, Research Cluster 6, UCL, London
//more info at soomeenhahm.com & igorpantic.net
//requires toxiclibs, peasycam, plethora
//Description: creating stream path within existing 3D space frame using agent based behaviour and dijkstra shortest path algorithm


//To do:
//1. Find longest path (v) 
//2. set specific seed and goal in pair (v)
//3. make animation (v)
//4. set saved view (v)
//5. import OBJ as separated components (v)
//6. export mesh components (v)
//7. let face store edge cpath count (v)
//7. display face according to face cpath sum (v)
//8. let mesh store face cpath count (v)
//8. average cpath gradiant to have 3 different kinds of components !!!!!!!!!!!!!!!!!!!  thermal gradiant problem. FIX THIS!!!----------------------------------------------------------------------------------
//8. fix error when using octa3Dpack for longest path
//8. fix face display flickering error
//9. optimize script by figuring out "how to remove last element from an array java" - when string change to int array
//10. optimize all initiation by changing temporal arraylist to a temporal string list 
//11. export face accroding to cpath
//12. fix physics spring simulation
//13. fix camera problem

//New Keys:
//1. Shortest Path = 'p'
//2. Longest Path = 'P' (shift + p)
//3. Refress all input = 'n'


int nSeed= 1; //seeds
int gSeed= 1; //goal seeds
int nAgent= 1; //number of agents at onces

float scRLscale= 0.98; 
int cPathMax= 10; //what is the maximum radius of bundles
float scBundleThick= 1; //how thick it gets at each time 
int nBundleCount= 5; //how many bundles to add at each time

Vec3D gravity= new Vec3D (0, 0, -1);


void setup() {
  size(1200, 600, P3D);
  colorMode(HSB);  
  setupScene(); 
  randomSeed(123);

  //import OBJ as one whole network:
  importObj("korean-lr.obj");
  //importObj("Mesh_p.obj");
  initiateData();

  //setupSeeds();
  //importSeeds();
  setupSeedsOnAllVertex(); // this is initial agent position

  setupGSeeds();  
  //importGSeeds();

  //setupAgents(); //setup on Seeds 
  setupAgentsOnAllSeeds(); 
  //setupAgentsOnAllSeedsInPair();
  setupVoxels();
  importAtts(1200, 2, "input/Atts.txt"); // radius, strength (-repel, +attract)
  importAtts(800, -2, "input/Atts2.txt"); 

  //printDupFaces();

  //println("Verts: " + allVertices.size());
  //println("Edges: " + allEdges.size());
  //println("Faces: " + allFaces.size());
}

void draw() {
  background(255);
  smooth(); 
  getTimeValue(); 

  if (blrecordDXF) exportDXF();
  if (blDisplayEdge) drawEdges();
  if (blDisplayPipe) drawEdgePipes();
  if (blDisplayAgent) drawAgents();
  if (blDisplayBox) drawBox();
  if (blDisplayFace) drawFaces();
  if (blDisplayVert) drawVertices();
  drawSeeds();
  if (blDisplayAgent) drawAgents();
  if (blDisplayVoxel) drawVoxels();
  if (blDisplayAtt) drawAtts();
  if (blDisplayMeshComp) drawMeshComponents();

  //if (blUpdateAgents) if (frameCount% 1 == 0) updateAgents(); ///////////////////////////////////////////
  if (blUpdateAgents)  updateAgents(); ///////////////////////////////////////////
 
  updateEdges();
  if (blUpdateAtt) updateAtts();
  updateMesh();

  //drawTestConnection(50);
}