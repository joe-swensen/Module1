float panelScale = 1000;  //set scale at which drawings can be made that will be sent to panels
float stdDensity = 0.05; //standard density of planets for calculating their mass
float planetScale = 1000;
int planetView = 0;
int speed = 50;
celestialBody viewedPlanet;
wPanel pA = new wPanel(578, 660, panelScale); //creates the panel locations in their respective objects
wPanel pB = new wPanel(521, 590, panelScale);
wPanel pC = new wPanel(498, 570, panelScale);
wPanel pD = new wPanel(472, 680, panelScale);
wPanel pE = new wPanel(444, 590, panelScale);
wPanel pF = new wPanel(420, 611, panelScale);
wPanel pG = new wPanel(396, 611, panelScale);
wPanel pH = new wPanel(362, 570, panelScale);
wPanel pI = new wPanel(306, 570, panelScale);
wPanel pJ = new wPanel(283, 590, panelScale);
wPanel pK = new wPanel(183, 592, panelScale);
wPanel pL = new wPanel(125, 612, panelScale);
wPanel pM = new wPanel(88, 592, panelScale);
wPanel pN = new wPanel(64, 612, panelScale);
wPanel pO = new wPanel(0, 573, panelScale);
wPanel[] panelList = {pA, pB, pC, pD, pE, pF, pG, pH, pI, pJ, pK, pL, pM, pN, pO}; //creates list of panels

ArrayList<wPanel> unusedPanels = new ArrayList<wPanel>(); //creates array list for keeping track of panels in use
ArrayList<celestialBody> presentBodies = new ArrayList<celestialBody>();
int totalBodies = int(5 + random(5));
void setup() {
  fulscreen(P3D);
  for (int i = 0; i < panelList.length; i++) { //add panels to unused arraylist
    unusedPanels.add(panelList[i]);
  }
  presentBodies.add(new celestialBody(0.0, 0.0, 50.0  * planetScale)); //Adds the 'sun,' for the sake of consistency it will always be the largest and exist in the center of the system
  viewedPlanet = presentBodies.get(0);
  for (int i = 0; i < totalBodies; i++) {
    celestialBody current = new celestialBody(random(width) * planetScale / 2, random(width) * planetScale / 2, (1.0 + random(6.00)) * planetScale);
    celestialBody sun = presentBodies.get(0);
    float xDist = (sun.xPosition - current.xPosition);
    float yDist = (sun.yPosition - current.yPosition);
    float angle = atan(yDist/xDist) - HALF_PI;
    float iv = (random(5.0) + 5.0) * planetScale;
    PVector acc = new PVector(cos(angle) * iv, sin(angle) * iv);
    current.velocity.add(acc);
    presentBodies.add(current);
  }
}
void draw() {


  background(0);
  
  for(int l = 0; l < 15; l++) {
  wPanel newstuff = panelList[l];
  newstuff.drawPrep();

  translate(panelScale / 2, panelScale / 2);
  scale(1/planetScale);
  celestialBody PanelCurrent = presentBodies.get(0);
  circle(PanelCurrent.xPosition, PanelCurrent.yPosition, PanelCurrent.radius * 2);
  for (int i = 1; i < presentBodies.size(); i++) {
    PanelCurrent = presentBodies.get(i);
    fill(PanelCurrent.bodyColor);
    circle(PanelCurrent.xPosition, PanelCurrent.yPosition, PanelCurrent.radius * 10);
  }
  scale(planetScale);
  translate(-panelScale / 2, -panelScale / 2);
  newstuff.drawSet();
  }
  
  boolean plan = false;
  celestialBody sun = presentBodies.get(0);
  if (planetView > presentBodies.size()) {
    planetView = 0;
  }
  translate(849, height / 3 * 2);
  scale(0.3/planetScale);



  sun.bodyColor = color(255, 255, 0);
  if (planetView > 0) {
    viewedPlanet = presentBodies.get(planetView);
  } else {
    viewedPlanet = presentBodies.get(0);
  }

  sun.update(false, false);
  pointLight(255, 255, 255, 0, 0, 0);


  for (int i = 1; i < presentBodies.size(); i++) {
    celestialBody currentMain = presentBodies.get(i);
    //update velocities
    for (int j = 0; j < presentBodies.size(); j++) {
      if (i != j) {
        celestialBody current = presentBodies.get(j);
        currentMain.updateGVelocity(current);
      }
    }
    //test for collision
    presentBodies.get(i).updatePosition();
    for (int j = 1; j < i; j++) {
      if (i != j) {
        celestialBody current = presentBodies.get(j);
        if (currentMain.collideTest(current)) {
          PVector v = current.velocity;
          float m = current.mass;
          v.mult(m);
          currentMain.velocity.mult(currentMain.mass);
          currentMain.velocity.add(v);
          currentMain.mass += m;
          float volume = m / stdDensity;
          currentMain.radius = pow(volume/((4/3) * PI), 1/3);
          presentBodies.remove(j);
        }
      }
    }
    currentMain.update(false, true);
    if (currentMain.collideTest(sun)) {
      presentBodies.remove(i);
    }
  }
  delay(speed);
  println(viewedPlanet);
}

