class Radar
{

  //main users color (red)
  color activeColor = color(255, 0, 80);
  //remote users color (blue)
  color remoteColor = color(100, 100, 255);

  int ellipseWidth = height/4;
  int pointerWidth = height/3 ;

  void drawContextCompass()
  {
    pushMatrix();
    ortho();

    stroke(activeColor);
    strokeWeight(1);
    line(-width/3, -height/3, width/3, -height/3);
    noStroke();
    translate(-width/3, 0, 0);

    float ratio = (width/3 * 2) / 360.0;   

    int rectWidth = width/5;
    int rectHeight = height/15;

    fill(activeColor, 200);
    ellipse(orientation.x*ratio, -height/3, 8, rectHeight); 
    fill(activeColor, 100);
    rect(orientation.x*ratio-rectWidth/2, -height/3-rectHeight/2, rectWidth, rectHeight);


    fill(remoteColor, 200);
    ellipse(remoteOrientation.x*ratio, -height/3, 8, rectHeight);
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
    ellipse(0, 0, ellipseWidth/2, ellipseWidth/2); 

    popMatrix();

    // new active Radar middle point
    pushMatrix();
    noStroke();  
    fill(activeColor, 150);
    rotateZ(radians(orientation.x));
    drawArc(pointerWidth, 55);
    popMatrix();

    // new active Radar area
    pushMatrix();
    noStroke();
    fill(activeColor, 30);
    rotateZ(radians(orientation.x));
    drawArc(ellipseWidth, 3);
    popMatrix();

    // new active Radar stroke
    pushMatrix();
    stroke(activeColor);
    strokeWeight(4);
    rotateZ(radians(orientation.x));
    drawArc(ellipseWidth, 3);
    popMatrix();

    //new remote radar middle point
    pushMatrix();
    noStroke();
    fill(remoteColor, 150); 
    rotateZ(radians(remoteOrientation.x));
    drawArc(pointerWidth, 55);
    popMatrix();

    //new remote radar area
    pushMatrix();
    noStroke();
    fill(remoteColor, 50); 
    rotateZ(radians(remoteOrientation.x));
    drawArc(ellipseWidth, 3);
    popMatrix();

    //new remote radar stroke
    pushMatrix();
    strokeWeight(4);
    stroke(remoteColor);
    noFill();
    rotateZ(radians(remoteOrientation.x));
    drawArc(ellipseWidth, 3);
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

    //draw centerpoint
    pushMatrix();
    stroke(255);
    strokeWeight(4);
    fill(255, 50);
    ellipse(0, 0, ellipseWidth/2, ellipseWidth/2); 
    popMatrix();


    translate(width/3, -height/4);
    translate(25, -9, -20);  

    //white radar
    pushMatrix();    
    noStroke();
    fill(activeColor, 255);

    rotateZ(radians(orientation.x));
    drawArc(pointerWidth+10, 55);
    popMatrix();

    pushMatrix();    
    noStroke();
    fill(activeColor, 100);      
    rotateZ(radians(orientation.x));
    drawArc(pointerWidth, 3);
    popMatrix();

    //turquoise radar

    pushMatrix();
    //strokeWeight(5);
    noStroke();
    fill(remoteColor, 255);      
    rotateZ(radians(remoteOrientation.x));
    drawArc(pointerWidth+10, 55);
    popMatrix();

    pushMatrix();
    //strokeWeight(5);
    noStroke();
    fill(remoteColor, 100);      
    rotateZ(radians(remoteOrientation.x));
    drawArc(pointerWidth, 3);
    popMatrix();

    int offset = 20; 

    pushMatrix();    
    noFill();
    stroke(255, 50);
    strokeWeight(4);
    ellipse(0, 0, ellipseWidth+offset, ellipseWidth+offset);
    strokeWeight(2);
    ellipse(0, 0, ellipseWidth*3/4+offset, ellipseWidth*3/4+offset);
    strokeWeight(1);
    ellipse(0, 0, ellipseWidth/2+offset, ellipseWidth/2+offset);
    ellipse(0, 0, ellipseWidth*1/3+offset, ellipseWidth*1/3+offset);
    ellipse(0, 0, ellipseWidth*1/4+offset, ellipseWidth*1/4+offset);
    fill(255);
    ellipse(0, 0, ellipseWidth*1/8, ellipseWidth*1/8);
    popMatrix();

    popMatrix();
  }
}

