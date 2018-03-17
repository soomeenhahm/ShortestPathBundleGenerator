class Mesh {
  ArrayList faces= new ArrayList(); //temporal list
  int[] fids;
  int[] mids; //face to face connected mesh ids
  int mCount=0; //turned on neighbour count
  boolean blon= false;
  int id;
  Vec3D cen= new Vec3D();
  int cPathSum= 0;
  int cPathAv= 0;
  int cPathSumT= 0; //for smooth
  int cPathAvT= 0; //for smooth
  String type= "D";

  Mesh(int _id) {
    id= _id;
    //if (random(1)< 0.1) blon= true;
    //if (id==58) blon= true;
  }

  //Creation==============================================================================
  //======================================================================================
  void initializeData() {    //initialize globally
    fids= new int[faces.size()];
    for (int i=0; i<faces.size(); i++) {
      Face f= (Face) faces.get(i);
      fids[i]= f.id;
      if (f.mcids[0] > 99999) {
        f.mcids[0]= id;
      } 
      else {
        f.mcids[1]= id;
      }
    }
    CalculateCentroid();
  }

  void CalculateCentroid() {
    int count=0;
    for (int i=0; i<fids.length; i++) {
      Face f= (Face) allFaces.get(fids[i]);
      cen.addSelf(f.pos);
      count++;
    }
    cen.scaleSelf(1/float(count));
  }

  //Initiation============================================================================
  //======================================================================================
  void initiate() {
    initiateConnection();
  }

  void initiateConnection() {
    String st= "";
    for (int j=0; j<fids.length; j++) {
      int idt= fids[j];
      Face f= (Face) allFaces.get(idt);
      if (f.mcids[1] < 99999) {
        if (f.mcids[0] == id) {
          st= st + f.mcids[1] + ";";
        } 
        else if (f.mcids[1] == id) {
          st= st + f.mcids[0] + ";";
        }
      }
    }
    //store in a index list
    int[] midsT= int(split(st, ';'));
    mids= new int[midsT.length-1];

    for (int i=0; i<midsT.length-1; i++) {
      mids[i]= midsT[i];
    }
  }

  //Setup=================================================================================
  //======================================================================================

  //Update================================================================================
  //======================================================================================
  void update() {
    //if (!blon && cPathSum > 5) blon = true;

    if (blGrow && blon) {
      initiateNeighbour();
      if (mCount<3) {
        grow();
      }
    }
  }

  void calculateCPathSum() { //called whenever an edge is updated.
    cPathSum=0;
    for (int i=0; i< fids.length; i++) {    
      Face f= (Face) allFaces.get(fids[i]);
      cPathSum += f.cPathAv;
    }
    cPathAv= int(cPathSum/ fids.length);

    devideType();
  }

  void devideType() {
    if (!blon && cPathSum > 5) {
      blon = true;
    }
    if (cPathSum > 5) type= "A";
    if (cPathSum > 20) type= "B";
    if (cPathSum > 50) type= "C";
  }

  void grow() {     
    for (int i=0; i<mids.length; i++) {
      int idt= mids[i];
      Mesh m= (Mesh) allMeshComponents.get(idt);
      if (m.cen.z > cen.z && random(1)<0.05) m.blon = true;
      else if (random(1) < 0.001) m.blon = true;
    }
  }

  void initiateNeighbour() {//initiate turned on neightbour count
    mCount= 0;
    for (int i=0; i<mids.length; i++) {
      int idt= mids[i];
      Mesh m= (Mesh) allMeshComponents.get(idt);
      mCount= mCount + int(m.blon);
    }
  }

  void smoothCpath() {
    float cPSt=cPathSum;
    float cPAt=cPathAv;
    for (int i=0; i<mids.length; i++) {
      int idt= mids[i];
      Mesh m= (Mesh) allMeshComponents.get(idt);
      cPSt += float(m.cPathSum);
      cPAt += float(m.cPathAv);
    }

    cPathSumT= int(cPSt/(mids.length+1));
    cPathAvT= int(cPAt/(mids.length+1));

    devideType();
  }
  
  void smootheCpath_replaceTempData(){
    cPathSum= cPathSumT;
    cPathAv= cPathAvT;
  }

  //Draw==================================================================================
  //======================================================================================
  void display() {
    displayMesh();
    //displayText();
  }

  void displayText() {
    fill(0);
    text (cPathSum, cen.x, cen.y, cen.z);
    //text (cPathAv, cen.x, cen.y, cen.z);
  }

  void displayMesh() {
    if (blon) {
      stroke(80); 
      strokeWeight(2);

      if (type == "A") fill(#81C7FF);
      if (type == "B") fill(#0262AF);
      if (type == "C") fill(#003864);

      for (int i = 0; i < faces.size(); i++) {
        Face f = (Face) faces.get(i);
        f.displayNoColor();
      }
    }
  }

  //======================================================================================
}