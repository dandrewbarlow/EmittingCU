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


int[] depth = kinect.getRawDepth();
