
import ketai.sensors.*;
import ketai.ui.*;
import android.view.*;
import java.util.Arrays;


SCENARIO scenario = SCENARIO.POINTING_DRAWING; 
ANNOTATION_TYPE localAnnotation = scenario == SCENARIO.DRAWING? ANNOTATION_TYPE.DRAWING: ANNOTATION_TYPE.POINTING;
ANNOTATION_TYPE remoteAnnotation = scenario == SCENARIO.DRAWING? ANNOTATION_TYPE.DRAWING: ANNOTATION_TYPE.POINTING;

KetaiGesture gesture;
KetaiSensor sensor;
PVector orientation, remoteOrientation;

//main users color (red)
color activeColor = color(255, 0, 80);
//remote users color (blue)
color remoteColor = color(100, 100, 255);


float startSize, startAngle, endAngle, rotateAngle;
float step;

float FOVwidth = 557;  // 557 pixels of the image is visible on the screen

float cwidth, cheight, cradius;
int tubeRes = 32;
float[] tubeX = new float[tubeRes+1];
float[] tubeY = new float[tubeRes+1];
PImage img;

//touch events
float startX, startY;
int touchState;


int x, y, px, py;

File file;
Radar radar;
Rectangle rectangle;
Pointing pointing;
Drawing drawing; 
Connection connection = new Connection();
Status status;

void onResume()
{
  println("onResume");
  super.onResume();

  connection.onResume();

  file= new File();
  file.write("onResume");
}


void onPause()
{
  println("onPause");

  connection.onPause();

  file.write("onPause");
  file.destroy();  

  super.onPause();
}

boolean sketchFullScreen() {
  return true;
}

void setup()
{
  println("setup");

  orientation(LANDSCAPE);
  background(0);
  //  size(640, 360, P3D);
  size(displayWidth, displayHeight, P3D);

  touchState = 0;

  setupFOV();


  img = loadImage("pano.jpg");
  
  
  cwidth = (float) 360.0;
  cheight = (float)img.height / (float)img.width * 360.0;
  cradius = cwidth / (float) (2 * Math.PI);

  println("cheight: " + cheight + " cradius: " + cradius + " img.height: "+ img.height + " img.width: "+  img.width);

  float angle = 360.0 / tubeRes;
  for (int i = 0; i <= tubeRes; i++) {
    tubeX[i] = cos(radians(i * angle));
    tubeY[i] = sin(radians(i * angle));
  }
  noStroke();

  gesture = new KetaiGesture(this); 
  sensor = new KetaiSensor(this);
  sensor.start();
  orientation = new PVector();
  remoteOrientation = new PVector();

  pointing = new Pointing();
  drawing = new Drawing();
  status = new Status();

  float imageScreenWidth = img.width * width / FOVwidth;

  radar = new Radar();
  rectangle = new Rectangle(imageScreenWidth);


  //  Point p = new Point(0, 0, width, height, 90);
  //  points.add(p);
}

float eyeX, eyeY, eyeZ;
float centerX, centerY, centerZ;

void setupFOV()
{
  float fovFactor, 
  degree, 
  fov, 
  cameraY, 
  cameraZ, 
  aspect, 
  clippingFactor;

  //  fovFactor = 80;  //180  
  //  fovFactor = mouseX;
  //  fovFactor = map(mouseX, 0, width, 70,400);

  degree = 30;
  //  degree = map(mouseX, 0, width, 0, 5);

  fov = radians(degree);
  //  fov = fovFactor/float(width) * PI/2;

  //  println("degree: " + degree + " fov: " + fov);
  //  println("fovFactor: " + fovFactor+ " fov: " + fov);  

  cameraY = height/2.0;
  cameraZ = cameraY / tan(degree/2.0);
  aspect = float(width)/float(height);

  clippingFactor = 10.0;  //30.0
  //  clippingFactor = map (mouseX, 0, width, 10, 100);
  //  println("clippingFactor: " + clippingFactor);  

  perspective(fov, aspect, 1, cameraZ*clippingFactor);
}

void draw()
{
  clear();
  background(10);

  float z = 1245; //250 //1200
  z = 1254;
  //  z = z + map(mouseX, 0, width, -100, 100);
  //  println("z:" + z);

  translate(width / 2, height / 2);

  pushMatrix();
  setupFOV();
  translate(0, 0, z);
  drawPanorama();
  popMatrix();

  //  switch(scenario)
  //  {
  //  case RADAR_BOX:
//  rectangle.drawRectangle(orientation, remoteOrientation);
//  radar.drawOldRadar(); 
  //    break;
  //
  //  case CONTEXT_COMPASS:
  radar.drawContextCompass();
  //    break;
  //
  //  case CENTERED_RADAR:
//  radar.drawCenteredRadar();
  //    break;
  //  }

  rectangle.drawCenterPoint(orientation, remoteOrientation);

  status.drawStatus();

  file.writeOrientation(orientation, remoteOrientation);

  connection.sendBufferMessages();
}

void onAnnotationDraw(Point p) {
  drawing.points.add(p);
  file.writeAnnotation(ANNOTATION_TYPE.DRAWING,p);
  connection.sendAnnotationMessage(p);
}

void onAnnotationPoint(Point p) {
  pointing.pointingPoint.set(p);
  file.writeAnnotation(ANNOTATION_TYPE.POINTING,p);
  connection.sendAnnotationMessage(p);
}


void onScreenTouched() {
  println("onScreenTouched");

  Point p = new Point(pmouseX, pmouseY, mouseX, mouseY, orientation.x);  

  switch(scenario)
  {
  case DRAWING:
    onAnnotationDraw(p);
    break;

  case POINTING:
    onAnnotationPoint(p);
    break;

  case POINTING_DRAWING:

    switch(localAnnotation) {

    case DRAWING:
      onAnnotationDraw(p);
      break;

    case POINTING:
      onAnnotationPoint(p);
      break;
    }

    break;
  }

  //    print("capture point");
  //    p.print();
}



