
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


// CLASSES //////////////////////////////////////////////////

// handler for syphon
// https://forum.processing.org/two/discussion/888/a-little-simplicity-with-syphon
class SFD{
  
  public SyphonServer server;
  PApplet p;
  
  SFD(PApplet p){
    this.p = p;
    // Create syhpon server to send frames out.
    server = new SyphonServer(p, "Processing Syphon");
  }
  
  void send() {
     send(p.g); 
  }
  
  void send(PGraphics g){
     server.sendImage(g);
  } 

  //void update(){
  //  that.loadPixels();
  //  canvas.loadPixels();
  //  for(int i=0;i<that.pixels.length;i++){
  //    canvas.pixels[i] = that.pixels[i];
  //  }
  //  canvas.updatePixels();
  //  server.sendImage(canvas);
  //}
}

// GLOBAL VARIABLES //////////////////////////////////////////////////

// instantiate kinect object
Kinect kinect;

// var to help me mess with video w/o worrying about syphon
boolean debug_video = true;

// syphon handler
//SFD send;
SyphonServer server;
PGraphics canvas;
// define the UDP object
// UDP udp; 

// controls window visibility, in case you want to run in the background and just devote CPU to sending info over network
boolean visible;

// ternary if to set window visibility


// define an easy to remember port to recieve the video over
int portNumber = 6969;


// FUNCTIONS //////////////////////////////////////////////////

void setup() {
  size(640, 480, P2D);
  canvas = createGraphics(640, 480, P2D);

  // construct kinect
  kinect = new Kinect(this);
  
  // use kinect's depth sensor
  kinect.initDepth();

  // this I think just gets color image. leaving for reference
  // kinect.initDevice();
  
  // if (debug_video) {visible = true;} else {visible = false;}
  visible = true;
  //send = new SFD(this);
  server = new SyphonServer(this, "Kinect Syphon");

  // show/hide draw window
  surface.setVisible(visible);
}

void draw() { 
  background(0);
  
  PImage img = kinect.getDepthImage();

  if (visible) {
    //canvas.image(img,0,0);
  }

  //if (!debug_video) {send.send();}
  server.sendImage(img);
}
