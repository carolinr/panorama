import ketai.sensors.*;
import ketai.ui.*;
import android.view.MotionEvent;
import java.util.Arrays;
import java.lang.Enum;
import android.os.Bundle;


SCENARIO scenario = SCENARIO.POINTING_DRAWING; 
ANNOTATION_TYPE localAnnotation = scenario == SCENARIO.DRAWING? ANNOTATION_TYPE.DRAWING: ANNOTATION_TYPE.POINTING;
ANNOTATION_TYPE remoteAnnotation = scenario == SCENARIO.DRAWING? ANNOTATION_TYPE.DRAWING: ANNOTATION_TYPE.POINTING;

KetaiGesture gesture;
KetaiSensor sensor;
PVector orientation, remoteOrientation;

float startSize, startAngle, endAngle, rotateAngle, step;
int  touchState;

//main users color (red)
color activeColor = color(255, 0, 80);
//remote users color (blue)
color remoteColor = color(100, 100, 255);

float cwidth, cheight, cradius;
int tubeRes = 32;
float[] tubeX = new float[tubeRes+1];
float[] tubeY = new float[tubeRes+1];
PImage img;



int x, y, px, py;
float o;

float touchX, touchY;

//Screen and pad dimensions
int myScreenWidth = 640;
int myScreenHeight = 360;
int padWidth = 1366;
int padHeight = 187;
boolean blinking, touched;

//Touch events
String touchEvent = ""; // string for the touch event type

float x_start;
float dx;
float timer, r, ripplex, rippley, posx, posy;

float hue = 0.0;
float l = 100;

//scale factors
float touchPadScaleX;
float touchPadScaleY;
float xpos, ypos;
float previousX;
float previousY;

int moves = 0;
int speed = 20;

float FOVwidth = 557;  // 557 pixels of the image is visible on the screen

File file;
Radar radar;
Rectangle rectangle;
Pointing pointing;
Drawing drawing; 
Connection connection = new Connection();
Status status;

//********************************************************************
//********************************************************************
void onCreate(Bundle savedInstanceState) {
  super.onCreate(savedInstanceState);
  getWindow().addFlags(android.view.WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);
}

//********************************************************************


void onResume()
{
  println("onResume");
  super.onResume();

  connection.onResume();

  file= new File();
  file.write("onResume");
}

void onStop()
{
  println("onStop");
  super.onStop();
}

void onPause()
{
  println("onPause");
  connection.onPause();

  super.onPause();

  file.write("onPause");
  file.destroy();
}

void setup()
{  
  background(0);
  size(640, 360, P3D);

  touchState = 0;


  img = loadImage("pano.jpg");
  cwidth = (float) 360.0;
  cheight = (float)img.height / (float)img.width * 360.0;
  cradius = cwidth / (float) (2 * Math.PI);

  setupFOV();

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

  //set the touch scale factor
  touchPadScaleX = (float)myScreenWidth/padWidth;
  touchPadScaleY = (float)myScreenHeight/padHeight;

  float imageScreenWidth = img.width * width / FOVwidth;

  radar = new Radar();
  rectangle = new Rectangle(imageScreenWidth);
  pointing = new Pointing();
  drawing = new Drawing();
  status = new Status();
}

void setupFOV()
{
  //  float fov = radians(30);
  //  float cameraZ = (height/2.0) / tan(fov/2.0);
  //  perspective(fov, float(width)/float(height), cameraZ/10.0, cameraZ*10.0);

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
  cameraZ = cameraY / tan(fov/2.0);
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

  float z = 250; //250 //1200
  z = 266;

  //  z = z + map(touchX, 0, padWidth, -100, 100);
  //  println("z:" + z + " touchX: " + touchX);

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

  stroke(100);
  strokeWeight(10);

  status.drawStatus();

  file.writeOrientation(orientation, remoteOrientation);

  connection.sendBufferMessages();
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

void drawAxis()
{
  strokeWeight(1);
  stroke(255, 0, 0);
  line(0, 0, 0, 100, 0, 0);

  stroke(0, 255, 0);
  line(0, 0, 0, 0, 100, 0);

  stroke(0, 0, 255);
  line(0, 0, 0, 0, 0, 100);
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

  //  println("points: " + points.size() + " remotePoints: " + remotePoints.size());
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
  //  drawLine(img, c1.x, c1.y, c2.x, c2.y);

  popMatrix();
}

void drawFingerPoint(Point point)
{
  pushMatrix();
  translate(0, -cheight / 2);

  strokeWeight(10);

  //  print("drawCylinderLine");
  //  point.print();

  PVector c1 = getCylinderPoint(point.a, point.b, point.o);
  PVector c2 = getCylinderPoint(point.x, point.y, point.o);

  //line(c1.x, c1.y, c1.z, c2.x, c2.y, c2.z);
  strokeWeight(40);
  line((c2.x-2), (c2.y-2), (c2.z-2), c2.x, c2.y, c2.z);
  //  drawLine(img, c1.x, c1.y, c2.x, c2.y);

  popMatrix();
}

PVector getCylinderPoint(float x0, float y0, float orientation)
{
  float r = cradius;

  float FOVw = cradius * (float) Math.PI / 2;
  float offset = orientation - 45;
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


//Glass Touch Events - reads from touch pad
public boolean dispatchGenericMotionEvent(MotionEvent event) {
  touchX = event.getX();                         // get x/y coords of touch event
  touchY = event.getY();

  int action = event.getActionMasked();          // get code for action
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
      if (dist(previousX, previousY, touchX, touchY)<10.0) {     
        drawing.clearLocalDrawing();
        file.writeClearAnnotation();
        connection.sendClearDrawingMessage();
      }
    }
  }


  if (pointerCount == 1) {
    switch (action) {                              // let us know which action code shows up    
    case MotionEvent.ACTION_DOWN:    
      touchEvent = "DOWN";
      break;

    case MotionEvent.ACTION_MOVE:
      if (touchEvent == "DOWN") {

        Point p = new Point(previousX*touchPadScaleX, previousY*touchPadScaleY, touchX*touchPadScaleX, touchY*touchPadScaleY, orientation.x);        
        onScreenTouched(p);
      }

      break;

    case MotionEvent.ACTION_UP:
      touchEvent = "UP";
      break;

    default:
      touchEvent = "OTHER (CODE " + action + ")";  // default text on other event
    } 

    //    println("touchEvent: " + touchEvent);

    previousX = touchX;
    previousY = touchY;
  }


  return super.dispatchTouchEvent(event);        // pass data along when done!
}


void onScreenTouched(Point p) {

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


void onDoubleTap(float x, float y) {
  println("double");
  //  circle = new Circle( x*touchPadScaleX, y*touchPadScaleY, orientation.x);
}

public boolean surfaceTouchEvent(MotionEvent event) {
  super.surfaceTouchEvent(event);
  println("surfaceTouchEvent: ");

  float touchX = event.getX();                         // get x/y coords of touch event
  float touchY = event.getY();

  int pointerCount = event.getPointerCount();
  println("pointerCount: " + pointerCount);

  return gesture.surfaceTouchEvent(event);
}

void keyPressed() {
  int KEY_SWIPE_DOWN = 4;

  //tap on the touchpad to start and stop camera
  if (key == CODED) {
    if (keyCode == DPAD) {

      println("worldState "+touchState);
      touchState = touchState+1;
      if (touchState > 1)
        touchState = 0;
    }
    else if (keyCode == KEY_SWIPE_DOWN) {
      println("swipe down");
    }
  }
}

void onSaveInstanceState()
{
  println("onSaveInstanceState");
}

