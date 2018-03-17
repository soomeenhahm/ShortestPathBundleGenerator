void keyPressed() {
  if (key == '1') {
    blFillFace =  !blFillFace;
    println("blFillFace is " + blFillFace);
  }
  if (key == '2') {
    blDisplayFace =  !blDisplayFace;
    println("blDisplayFace is " + blDisplayFace);
  }
  if (key == '3') {
    blDisplayEdge =  !blDisplayEdge;
    println("blDisplayEdge is " + blDisplayEdge);
  }
  if (key == '4') {
    blDisplayVert =  !blDisplayVert;
    println("blDisplayVert is " + blDisplayVert);
  }
  if (key == '5') {
    blDisplayAgent= !blDisplayAgent;
    println("blDisplayAgent is " + blDisplayAgent);
  }
  if (key == '6') {
    blDisplayGoal= !blDisplayGoal;
    println("blDisplayGoal is " + blDisplayGoal);
  }
  if (key == '7') {
    blDisplayVoxel= !blDisplayVoxel;
    println("blDisplayVoxel is " + blDisplayVoxel);
  }
  if (key == '8') {
    blDisplayAgentPts= !blDisplayAgentPts;
    println("blDisplayAgentPts is " + blDisplayAgentPts);
  }
  if (key == '9') {
    blDisplayBox= !blDisplayBox;
    println("blDisplayBox is " + blDisplayBox);
  }
  if (key == '0') {
    blDisplayAtt= !blDisplayAtt;
    println("blDisplayAtt is " + blDisplayAtt);
  }
  if (key == '-') {
    blDisplaySeed= !blDisplaySeed;
    println("blDisplaySeed is " + blDisplaySeed);
  }
  if (key=='=') {
    blDisplayPipe= !blDisplayPipe;
  }
  if (key=='[') {
    blDisplayMeshComp= !blDisplayMeshComp;
  }

  //Exporters: =========================================================
  if (key=='i' || key == 'I') {
    saveFrame ("output/image" + timestamp() + ".png");
    println("one frame saved at: " + timestamp() );
  }
  if (key=='x' || key == 'X') {
    exportMesh();
  }
  if (key=='t' || key == 'T') {
    exportTrail();
  }
  if (key=='e') {
    exportEdges();
  }
  if (key == 'E') {
    exportChildEdges();
  }
  if (key=='d' || key == 'D') {
    if (blDisplayAgentPts) blDisplayAgentPts= false;
    if (!blDisplayBox) blDisplayBox= true;
    if (blDisplayGoal) blDisplayGoal= false;
    blrecordDXF= true;
  }
  if (key == 'b' ) {
    exportMeshComponents();
  }
  if (key == 'C') {
    getCamState();
  }
  if (key == 'c') {
    setCamState();
  }

  //Updater: ============================================================
  if (key==' ') { ////////////////////////////////////////////////////////////////////////////////////////////
    blUpdateAgents= !blUpdateAgents;
  }
  if (key=='a' || key == 'A') {
    //setupAgents();
    //setupAgentsOnAllSeedsInPair();
    setupAgentsOnAllSeeds();
  }
  if (key=='s' || key == 'S') {
    //blSnap= true;
    //etouchAgents();
    blUpdateSpring= !blUpdateSpring; //////////////////////////////////////////////////////// interesting spring deformer
  }
  if (key=='l' || key == 'L') {
    blUpdateSpringRL= !blUpdateSpringRL;  //////////////////////////////////////////////////////// interesting spring deformer
  }
  if (key=='p') {  //////////////////////////////////////////////////////// nearest path
    findShortestPathAgents();
  }
  if (key=='P') {  //////////////////////////////////////////////////////// longest path
    findLongestPathAgents();
  }
  if (key=='k' || key == 'K') {  //////////////////////////////////////////////////////// interesting spring deformer
    blUpdateAtt= !blUpdateAtt;
  }
  if (key=='w' || key == 'W') {
    retouchAgents();
  }
  if (key=='q' || key == 'Q') {
    gotoGoalAgents();
  }
  if (key=='n' || key == 'N') {
    allAgents.clear();
    for (int i = 0; i < allEdges.size(); i++) {
      Edge e = (Edge) allEdges.get(i);
      e.cPath=0;
      e.cPathBundles.clear();
    }
  }
  if (key=='g') {
    blGrow= !blGrow;
    println("blGrow is " + blGrow);
  }
  if (key=='f'){
    smoothCpath();
  }
}