float earthRadius = 6371;
float skyRadius = 6500;
float altitude = 100;
float skyDiff = skyRadius - earthRadius - altitude;
float m2p = 89;
float rayleighThickness = 7994;
float mieThickness = 1200;
float H = 8500;
float a; //sphere center x
float b; //sphere center y
float c; //sphere center z
float RL; //ray length
float TR, TG, TB; //transmittence values
float raySteps = 1000;
float FOV = 90;
float SI = 20; //sun intensity
PVector[][] renderVectors;
float[][] renderAngles;
PVector observer;
PVector center;
int hw;
int hh;
float cDist;
float T; //transmittance
float colorCE;
PVector pimachine = new PVector(PI, PI, PI);
float R = 333.1e-6;
float G = 13.5e-6;
float B = 5.8e-6;
float mie = 210e-5;
float u;
float g;
PVector sunPos;
float rPhase = (3/(16 * PI)) * (1 + pow(u, 2));
float miePhase = (3 / (8 * PI)) * ((1 - pow(g, 2)) * (1 + pow(u, 2)))/((2 + pow(g, 2)) * pow(1 + pow(g, 2) - 2 * g * u, 3/2));
void setup() {
  size(400, 400, P3D);
  background(0);
  hw = width / 2;
  hh = height / 2;
  a = width / 2;
  b = (height + ((earthRadius + altitude) * m2p));
  c = 0;
  cDist = (0.5 * width) / tan((FOV * PI)/360);
  observer = new PVector(hw, hh, cDist);
  center = new PVector(a, b, c);
  float sunx = hw;
  float suny = 0;
  float sunz = -10 * skyRadius;
  sunPos = new PVector(sunx, suny, sunz);
  renderVectors = new PVector[width][height];
  for (int i = -1 * hh; i < hh; i++) {
    for (int j = -1 * hw; j < hw; j++) {
      renderVectors[j + hw][i + hh] = new PVector(parseFloat(j + hw), parseFloat(i + hh), 0);
    }
  }
}

void draw() {
  observer = new PVector(hw, hh, cDist);
  b = (height + ((earthRadius + altitude) * m2p));
  center = new PVector(a, b, c);
  background(0);
  for (int k = -1 * hh; k < hh; k++) {
    for (int l = -1 * hw; l < hw; l++) {
      PVector newPoint = sphereIntersect(observer, renderVectors[l + hw][k + hh], center, skyRadius * m2p);
      if (newPoint != pimachine) {
        PVector colorTransmit = transmittanceCalc(observer,newPoint,raySteps);

        point(l + hw, k + hh);
      } else {
        stroke(0);
      }
      PVector newPoint2 = sphereIntersect(observer, renderVectors[l + hw][k + hh], center, earthRadius * m2p);
      if (newPoint2 != pimachine) {
        float colorDist;
        colorDist = PVector.dist(observer, newPoint2);
        stroke(0, 0, 255 - colorDist);
        //println(newPoint);
        //point(screenX(newPoint.x,newPoint.y,newPoint.z),screenY(newPoint.x,newPoint.y,newPoint.z));
        point(l + hw, k + hh);
      } else {
        stroke(0);
      }
    }
  }

  /*
  pushMatrix();
   translate(a,b,c);
   fill(0,100,200);
   stroke(0);
   sphere(earthRadius * m2p);
   popMatrix();*/
}

public PVector sphereIntersect(PVector obs, PVector scrn, PVector cntr, float rad) {

  float cx = cntr.x;
  float cy = cntr.y;
  float cz = cntr.z;

  float x0 = obs.x;
  float y0 = obs.y;
  float z0 = obs.z;

  float x1 = scrn.x - x0;
  float y1 = scrn.y - y0;
  float z1 = scrn.z - z0;

  float A = pow(x1, 2) + pow(y1, 2) + pow(z1, 2);
  float C = 2.0 * ((x0 * x1) + (y0 * y1) + (z0 * z1) - (x1 * cx) - (y1 * cy) - (z1 * cz));
  float B = pow(x0, 2) - (2 * x0 * cx) + pow(cx, 2) + pow(y0, 2) - (2 * y0 * cy) + pow(cy, 2) +pow(z0, 2) - (2 * z0 * cz) + pow(cz, 2) - pow(rad, 2);

  float D = B * B - 4 * A * C;
  /*
  println("A: " + A);
   println("B: " + B);
   println("C: " + C);
   println("D: " + D);
   println("rad: " + rad);
   println(cntr);
   println(obs);
   println(scrn);
   println(cntr);*/


  if (D < 0) {
    return pimachine;
  }


  float t1 = (- B - sqrt(D)) / (2.0 * A);

  PVector possibility1 = new PVector(obs.x * (1 - t1) + t1 * scrn.x, obs.y * (1 - t1) + t1 * scrn.y, obs.z * (1 - t1) + t1 * scrn.z);
  if (D == 0) {
    return possibility1;
  }

  float t2 = (- B + sqrt(D)) / (2.0 * A);

  PVector possibility2 = new PVector(obs.x * (1 - t2) + t2 * scrn.x, obs.y * (1 - t2) + t2 * scrn.y, obs.z * (1 - t2) + t2 * scrn.z);
  if (possibility2.z > scrn.z) {
    return possibility1;
  } else {
    return possibility2;
  }
}

public PVector transmittanceCalc(PVector Pc, PVector Pa,float steps) { //where Pc is point of camera and Pa is point exiting atmosphere
  float integral = 0;
  PVector Pb;
  float colorDist = PVector.dist(Pc, Pa);
  float sliceWidth = colorDist / steps;
  for (float x = 0; x < colorDist; x += sliceWidth) {
    Pb = PVector.lerp(Pc, Pa, colorDist/x);
    float h = exp(- ((PVector.dist(Pb, center) - earthRadius)/H));
    integral += h;
  }
  integral *= sliceWidth;
  TR = exp(- R * integral);
  TG = exp(- G * integral);
  TB = exp(- B * integral);
  return new PVector(TR,TG,TB);
}
