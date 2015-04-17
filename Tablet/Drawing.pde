class Drawing
{
  ArrayList points = new ArrayList();
  ArrayList remotePoints = new ArrayList();

  void drawLocalDrawing()
  {
    //draw line
    stroke(activeColor);  
        
    loop(points);
  }

  void drawRemoteDrawing() {
    stroke(remoteColor);    
    loop(remotePoints);    
  }
  
  void loop(ArrayList array){
    for (int i = 0; i < array.size(); i++) {
      Object p = array.get(i);
      if (p!=null) {
        Point dots = (Point)p;
        drawCylinderLine(dots);
      }
    }
  }

  void clearLocalDrawing()
  {
    points.clear();      
  }
  
  void clearRemoteDrawing()
  {
    remotePoints.clear();
  }
}

