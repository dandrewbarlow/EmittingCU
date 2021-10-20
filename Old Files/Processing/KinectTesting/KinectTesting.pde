import org.openkinect.freenect.*;
import org.openkinect.freenect2.*;
import org.openkinect.processing.*;
import org.openkinect.tests.*;

import org.openkinect.processing.*;

Kinect kinect;

void setup() {
  size(640, 480);
  kinect = new Kinect(this);
  
  kinect.initDepth();
  // kinect.initDevice();
}

void draw() { 
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
