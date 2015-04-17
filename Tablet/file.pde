import java.io.FileWriter;
import java.io.BufferedWriter;
import android.os.Environment;

// TEST COMMENT
class File {  

  PrintWriter output;
  long lastUpdate = 0;

  File()
  {
    int D = day();    // Values from 1 - 31
    int M = month();  // Values from 1 - 12
    int Y = year();   // 2003, 2004, 2005, etc.

    int ms = millis();
    int s = second();  // Values from 0 - 59
    int m = minute();  // Values from 0 - 59
    int h = hour();    // Values from 0 - 23

    String fileName = String.format("Experiment %s_%s_%s_%s_%s_%s_%s.csv", Y, M, D, h, m, s, ms);    
    String basePath = Environment.getExternalStorageDirectory().getAbsolutePath();
    String directory = "/panorama_experiment/";
    String filePath = basePath + directory+ fileName; 

    output = createWriter(filePath);
  }

  boolean isReady() 
  {
    if (System.currentTimeMillis() - lastUpdate > 500) {
      lastUpdate = System.currentTimeMillis();
      return true;
    }
    return false;
  }

  void writeTime()
  {
    int D = day();    // Values from 1 - 31
    int M = month();  // Values from 1 - 12
    int Y = year();   // 2003, 2004, 2005, etc.

    int s = second();  // Values from 0 - 59
    int m = minute();  // Values from 0 - 59
    int h = hour();    // Values from 0 - 23

    output.print(String.format("TABLET,%s-%s-%s %s:%s:%s", Y, M, D, h, m, s));
  }

  void write(String text)
  {
    writeTime();
    output.print(String.format(",%s", text));
    output.println();
  }

  void writeVector(PVector vector, String name)
  {
    writeTime();
    output.print(String.format(",%s,%s,%s,%s", name, vector.x, vector.y, vector.z));
  }

  void writeOrientation(PVector local, PVector remote)
  {
    if (isReady()) {
      writeVector(local, "local");
      writeVector(remote, "remote");
      output.println();
    }
  }    
      
  void writeAnnotation(ANNOTATION_TYPE annotation, Point point){
    writeTime();
    output.print(String.format(",%s,%s,%s,%s,%s,%s", annotation, point.a, point.b, point.x, point.y, point.o));
    output.println();
    output.flush();
  }
  
  void writeClearAnnotation(){
    writeTime();
    output.print(String.format(",CLEAR"));
    output.println();
    output.flush();
  }

  void destroy()
  {
    output.flush(); // Writes the remaining data to the file
    output.close(); // Finishes the file
  }
}

