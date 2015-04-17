
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
  
  void setValues(float apos, float bpos, float xpos, float ypos, float orientation)
  {
    a = apos;
    b = bpos;
    x = xpos;
    y = ypos;
    o = orientation;
  }

  void print()
  {
    println("point - a:" + this.a + " b:" + this.b + " x:" + this.x + " y:" + this.y + " o:" + this.o);
  }

  void draw()
  {
    line(a, b, x, y);
  }
}