void keyPressed() {
  if (key == CODED) {
    if (keyCode == UP) {
      if (speed > 0) {
        speed -= 10;
      }
    } else if (keyCode == DOWN) {
      if (speed < 100) {
        speed += 10;
      }
    } else if (keyCode == LEFT) {
      if (planetView > 0) {
        planetView--;
      }
    } else if (keyCode == RIGHT) {
      if (planetView < presentBodies.size() - 1) {
        planetView++;
      } else if (keyCode == TAB) {
        celestialBody currentCreate = new celestialBody(random(width) * planetScale / 2, random(width) * planetScale / 2, (1.0 + random(6.00)) * planetScale);
        celestialBody sun = presentBodies.get(0);
        float xDist = (sun.xPosition - currentCreate.xPosition);
        float yDist = (sun.yPosition - currentCreate.yPosition);
        float angle = atan(yDist/xDist) - HALF_PI;
        float iv = (random(5.0) + 5.0) * planetScale;
        PVector acc = new PVector(cos(angle) * iv, sin(angle) * iv);
        currentCreate.velocity.add(acc);
        presentBodies.add(currentCreate);  
      }
    }
  }
}





class wPanel { //panel class stores data about location & allows for scaled drawing
  float corner1x, corner1y, corner2x, corner2y, panelWidth, panelHeight, drawSize;
  boolean pBusy;
  wPanel(float x, float y, float dS) {
    panelWidth = 24;
    panelHeight = 21;
    corner1x = x;
    corner1y = y;
    corner2x = x + panelWidth;
    corner2y = y + panelHeight;
    drawSize = dS;
  }
  void drawPrep() { //Prepares to convert what is drawn and translate it to the panel
    translate(corner1x, corner1y);
    scale(24/drawSize, 21/drawSize);
    pBusy = true;
  }
  void drawSet() { //Resets after drawing to panel so that you can then draw to other panels
    scale(drawSize/24, drawSize/21);
    translate(-corner1x, -corner1y);
    pBusy = false;
  }
}


class celestialBody { //stores data about stars and planets for the simulation
  float xPosition, yPosition, radius, mass, area;
  PVector velocity;
  color bodyColor = color(255);  
  celestialBody(float x, float y, float r) {
    velocity = new PVector(0, 0);
    xPosition = x;
    yPosition = y;
    radius = r;
    mass = stdDensity * (4 / 3) * PI * pow(r, 3);
  }
  void update(boolean viewing, boolean grow) {
    fill(bodyColor);
    if (viewing == false) {
      translate((xPosition - viewedPlanet.xPosition), 0, ( yPosition - viewedPlanet.yPosition ));
      if (grow) {
        sphere(radius * 3);
      } else {
        sphere(radius);
      }
      translate(- (xPosition - viewedPlanet.xPosition), 0, - (yPosition - viewedPlanet.yPosition));
    } else {
      if (grow) {
        sphere(radius * 3);
      } else {
        sphere(radius);
      }
    }
  }
  void updateGVelocity(celestialBody cb) {
    /* Updates the velocity of the body based on the gravitational force as acted upon it
     by another body at position (x,y) and of mass m. For simplicity the gravitational
     constant is not used so that we can have smaller numbers overall describing the 
     positions, sizes, and masses of the bodies. */
    float x = cb.xPosition;
    float y = cb.yPosition;
    float m = cb.mass;
    float xDist = (xPosition - x);
    float yDist = (yPosition - y);
    float angle = atan(yDist/xDist);
    float dist = sqrt(pow(xDist, 2) + pow(yDist, 2));
    float gAcc = m / pow(dist, 2);
    PVector acc = new PVector(cos(angle) * gAcc, sin(angle) * gAcc);
    if (xDist >= 0) {
      velocity.sub(acc);
    } else {
      velocity.add(acc);
    }

    // println("ACC: " + acc + "  X: " + xPosition + "   Y: " + yPosition + "   dist: " + dist + "  VEL: " + velocity);
  }
  void updatePosition() {
    xPosition += velocity.x;
    yPosition += velocity.y;
  }
  boolean collideTest(celestialBody cb) { //tests for collision of this body with another body of position (x,y) and radius r
    float x = cb.xPosition;
    float y = cb.yPosition;
    float r = cb.radius;
    float test = pow(x - xPosition, 2) + pow(y - yPosition, 2);
    float test2 = pow(r + radius, 2);
    if (test <= test2) {
      return true;
    } else {
      return false;
    }
  }
}
