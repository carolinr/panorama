class Rectangle
{
  color remoteColor = color(100, 100, 255);
  float padding = 10;
  float imageScreenWidth;

  Rectangle(float imageScreenWidth)
  {
    this.imageScreenWidth = imageScreenWidth;
    //  padding = map(mouseX, 0, width, 0, 100); 
    //  println("padding: " + padding);
  }

  float calculateOffset(PVector orientation, PVector remoteOrientation)
  {
    float diff = orientation.x - remoteOrientation.x;  
    diff = diff > 180? diff - 360 : diff;  

    //  println("orientation.x: " + orientation.x + " diff: " + diff+ " offsetX: " + offsetX);

    float offsetX = map(-diff, -180.0, 180.0, -imageScreenWidth/2, imageScreenWidth/2);

    return offsetX;
  } 

  void pre(PVector orientation, PVector remoteOrientation)
  {
    float offsetX = calculateOffset(orientation, remoteOrientation); 

    pushMatrix();
    ortho();
    translate(offsetX, 0, 0);    
  }
  
  void post()
  {
    popMatrix();
  }
  
  void drawRectangle(PVector orientation, PVector remoteOrientation)
  {
    pre(orientation, remoteOrientation);
    
    drawRectangle();

    post();
  }
  
  void drawCenterPoint(PVector orientation, PVector remoteOrientation)
  {
    pre(orientation, remoteOrientation);
    
    drawCenterPoint();

    post();
  }

  void drawRectangle() {
    //draw rectangle
    strokeWeight(10);
    stroke(remoteColor, 150);
    noFill();
    rect(-width/2+padding, -height/2+padding, width-padding*2, height-padding*2);
  }

  void drawCenterPoint()
  {
    //draw center point
    strokeWeight(1);  
    fill(remoteColor, 150);
    ellipse(0, 0, height/8, height/8);
  }
}

