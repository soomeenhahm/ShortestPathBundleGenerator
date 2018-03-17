class Agent extends Ple_Agent {
  PApplet p5;

  int vID=0;
  int state= 1;
  int changeStage= 0;

  Seed goalSeed;
  Seed initSeed;

  ArrayList trail= new ArrayList(); //trail as Vec3D
  ArrayList trailVertex= new ArrayList(); //trail as Vertex (for dijkstra use only)
  boolean bldisplayTraceback= false;
  int tracebackcount= 0;

  boolean blStopTrail= false;
  boolean blDijkstraCalculate= false;


  Agent(PApplet _p5, Vec3D _loc) {
    super (_p5, _loc);
    loc= _loc.copy();
  }

  void run() {
    updateFlock();

    updateRainFlow();
    //updateRainFlow2();
    //updateRandomPath();
    //updateRainflowPath();
    //updateRainflowPathReal();

    /*
    //G: rainflow and then if stuck, divide mid point and snap(retouch) until settle
     switch(state) {
     case 0:
     if (changeStage>100) state=1;
     updateRandomPath();
     changeStage++;
     break;
     case 1:
     updateRainflowPath();
     break;
     case 2:
     snapToGrid(50); //50
     break;
     }
     */

    //if (blSnap) {
    //  snapToGrid_retouch(50);
    //  blSnap= false;
    //}


    traceBackDisplayUpdate();
  }

  void updateFlock() {
    flock(allAgents, 80, 40, 30, 1, 0.5, 1.5);
    update();

    if (frameCount % 15 == 0) {
      trail.add(loc.copy());
    }
    if (trail.size()>100) {
      trail.remove(0);
    }
  }


  void updateLoc() {
  }


  //==============================================================================================================
  //dijkstra_ shortest path ======================================================================================
  void dijkstra() {
    //println("hellow:" + vID);
    if (!blDijkstraCalculate) {
      ArrayList unsettledVts= new ArrayList();

      for (int i = 0; i < allVertices.size(); i++) {
        Vertex v = (Vertex) allVertices.get(i);
        v.fdist=999999; //tentative distance
        v.pid= 0; //previous node id
        v.blsettle= false;
      }

      Vertex vc = (Vertex) allVertices.get(vID);
      vc.fdist=0;
      unsettledVts.add(vc);

      while (unsettledVts.size () != 0) {
        Vertex v = getVertexinLowestDist(unsettledVts);
        unsettledVts.remove(v);
        v.blsettle= true;
        evaluateNeighbors(v, unsettledVts);
      }

      if (goalSeed.v.blsettle == true) {
        trail.add(goalSeed.v.v);
        trailVertex.add(goalSeed.v);
        traceBack(goalSeed.v);
      }
      blDijkstraCalculate= true;

      bldisplayTraceback= true;
      tracebackcount= trailVertex.size()-1;
    }
  }


  void dijkstra_flip() { //find longest path
    //println("hellow:" + vID);
    if (!blDijkstraCalculate) {
      ArrayList unsettledVts= new ArrayList();

      for (int i = 0; i < allVertices.size(); i++) {
        Vertex v = (Vertex) allVertices.get(i);
        v.fdist= 0; //tentative distance
        v.pid= 0; //previous node id
        v.blsettle= false;
      }

      Vertex vc = (Vertex) allVertices.get(vID);
      vc.fdist=99999999;
      unsettledVts.add(vc);

      while (unsettledVts.size () != 0) {
        Vertex v = getVertexinHighestDist(unsettledVts);
        unsettledVts.remove(v);
        v.blsettle= true;
        evaluateNeighbors_LongestPath(v, unsettledVts);
      }

      if (goalSeed.v.blsettle == true) {
        trail.add(goalSeed.v.v);
        trailVertex.add(goalSeed.v);
        traceBack(goalSeed.v);
      }
      blDijkstraCalculate= true;

      bldisplayTraceback= true;
      tracebackcount= trailVertex.size()-1;
    }
  }


  void traceBack(Vertex v) {
    if (v.pid < allVertices.size()) {
      Vertex vpre= (Vertex) allVertices.get(v.pid);
      trail.add(vpre.v);
      trailVertex.add(vpre);
      //trailVertex.add(vpre);
      //Edge et= (Edge) allEdges.get(v.cids_e[indexOfIds(v.cids, v.pid)]);
      //et.increaseCPath();
      if (vpre != initSeed.v) traceBack(vpre);
    }
  }

  void traceBackDisplay(Vertex v, Vertex vnext) {
    if (v.pid < allVertices.size()) {
      Edge et= (Edge) allEdges.get(v.cids_e[indexOfIds(v.cids, vnext.id)]);
      et.increaseCPath();
    }
  }

  void traceBackDisplayUpdate() {
    if (bldisplayTraceback) {
      if (trailVertex.size()>0 && tracebackcount > 0) {
        Vertex v= (Vertex) trailVertex.get(tracebackcount);
        Vertex vnext= (Vertex) trailVertex.get(tracebackcount-1);
        traceBackDisplay(v, vnext);
        tracebackcount --;
      }
    }
  }

  void evaluateNeighbors(Vertex v, ArrayList unsettledVts) {
    for (int i=0; i<v.cids.length; i++) {
      Vertex vn= (Vertex) allVertices.get(v.cids[i]);
      if (vn.blsettle == false) {
        //float edgeDist= 1.0; //for true value, get the distance between v & vn
        float edgeDist= v.v.distanceTo(vn.v); //true value
        float newDist= edgeDist + v.fdist;

        if (vn.fdist > newDist) {
          vn.fdist= newDist;
          vn.pid= v.id;
          unsettledVts.add(vn);
        }
      }
    }
  }

  Vertex getVertexinLowestDist(ArrayList unsettledVts) {
    Vertex vt= (Vertex) unsettledVts.get(0);
    for (int i=0; i< unsettledVts.size(); i++) {
      Vertex v= (Vertex) unsettledVts.get(i);
      if (v.fdist< vt.fdist) {
        vt= v;
      }
    }

    return vt;
  }

  void evaluateNeighbors_LongestPath(Vertex v, ArrayList unsettledVts) {
    for (int i=0; i<v.cids.length; i++) {
      Vertex vn= (Vertex) allVertices.get(v.cids[i]);
      if (vn.blsettle == false) {
        //float edgeDist= 1.0; //for true value, get the distance between v & vn
        float edgeDist= v.v.distanceTo(vn.v); //true value
        float newDist= edgeDist + v.fdist;

        if (vn.fdist < newDist) {
          vn.fdist= newDist;
          vn.pid= v.id;
          unsettledVts.add(vn);
        }
      }
    }
  }

  Vertex getVertexinHighestDist(ArrayList unsettledVts) {
    Vertex vt= (Vertex) unsettledVts.get(0);
    for (int i=0; i< unsettledVts.size(); i++) {
      Vertex v= (Vertex) unsettledVts.get(i);
      if (v.fdist> vt.fdist) {
        vt= v;
      }
    }

    return vt;
  }

  //==============================================================================================================
  //==============================================================================================================v



  void display() {
    if (blDisplayAgentPts) displayPt();
    displayTrail();
    if (blDisplayGoal)displayGoal();
  }

  void displayGoal() {
    stroke(tronBlue);
    strokeWeight(1);
    line(goalSeed.v.v.x, goalSeed.v.v.y, goalSeed.v.v.z, loc.x, loc.y, loc.z);

    stroke(tronPurple);
    line(goalSeed.v.v.x, goalSeed.v.v.y, goalSeed.v.v.z, initSeed.v.v.x, initSeed.v.v.y, initSeed.v.v.z);
  }

  void displayPt() {
    stroke(tronMidBlue);
    strokeWeight(5);
    point(loc.x, loc.y, loc.z);
  }

  void displayTrail() {
    stroke(tronMidBlue);

    if (trail.size()>0) {
      for (int i=0; i< trail.size(); i++) {
        Vec3D t= (Vec3D) trail.get(i);
        strokeWeight(4);
        if (blDisplayAgentPts)point(t.x, t.y, t.z);
        if (i>0) {
          Vec3D tpre= (Vec3D) trail.get(i-1);
          //stroke(tronBlue,100);
          //strokeWeight(3);
          //line(tpre.x, tpre.y, tpre.z, t.x, t.y, t.z);
          //stroke(0);
          strokeWeight(2);
          line(tpre.x, tpre.y, tpre.z, t.x, t.y, t.z);
        }
      }
    }
  }

  void updateRainflowPathReal() {
    if (!blStopTrail) {
      Vertex v = (Vertex) allVertices.get(vID);
      Vec3D targetDir= gravity; 
      int idn= v.getTargetVertexID(targetDir);

      Edge et= (Edge) allEdges.get(v.cids_e[indexOfIds(v.cids, idn)]);
      et.cPath++;
      Vertex vt = (Vertex) allVertices.get(idn); 
      trail.add(loc);
      loc= vt.v;
      vID= vt.id;
    }
  }


  void updateRainflowPath() {
    if (!blStopTrail) {
      Vertex v = (Vertex) allVertices.get(vID);
      Vec3D targetDir= goalSeed.v.v.sub(loc);
      int idn= v.getTargetVertexID(targetDir);

      Edge et= (Edge) allEdges.get(v.cids_e[indexOfIds(v.cids, idn)]);
      et.cPath++;
      Vertex vt = (Vertex) allVertices.get(idn); 
      trail.add(loc);
      loc= vt.v;
      vID= vt.id;

      if (vt.equals(goalSeed.v)) {
        blStopTrail = true;
        trail.add(loc);
      } 
      else if (trail.size()>2) {
        if (loc.equals((Vec3D)trail.get(trail.size()-2))) {
          blStopTrail = true;

          loc= (Vec3D)trail.get(trail.size()-1);
          et.cPath--;


          loc= goalSeed.v.v;
          trail.add(loc);

          //state=0;
          //trail.clear();
          //allAgents.remove(this);

          //loc= initSeed.loc;
          //state= 2;

          //snapToGrid(loc, goalSeed.v.v, 50);
        }
      }
    }
  }

  void snapToGrid_retouch(float interval) {
    if (trail.size()>0) {
      ArrayList trailTemp= new ArrayList();
      trailTemp.add((Vec3D) trail.get(0));

      for (int j=0; j<trail.size()-1; j++) {
        Vec3D loc_next= (Vec3D) trail.get(j+1);
        Vec3D loc= (Vec3D) trailTemp.get(trailTemp.size()-1);

        Vec3D dir= loc_next.sub(loc);
        float dist= dir.magnitude();

        if (dist > 0.1) {            
          if (dist> interval*2) {
            Vec3D newLoc= new Vec3D(loc.add(dir.scale(0.5)));
            Vertex vt= getClosestVertex(newLoc);
            newLoc= vt.v;
            trailTemp.add(newLoc);
          }
          trailTemp.add(loc_next);
        }
      }

      Vec3D locFin= (Vec3D) trailTemp.get(trailTemp.size()-1);
      if (!locFin.equals(goalSeed.v.v)) {
        trailTemp.add(goalSeed.v.v);
      }

      trail.clear();
      trail.addAll(trailTemp);
    }
  }



  void snapToGrid_retouch2(float interval) {
    ArrayList trailTemp= new ArrayList();
    trailTemp.add((Vec3D) trail.get(0));

    for (int j=1; j<trail.size(); j++) {
      Vec3D loc_pre= (Vec3D) trail.get(j-1);
      Vec3D loc= (Vec3D) trail.get(j);

      Vec3D dir= loc.sub(loc_pre);
      float dist= dir.magnitude();

      if (dist > 0.1) {            
        if (dist> interval*2) {
          for (int i=0; i< dist; i= i+int(interval)) {
            Vec3D newLoc= new Vec3D(loc_pre.add(dir.normalizeTo(interval)));

            Vertex vt= getClosestVertex(newLoc);
            loc= vt.v;
            //loc= newLoc;
            trailTemp.add(loc);
          }
        }
        trailTemp.add(loc);
      }
    }

    if (trailTemp.size()>0) {
      Vec3D locFin= (Vec3D) trailTemp.get(trailTemp.size()-1);
      if (!locFin.equals(goalSeed.v.v)) {
        trailTemp.add(goalSeed.v.v);
      }
    }
    trail.clear();
    trail.addAll(trailTemp);
  }

  void snapToGrid(float interval) {
    //float interval = 50;
    Vec3D dir= goalSeed.v.v.sub(loc);

    for (int i=0; i< dir.magnitude(); i= i+int(interval)) {
      Vec3D newLoc= new Vec3D(loc.add(dir.normalizeTo(interval)));

      Vertex vt= getClosestVertex(newLoc);
      loc= vt.v;
      trail.add(loc);
    }

    loc= goalSeed.v.v;
    trail.add(loc);

    blStopTrail = true;
  }

  void snapToGrid_gradual() {
    float interval = 50;
    Vec3D dir= goalSeed.v.v.sub(loc);
    Vec3D newLoc= new Vec3D(loc.add(dir.normalizeTo(interval)));

    Vertex vt= getClosestVertex(newLoc);
    loc= vt.v;
    trail.add(loc);

    if (vt.equals(goalSeed.v)) {
      blStopTrail = true;
    }
  }

  Vertex getClosestVertex(Vec3D loc) {
    Vertex temp= (Vertex) allVertices.get(vID);
    float distMin= 9999999;
    for (int i=0; i< allVertices.size(); i++) {
      Vertex v= (Vertex) allVertices.get (i);
      float dist= loc.distanceTo(v.v);
      if (dist< distMin) {
        temp= v;
        distMin= dist;
      }
    }
    return temp;
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

  void updateRandomPath() {
    if (!blStopTrail) {
      Vertex v = (Vertex) allVertices.get(vID);
      int idRan= int(random(v.cids.length)); //a random id

      Edge et= (Edge) allEdges.get(v.cids_e[idRan]);
      et.cPath++;
      Vertex vt = (Vertex) allVertices.get(v.cids[idRan]);   
      loc= vt.v;
      vID= vt.id;

      if (vt.equals(goalSeed.v)) { //(vt.blIsSeed) {
        blStopTrail = true;
      }
    }
  }


  void updateRainFlow2() {
    if (!blStopTrail) {
      Vertex v = (Vertex) allVertices.get(vID);

      Edge et= (Edge) allEdges.get(v.tID_e);
      et.cPath++;
      Vertex vt = (Vertex) allVertices.get(v.tID);   
      loc= vt.v;

      if (vt.tID == vID) {
        blStopTrail = true;
      }
      vID= v.tID;
    }
  }

  void updateRainFlow() {
    if (!blStopTrail) {
      Vertex v = (Vertex) allVertices.get(vID);
      Vertex vt = (Vertex) allVertices.get(v.tID);    
      trail.add(loc);
      loc= vt.v;

      if (vt.tID == vID) {
        blStopTrail = true;
      }
      vID= v.tID;
    }
  }
}