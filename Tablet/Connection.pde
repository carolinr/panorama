import oscP5.*;
import netP5.*;

class Connection {
  String CLEAR = "clear";

  String REMOTE_ADDRESS = "10.1.1.2";  //glass IP address
  OscP5 oscP5;
  NetAddress remoteLocation;
  long lastOrientationUpdate = 0;
  ArrayList bufferMessages = new ArrayList();

  Connection() {
    remoteLocation = new NetAddress(REMOTE_ADDRESS, 32000);
  }

  void onResume() {
    oscP5 = new OscP5(this, 12000);
  }

  void onPause() {
    oscP5.stop();
    oscP5.dispose();
    oscP5 = null;
  }

  void sendClearDrawingMessage() {  

    OscMessage myMessage = new OscMessage("AndroidData"); 
    myMessage.add(CLEAR);

    bufferMessages.add(myMessage);
  }

  void sendAnnotationMessage(Point p) {  
    Point p2 = new Point(p);
    p2.scaleTo640x360();    

    OscMessage myMessage = new OscMessage("AndroidData"); 
    myMessage.add(p2.a);
    myMessage.add(p2.b);
    myMessage.add(p2.x);
    myMessage.add(p2.y);
    myMessage.add(p2.o);
    myMessage.add(localAnnotation.ordinal());

    bufferMessages.add(myMessage); 

    //    println("sending...");
  }

  void sendBufferMessages() {
    if ( bufferMessages.size()>0) {
      for (int i=0; i<bufferMessages.size();i++) {        
        Object  m = bufferMessages.get(i);
        if (m!= null) {
          OscMessage myMessage = (OscMessage)m;
          if (myMessage != null) {
            oscP5.flush(myMessage, remoteLocation);
          }
        }
      }

      bufferMessages.clear();
    }

    if (System.currentTimeMillis() - lastOrientationUpdate > 500) {
      //send the current orientation to the other device
      OscMessage myMessage = new OscMessage("AndroidData"); 
      myMessage.add(orientation.x);
      myMessage.add(orientation.y);
      myMessage.add(orientation.z);
      //    oscP5.send(myMessage, remoteLocation);
      oscP5.flush(myMessage, remoteLocation);  

      //    println("sending orientation x:" + orientation.x);

      lastOrientationUpdate = System.currentTimeMillis();
    }
  }

  void oscEvent(OscMessage theOscMessage)
  {
    //    println("receiving");

    if (theOscMessage.checkTypetag("fffffi"))
    {
      println(theOscMessage);

      Point p = new Point();

      p.a = theOscMessage.get(0).floatValue();
      p.b = theOscMessage.get(1).floatValue();
      p.x = theOscMessage.get(2).floatValue();
      p.y = theOscMessage.get(3).floatValue();
      p.o = theOscMessage.get(4).floatValue();
      int s = theOscMessage.get(5).intValue();

      println("s: " + s);

      ANNOTATION_TYPE remoteScenario = ANNOTATION_TYPE.values()[s];

      println("remoteScenario: " + remoteScenario);

      p.scaleToScreen();

      switch(remoteScenario)
      {
      case DRAWING:
        drawing.remotePoints.add(p);
        remoteAnnotation = ANNOTATION_TYPE.DRAWING;
        break;

      case POINTING:
        pointing.remotePointingPoint.set(p);      
        remoteAnnotation = ANNOTATION_TYPE.POINTING;
        break;

      default:
        println("invalid scenario:" + remoteScenario);
      }

      p.print();
      //    p.draw();
    }
    else if (theOscMessage.checkTypetag("fff"))
    {
      float x = theOscMessage.get(0).floatValue();
      float y = theOscMessage.get(1).floatValue();
      float z = theOscMessage.get(2).floatValue();

      //    float offset = -2.5625;

      //    offset = map(mouseX, 0, width, -10, 10);    
      //    println("offset: " + offset + " x: " + x);

      remoteOrientation.set(x, y, z);
      //    println("x: " + x + " y: " + y + " z: " + z);
    }
    else if (theOscMessage.checkTypetag("s")) {
      String command = theOscMessage.get(0).stringValue();
      if (command.equals(CLEAR)) {
        drawing.clearRemoteDrawing();
      }
    }
  }
}

