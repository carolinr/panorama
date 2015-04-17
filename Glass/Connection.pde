import oscP5.*;
import netP5.*;


class Connection {
  String CLEAR = "clear";

  // true until a key is pressed
  boolean waitForClients = true;
  String oscPatternConnect = "/server/connect";
  String oscPatternDisconnect = "/server/disconnect";
  String oscPatternLetter = "/letter";
  NetAddressList connectedUsers = new NetAddressList();
  int myListeningPort = 32000;
  int myBroadcastPort = 12000;

  long lastOrientationUpdate = 0;

  OscP5 oscP5;
  NetAddress remoteLocation;

  ArrayList bufferMessages = new ArrayList();

  void onResume() {
    oscP5 = new OscP5(this, myListeningPort );
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


  void sendBufferMessages() {

    if (!waitForClients) {

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
        oscP5.flush(myMessage, remoteLocation);

        //    println("sending orientation x:" + orientation.x);

        lastOrientationUpdate = System.currentTimeMillis();
      }
    }
  }

  void sendAnnotationMessage(Point p) {
    OscMessage myMessage = new OscMessage("AndroidData");         
    myMessage.add(p.a);
    myMessage.add(p.b);
    myMessage.add(p.x);
    myMessage.add(p.y);
    myMessage.add(p.o);
    myMessage.add(localAnnotation.ordinal());

    bufferMessages.add(myMessage);
  }

  private void connect(String ip) {
    //  println("connecting... " + ip);  
    remoteLocation = new NetAddress(ip, myBroadcastPort);
    waitForClients = false; 

    if (!connectedUsers.contains(ip, myBroadcastPort)) {
      connectedUsers.add(new NetAddress(ip, myBroadcastPort));
      println("Adding "+ip+" to the list.");
    } 
    else {
      println(ip+" is already connected.");
    }
    println("Currently there are "+connectedUsers.list().size()+" remote locations connected.");
  }

  private void disconnect(String ip) {
    if (connectedUsers.contains(ip, myBroadcastPort)) {
      connectedUsers.remove(ip, myBroadcastPort);
      println("Removing "+ip+" from the list.");
    } 
    else {
      println(ip+" is not connected.");
    }
    println("Currently there are "+connectedUsers.list().size()+" remote locations connected.");
  }


  void oscEvent(OscMessage theOscMessage)
  {  
    //  println("oscEvent");
    if (waitForClients) {
      connect(theOscMessage.netAddress().address());
    }

    //  if (theOscMessage.addrPattern().equals(oscPatternConnect)) {
    //    connect(theOscMessage.netAddress().address());
    //  }
    //  else if (theOscMessage.addrPattern().equals(oscPatternDisconnect)) {
    //    disconnect(theOscMessage.netAddress().address());
    //  }

    if (theOscMessage.checkTypetag("fffffi"))
    {
      float a = theOscMessage.get(0).floatValue();
      float b = theOscMessage.get(1).floatValue();
      float x = theOscMessage.get(2).floatValue();
      float y = theOscMessage.get(3).floatValue();
      float o = theOscMessage.get(4).floatValue();
      int s = theOscMessage.get(5).intValue();

      println("s: " + s);

      ANNOTATION_TYPE remoteScenario = ANNOTATION_TYPE.values()[s];

      println("remoteScenario: " + remoteScenario);


      Point p = new Point(a, b, x, y, o);

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

      //    println("received point:");
      p.print();
    }
    else if (theOscMessage.checkTypetag("fff"))
    {
      float x = theOscMessage.get(0).floatValue();
      float y = theOscMessage.get(1).floatValue();
      float z = theOscMessage.get(2).floatValue();

      remoteOrientation.set(x, y, z);

      //    println("received orientation - x: " + x + " y: " + y + " z: " + z);
    }
    else if (theOscMessage.checkTypetag("s")) {
      String command = theOscMessage.get(0).stringValue();
      if (command.equals(CLEAR)) {
        drawing.clearRemoteDrawing();
      }
    }
  }
}

