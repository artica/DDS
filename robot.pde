/************************
 
 ROBOT STUFF
 
 *************************/

float previousY = 0.01;
float dt = 1.0/30.0;
float velocityAmount;
float rotationAmount;
float rotationWheelLeft, rotationWheelRight;

int pathIntervalCounter;
int pathInterval = 5;

float R = 10; // wheel radius
float L = 50; // wheel distance

Robot RobotOne = new Robot (0, 0, 0, R, L);

ArrayList pontos; 

void RobotSetup()
{
  RobotOne.heading = -PI/2;
  RobotOne.vr = 3;
  RobotOne.vl = 2;
  pontos = new ArrayList();  
  pontos.add(new Ponto(0, 0, 0));
}

/********************************************************
 
 CALL MOVE + DRAW + PATH
 
 ********************************************************/

void RobotDraw()
{
  rectMode(CENTER);

  if (robotMove)
    RobotOne.Move();

  if (drawRobot)
    RobotOne.Draw();

  if (addPath && activePath) 
  {  
    if (pathIntervalCounter > pathInterval) {
      RobotOne.addPath();
      pathIntervalCounter = 0;
    }
    pathIntervalCounter++;
  }

  if (drawPath)
    RobotDrawPath();
}

/************************
 
 CLASS ROBOT
 
 *************************/

class Robot {
  float vl, vr; // left and right wheel velocity
  float v; // "unicycle" velocity
  float w; // angular velocity 

  float heading; // direction in radians;
  float x, y;
  float R; // wheel radius
  float L; // wheel distance

  int id;

  Robot (float _x, float _y, float _heading, float _r, float _l) {
    x = x;
    y = y;
    heading = _heading;
    vl = 0;
    vr = 0;
    v = 0;
    L = _l;
    R = _r;
  }

  void Draw () {

    pushMatrix();
    translate(width/2+x, height/2+y);

    rotate (heading);    

    strokeWeight(1);
    stroke(0, 150, 255, 220);
    fill(0, 150, 255, 50);

    // chassis
    drawChassis();

    //wheels
    pushMatrix();
    translate(0, -L/2-3);
    if (robotMove)
      rotateY(rotationWheelLeft -= (oneValLeft/50)/20);
    drawWheel();
    popMatrix();

    pushMatrix();
    translate(0, L/2+3);
    if (robotMove)
      rotateY(rotationWheelRight -= (oneValRight/50)/20);
    drawWheel();
    popMatrix();

    //sensor
    pushMatrix();
    translate(20, 0, 10);
    drawSensor();
    popMatrix();

    //rect (20, 0, 10, 10);

    popMatrix();
  }

  void addPath()
  {
    pontos.add(new Ponto(id, width/2+x, height/2+y));
    id++;
  }

  void Move() {
    // v =  R * (vr+vl)/2; 
    // w = (R/L) * (vl-vr);

    x += (v * cos(heading))*dt;
    y += (v * sin(heading))*dt;
    heading += w*dt; 

    velocityAmount = (oneValRight/50)+(oneValLeft/50);
    rotationAmount = (oneValRight/50)-(oneValLeft/50);

    v = -velocityAmount*17;
    w = rotationAmount;

    vr =  R/2*(v/2 + w/L);
    vl =  R/2*(v/2 - w/L);

    //println(vr+"   "+vl+"   "+oneValLeft+"   "+oneValRight);
  }
}


/********************************************************
 
 ROBOT DRAW PATH
 
 ********************************************************/
void RobotDrawPath()
{
  stroke(0, 255, 150, 100);
  for (int i = pontos.size()-1; i >= 0; i--) { 
    Ponto ponto = (Ponto) pontos.get(i);    
    ponto.display();
    if (ponto.finished()) {
      pontos.remove(i);
    }
  }
}

/********************************************************
 
 ROBOT TEXT
 
 ********************************************************/

void drawRobotStatus() {
  pushMatrix();
  translate(240, 510);
  text ("Robot data:", 0, -140);
  text ("x = " + RobotOne.x, 0, -120);
  text ("y = " + RobotOne.y, 0, -100);
  text ("vl = " + RobotOne.vl, 0, -80);
  text ("vr = " + RobotOne.vr, 0, -60);
  text ("v = " + RobotOne.v, 0, -40);
  text ("w = " + RobotOne.w, 0, -20);
  popMatrix();
}

/********************************************************
 
 ROBOT UPDATER
 
 ********************************************************/

void robotUpdater()
{

  dx = mouseX - joyDisplayCenterX;
  dy = mouseY - joyDisplayCenterY;

  curJoyAngle = atan2(dy, dx);
  curJoyRange = constrain(dist(mouseX, mouseY, joyDisplayCenterX, joyDisplayCenterY), 0, joyOutputRange-5);


  joyHorizontalText = (joyOutputRange*(cos(curJoyAngle) * curJoyRange)/ maxJoyRange);
  joyVerticalText = (joyOutputRange*(-(sin(curJoyAngle) * curJoyRange)/maxJoyRange));

  // radians

  float radHoriz;
  float radVert;

  radHoriz = radians(joyHorizontalText);
  radVert = radians(joyVerticalText);

  // gXLeft & gYLeft

    gXLeft = map(joyHorizontalText, -90, 90, -1.0, 1.0);
  gYLeft = map(joyVerticalText, -90, 90, -1.0, 1.0);

  gXRight = -gXLeft;
  gYRight = gYLeft;

  rectsLeft();
  rectsRight();
}

/********************************************************
 
 ROBOT 3D STAGE
 
 ********************************************************/

void robotDrawStage()
{
  if (cameraActive)
  {
    noFill();
    stroke(0, 255, 0, 100);

    pushMatrix();
    /*
    camera(eyeX, eyeY, eyeZ, 
     centerX, centerY, centerZ, 
     upX, upY, upZ);   
     */
    translate(width/2.0+xpos, height/2.0+ypos, zpos);

    rotateX(rX);
    rotateY(rY);
    rotateZ(rZ);

    /*
    stroke(255, 0, 0);
    rect(0, 0, 20, 20);
    */
    
    translate(-600, -500);
    
    /*
    stroke(0, 255, 0);
    rect(0, 0, 20, 20);
    */
    
    if (gridActive)
      drawGrid();

    RobotDraw();

    popMatrix();
  } 
  else
  {
    if (gridActive)
      drawGrid();

    RobotDraw();
  }
}

