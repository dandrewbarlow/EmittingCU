
/*
Andrew Barlow
Kinect.pde

Trying to find an easy-ish way to send live video to Touchdesigner in a platform-agnostic way. 
Which turns out to not be very easy-ish

Using modified version of file written by group partner Madi Heath, who followed an internet tutorial.
Also using the internet for help, because I'm a goals oriented man, and this is an art project, not a coding one

Resources:
* sending live video over udp, with the sage wisdom of the man, the myth, the legend: Daniel Shiffman
https://shiffman.net/processing.org/udp/2010/11/13/streaming-video-with-udp-in-processing/

https://forum.processing.org/two/discussion/888/a-little-simplicity-with-syphon

*/

// IMPORTS ///////////////////////////////////////////////////////

// syphon is a osx specific video sharing solution
// hopefully removes the need for UDP, but idk, its no longer in Processing's official libraries so its a pain in the ass to setup

/* to install:
get Syphon.zip from the releases page on github:
https://github.com/Syphon/Processing/releases/tag/3
extract contents to ~/Documents/Processing/libraries/
it should have something like:
~/Documents/Processing/libraries/syphon/libraries/syphon.jar

after installing, Tim Cook personally spits in your face for trying to open an unsafe file.
you have to open each individually with the security settings open to manually allow each file in libraries/syphon/library
*/
import codeanticode.syphon.*;

// open kinect libraries
// must be downloaded
import org.openkinect.freenect2.*;
import org.openkinect.processing.*;
import org.openkinect.tests.*;

// OSC libraries
import netP5.*;
import oscP5.*;


// UDP library
// must be downloaded
import hypermedia.net.*;

// GLOBAL VARIABLES //////////////////////////////////////////////////

// instantiate kinect object
Kinect kinect;

KinectTracker kinectTracker;

SyphonServer server;
//PGraphics canvas;

// controls window visibility, in case you want to run in the background and just devote CPU to sending info over network
boolean visible;

OscP5 oscP5;
NetAddress myRemoteLocation;
/*
// define the UDP object
UDP udp; 
*/
// define an easy to remember port to recieve the video over
int portNumber = 6969;

String clientIP = "localhost";


// FUNCTIONS //////////////////////////////////////////////////

// convert depth array into the closest int
float getClosest(int[] array) {
  // int min = 2048;
  int[] topHundo = new int[100];
  int sum = 0;
  array = sort(array);
  for (int i = 0; i < 100; i++)
  {
    topHundo[i] = array[i];
    sum += array[i];
  }

  float average = sum / 100;
  float median = float(topHundo[49]);
   return median;
  //return average;
}

/*
// initUDP() is a small function to initialize a udp connection
void initUDP() {
  // create a new datagram connection on port 6000
  // and wait for incomming message
  udp = new UDP( this, 6000 );
  //udp.log( true );     // <-- printout the connection activity
  udp.listen( true );
}
*/


void setup() {
  size(640, 480, P2D);
  //canvas = createGraphics(640, 480, P2D);

  // construct kinect
  kinect = new Kinect(this);
  
  // use kinect's depth sensor
  //kinect.initVideo();
  kinect.initDepth();
  //kinect.enableIR(true);

  // kinectTracker = new KinectTracker();
  
  // OSC
  oscP5 = new OscP5(this,12000);
  myRemoteLocation = new NetAddress(clientIP, portNumber);

  // this I think just gets color image. leaving for reference
  // kinect.initDevice();
  
  visible = true;

  // bc td is weird about restarting syphon, give it a new name, so you can manually switch syphon stream
  server = new SyphonServer(this, "Kinect Syphon" + str(round(random(0, 999))));

  // show/hide draw window
  surface.setVisible(visible);
}

void draw() { 
  background(0);
  
  // kinectTracker.track();
  //PImage img = kinect.getVideoImage();//kinectTracker.display;
    PImage img = kinect.getDepthImage();

  // calculate closest depth int
  int [] rawDepth = kinect.getRawDepth();
  float minDepth = getClosest(rawDepth);
  OscMessage message = new OscMessage("/depth");
  message.add(minDepth);
  
  oscP5.send(message, myRemoteLocation);
  //println(minDepth);

  image(img, 0, 0);

  server.sendImage(img);
  //udp.send(str(random(100)) + "\n", clientIP, portNumber);
}

// Adjust the threshold with key presses
void keyPressed() {
  /*
  int t = kinectTracker.getThreshold();
  if (key == CODED) {
    if (keyCode == UP) {
      t+=5;
      kinectTracker.setThreshold(t);
    } else if (keyCode == DOWN) {
      t-=5;
      kinectTracker.setThreshold(t);
    }
  }
  */
}
