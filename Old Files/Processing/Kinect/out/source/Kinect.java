import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import org.openkinect.freenect.*; 
import org.openkinect.freenect2.*; 
import org.openkinect.processing.*; 
import org.openkinect.tests.*; 
import org.openkinect.processing.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class Kinect extends PApplet {








Kinect kinect;

public void setup() {
  
  kinect = new Kinect(this);
  
  kinect.initDepth();
  // kinect.initDevice();
}

public void draw() { 
  background(0);
  
  PImage img = kinect.getDepthImage();
  image(img,0,0);
  
  int skip = 20;
  for (int x = 0; x < img.width; x+=skip) {
    for (int y = 0; y < img.height; y+=skip) { 
      int index = x + y * img.width;
      //int col = img.pixels[index];
      float b = brightness(img.pixels[index]);
      float z = map(b, 0, 255, 250, -250);
      fill(b-255);
      pushMatrix();
      translate(x, y, z); 
      rect(0,0, skip/2, skip/2);
      popMatrix();
    }
  }  
}
  public void settings() {  size(640, 480); }
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "Kinect" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
