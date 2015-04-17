
class Point {
  float a, b, x, y, o;

  Point() {
  }

  Point(Point p) {
    set(p);
  }

  Point(float apos, float bpos, float xpos, float ypos, float orientation) {
    a = apos;
    b = bpos;
    x = xpos;
    y = ypos;
    o = orientation;
  }

  void set(Point p)
  {
    a = p.a;
    b = p.b;
    x = p.x;
    y = p.y;
    o = p.o;
  }

  void scale(float w0, float h0, float w1, float h1)
  { 
    a = map(a, 0, w0, 0, w1);
    b = map(b, 0, h0, 0, h1);
    x = map(x, 0, w0, 0, w1);
    y = map(y, 0, h0, 0, h1);
  }

  void scaleTo640x360()
  { 
    scale(width, height, 640, 360);
  }

  void scaleToScreen()
  { 
    scale(640, 360, width, height);
  }

  void print()
  {
    println("point - a:" + this.a + " b:" + this.b + " x:" + this.x + " y:" + this.y + " o:" + this.o);
  }
}

