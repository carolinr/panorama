
class Circle {
  float a, b, o;

  Circle() {
  }

  Circle(float apos, float bpos, float orientation) {
    a = apos;
    b = bpos;
    o = orientation;
  }

  void setValues(float apos, float bpos,  float orientation)
  {
    a = apos;
    b = bpos;
    o = orientation;
  }

  void print()
  {
    println("circle - a:" + this.a + " b:" + this.b +" o:" + this.o);
  }

}

