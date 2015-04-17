class Radar 
{
  void drawContextCompass()
  {
    pushMatrix();
    ortho();
    
    //draw centerpoint
    stroke(activeColor);
    strokeWeight(4);
    fill(255, 50);
    ellipse(0, 0, height/8, height/8); 

    stroke(activeColor);
    line(-width/3, -height/3, width/3, -height/3);
    noStroke();
    translate(-width/3, 0, 0);

    float ratio = (width/3 * 2) / 360.0;
    
    int rectWidth = 500;
    int rectHeight = 50;

    fill(activeColor, 150);
    ellipse(orientation.x*ratio, -height/3, 10, rectHeight); 
    fill(activeColor, 100);
    rect(orientation.x*ratio-rectWidth/2, -height/3-rectHeight/2, rectWidth, rectHeight);


    fill(remoteColor, 150);
    ellipse(remoteOrientation.x*ratio, -height/3, 10, rectHeight);
    fill(remoteColor, 100);
    rect(remoteOrientation.x*ratio-rectWidth/2, -height/3-rectHeight/2, rectWidth, rectHeight);
    popMatrix();
  }

  void drawCenteredRadar()
  {
    pushMatrix();
    ortho();

    //draw ellipses 
    pushMatrix();
    //draw centerpoint
    stroke(activeColor);
    strokeWeight(4);
    fill(255, 50);
    ellipse(0, 0, height/8, height/8); 

    popMatrix();

    // new active Radar middle point
    pushMatrix();
    noStroke();  
    fill(activeColor, 150);
    rotateZ(radians(orientation.x));
    drawArc(450, 55);
    popMatrix();

    // new active Radar area
    pushMatrix();
    noStroke();
    fill(activeColor, 30);
    rotateZ(radians(orientation.x));
    drawArc(400, 3);
    popMatrix();

    // new active Radar stroke
    pushMatrix();
    stroke(activeColor);
    strokeWeight(5);
    rotateZ(radians(orientation.x));
    drawArc(400, 3);
    popMatrix();

    //new remote radar middle point
    pushMatrix();
    noStroke();
    fill(remoteColor, 150); 
    rotateZ(radians(remoteOrientation.x));
    drawArc(450, 55);
    popMatrix();

    //new remote radar area
    pushMatrix();
    noStroke();
    fill(remoteColor, 50); 
    rotateZ(radians(remoteOrientation.x));
    drawArc(400, 3);
    popMatrix();

    //new remote radar stroke
    pushMatrix();
    strokeWeight(5);
    stroke(remoteColor);
    noFill();
    rotateZ(radians(remoteOrientation.x));
    drawArc(400, 3);
    popMatrix();

    popMatrix();
  }

  void drawArc(float arcSize, float arcStep)
  {
    startSize = arcSize;
    step = arcStep;
    startAngle = rotateAngle - PI/step;
    endAngle = rotateAngle + PI/step;
    arc(0, 0, startSize, startSize, startAngle, endAngle);
  }


  void drawOldRadar()
  {
    pushMatrix();
    ortho();
    translate(width/3, -height/3);

    //white radar
    pushMatrix();

    //strokeWeight(5);
    noStroke();
    fill(activeColor, 150);

    rotateZ(radians(orientation.x));
    drawArc(450, 70);
    popMatrix();

    pushMatrix();
    //strokeWeight(5);
    noStroke();
    fill(activeColor, 70);
    rotateZ(radians(orientation.x));
    drawArc(400, 3);

    popMatrix();

    //turquoise radar

    pushMatrix();
    //strokeWeight(5);
    noStroke();
    fill(remoteColor, 150);
    rotateZ(radians(remoteOrientation.x));
    drawArc(450, 80);
    popMatrix();

    pushMatrix();
    //strokeWeight(5);
    noStroke();
    fill(remoteColor, 100);

    rotateZ(radians(remoteOrientation.x));
    drawArc(400, 3);
    popMatrix();

    //draw ellipses
    pushMatrix();
    noFill();
    stroke(255, 50);
    strokeWeight(4);
    ellipse(0, 0, height/4, height/4);
    strokeWeight(2);
    ellipse(0, 0, height/5, height/5);
    strokeWeight(1);
    ellipse(0, 0, height/6, height/6);
    ellipse(0, 0, height/8, height/8);
    ellipse(0, 0, height/11, height/11);

    fill(255);
    ellipse(0, 0, 5, 5);
    popMatrix();

    //draw centerpoint
    stroke(255);
    strokeWeight(4);
    fill(255, 50);
    ellipse(-width/3, height/3, height/8, height/8); 




    popMatrix();
  }
}