void onOrientationEvent(float x, float y, float z, long time, int accuracy)
{
  orientation.set(x, y, z);  
  //  println("orientaiton x: " + x);
}


void drawPanorama()
{ 
  pushMatrix();

  rotateY(radians(orientation.x + 90)); //roll

  //  drawAxis();
  drawCylinder();
  drawPoints();

  popMatrix();
}


void drawPoints()
{
  pushMatrix();

  switch(scenario)
  {
  case DRAWING:
    drawing.drawLocalDrawing(); 
    drawing.drawRemoteDrawing();
    break;

  case POINTING: 
    pointing.drawLocalPointing();
    pointing.drawRemotePointing();
    break;

  case POINTING_DRAWING: 
    drawLocalAnnotation();
    drawRemoteAnnotation();
    break;
  }

  popMatrix();
}

void drawLocalAnnotation() {
  switch(localAnnotation) {
  case POINTING:
    pointing.drawLocalPointing();
    drawing.drawLocalDrawing();  
    break;

  case DRAWING:
    drawing.drawLocalDrawing(); 
    break;
  }
}

void drawRemoteAnnotation() {

  switch(remoteAnnotation) {
  case POINTING:
    pointing.drawRemotePointing();
    drawing.drawRemoteDrawing(); 
    break;

  case DRAWING:
    drawing.drawRemoteDrawing(); 
    break;
  }
}


void drawAxis()
{
  pushMatrix();

  strokeWeight(1);
  stroke(255, 0, 0);
  line(0, 0, 0, 100, 0, 0);

  stroke(0, 255, 0);
  line(0, 0, 0, 0, 100, 0);

  stroke(0, 0, 255);
  line(0, 0, 0, 0, 0, 100);

  popMatrix();
}

void drawCylinder()
{
  stroke(0);
  noStroke();
  beginShape(QUAD_STRIP);
  texture(img);

  float r = cradius;
  float h = cheight;
  for (int i = 0; i <= tubeRes; i++) {
    float x = tubeX[i] * r;
    float z = tubeY[i] * r;
    float u = img.width / tubeRes * i;
    vertex(x, -h/2, z, u, 0);
    vertex(x, h/2, z, u, img.height);
  }
  endShape();
}

void drawCylinderLine(Point point)
{
  pushMatrix();
  translate(0, -cheight / 2);

  strokeWeight(10);

  //  print("drawCylinderLine");
  //  point.print();

  PVector c1 = getCylinderPoint(point.a, point.b, point.o);
  PVector c2 = getCylinderPoint(point.x, point.y, point.o);

  line(c1.x, c1.y, c1.z, c2.x, c2.y, c2.z);

  strokeWeight(1);
  popMatrix();
}

PVector getCylinderPoint(float x0, float y0, float orientation)
{
  float r = cradius;

  float FOVw = cradius * (float) Math.PI / 2; 

  float offset = orientation - 45;
  //  offset = 0;

  float hOffset = map(45, 0, img.height, 0, cheight);

  float x = map(x0, 0, width, 0 + offset, FOVw + offset);  
  float y = map(y0, 0, height, 0 + hOffset, cheight - hOffset);

  float f = x;

  PVector cPoint = new PVector();  
  cPoint.x = r * cos(radians(f));
  cPoint.y = y;
  cPoint.z = r * sin(radians(f));

  //  print("getCylinderPoint- x: " + x + " x0: " + x0 + " y: " + y + " y0: " + y0 + " orientation: " + orientation + " f: " + f + " result- x:" + cPoint.x + " y:" + cPoint.y + " z:" + cPoint.z);

  return cPoint;
}


long  lastLongPress;

void  onLongPress(android.view.MotionEvent arg0) {
  println("onLongPress");
} 

final GestureDetector gestureDetector = new GestureDetector(new GestureDetector.SimpleOnGestureListener() {
  public void onLongPress(MotionEvent event) {
    int pointerCount = event.getPointerCount();  

    println("Longpress detected. pointerCount: " + pointerCount);
  }
}
);

public boolean onTouchEvent(MotionEvent event) {
  return gestureDetector.onTouchEvent(event);
};


void mouseDragged()  //(19)
{
  onScreenTouched();
}

public boolean surfaceTouchEvent(MotionEvent event) {
  boolean result = super.surfaceTouchEvent(event);
  int action = event.getActionMasked();          // get code for action

  float touchX = event.getX();                         // get x/y coords of touch event
  float touchY = event.getY();

  int pointerCount = event.getPointerCount();
  long diff = System.currentTimeMillis() - lastLongPress; 
  println("pointerCount: " + pointerCount + " diff: " + diff + " action: " + action);  
  if (diff> 400.0f)
  {
    println("llllllllllong");
    lastLongPress = System.currentTimeMillis();

    if (pointerCount ==2 && scenario ==SCENARIO.POINTING_DRAWING)
    {
      println("switching local annotation type");
      localAnnotation = localAnnotation == ANNOTATION_TYPE.DRAWING? ANNOTATION_TYPE.POINTING : ANNOTATION_TYPE.DRAWING;
    }

    if (pointerCount == 3) {
      if (dist(startX, startY, touchX, touchY)<10.0) {        
        drawing.clearLocalDrawing();
        file.writeClearAnnotation();
        connection.sendClearDrawingMessage();
      }
    }
  }

  switch (action) {                              

  case MotionEvent.ACTION_DOWN:    
    startX = touchX;
    startY = touchY;
    break;

  case MotionEvent.ACTION_UP:
    break;
  }
  return gesture.surfaceTouchEvent(event);
}

