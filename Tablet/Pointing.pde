class Pointing
{
  Point pointingPoint = new Point();
  Point remotePointingPoint = new Point();

  //triangle parameters
  float offset = 50;
  float factor = 3;

  void drawLocalPointing()
  { 
    //draw finger point
    stroke(activeColor);    
    drawFingerPoint(pointingPoint);
  }
  
  void drawRemotePointing()
  {
    stroke(remoteColor);    
    drawFingerPoint(remotePointingPoint);
  }
  
  void drawFingerPoint(Point point)
  {
    pushMatrix();
    translate(0, -cheight / 2);

    strokeWeight(5);

    float angle = atan2((point.y - point.b), (point.x - point.a)) ;

    PVector v1 = createVector(-offset*factor, -offset, point, angle);
    PVector v2 = createVector(0, 0, point, angle);
    PVector v3 = createVector(-offset*factor, +offset, point, angle);

    PVector c1 = getCylinderPoint(v1.x, v1.y, point.o);
    PVector c2 = getCylinderPoint(v2.x, v2.y, point.o);
    PVector c3 = getCylinderPoint(v3.x, v3.y, point.o);

    line(c1.x, c1.y, c1.z, c2.x, c2.y, c2.z);
    line(c1.x, c1.y, c1.z, c3.x, c3.y, c3.z);
    line(c3.x, c3.y, c3.z, c2.x, c2.y, c2.z);

    popMatrix();
  }

  PVector createVector(float x0, float y0, Point point, float angle)
  {
    PVector v = new PVector(x0, y0); 
    v.rotate(angle); 
    v.add(point.x, point.y, 0);

    return v;
  }
}

