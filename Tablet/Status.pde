class Status {
  PImage imgDrawing, imgPointing;
  int imgPadding = 10;

  Status() {
    imgDrawing = loadImage("icon-drawing.png");
    imgPointing = loadImage("icon-pointing.png");
  }

  void drawStatus()
  {
    pushMatrix();
    ortho();  

    translate(-width / 2, height / 2);
    textSize(15);
    fill(255, 0, 0);
    text("scenario: " + scenario, 0, 0);

    translate(0, -10);
    text("local: " + drawing.points.size(), 0, 0);

    translate(0, -10);
    text("remote: " + drawing.remotePoints.size(), 0, 0);

    popMatrix();
    
    drawAnnotationTypeIcon();
  }
  
  void drawAnnotationTypeIcon(){
    pushMatrix();
    ortho();
    
    PImage img = getIconImage();
    
//    float x = map(mouseX, 0, width, 0, 500);    
//    println("x: " + x);
    
    float x = 200;  //offset
    float y = 20;
    
    translate(width / 2, height / 2);
    image(img, -img.width-imgPadding  - x, -img.height-imgPadding - y);
    
    popMatrix();
  }

  PImage getIconImage() {
    return localAnnotation == ANNOTATION_TYPE.DRAWING?  imgDrawing : imgPointing;
  }
}

