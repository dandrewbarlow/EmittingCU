
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

// open kinect libraries
// must be downloaded
import org.openkinect.freenect2.*;
import org.openkinect.processing.*;
import org.openkinect.tests.*;

// UDP library
// must be downloaded
import hypermedia.net.*;

// Java image libraries
// doesn't need to be downloaded
import java.awt.image.BufferedImage;
import javax.imageio.*;
import java.io.*;
import java.awt.image.*; 
import java.nio.ByteBuffer;


// GLOBAL VARIABLES //////////////////////////////////////////////////

// instantiate kinect object
Kinect kinect;

// define the UDP object
 UDP udp; 

// controls window visibility, in case you want to run in the background and just devote CPU to sending info over network
boolean visible = true;

// define an easy to remember port to recieve the video over in another application
int portNumber = 6969;

String clientIP = "localhost";


// FUNCTIONS //////////////////////////////////////////////////

// imgToJPG(PImage img) converts an image to jpg to speed up UDP transmission, returning a ByteBuffer of the image
byte[] imgToJPG(PImage img) {
  int w = img.width;
  int h = img.height;
  BufferedImage b = new BufferedImage(w, h, BufferedImage.TYPE_INT_RGB);

  img.loadPixels();
  b.setRGB(0, 0, w, h, img.pixels, 0, w);

  // ByteArrayOutputStream baStream = new ByteArrayOutputStream();
  // BufferedOutputStream bos = new BufferedOutputStream(baStream);

  ByteArrayOutputStream baStream = new ByteArrayOutputStream();
  // ByteArrayOutputStream bos = new ByteArrayOutputStream;

  try {
    ImageIO.write(b, "jpg", baStream);
  } catch (IOException e) {
    e.printStackTrace();
  }

  byte[] out = baStream.toByteArray();
  return out;
}

// initUDP() is a small function to initialize a udp connection
void initUDP() {
  // create a new datagram connection on port 6000
  // and wait for incomming message
  udp = new UDP( this, 6000 );
  //udp.log( true );     // <-- printout the connection activity
  udp.listen( true );
}

void setup() {
  size(640, 480, P2D);

  // construct kinect
  kinect = new Kinect(this);
  
  // use kinect's depth sensor
  kinect.initDepth();

  // this I think just gets color image. leaving for reference
  // kinect.initDevice();
  
   initUDP();

  // hide/show draw window
  surface.setVisible(visible);
}

void draw() { 
  background(0);
  
  PImage img = kinect.getDepthImage();
  if (visible) {
    image(img,0,0);
  }

  // in 2 fell strokes, convert the image to a jpg and send it over udp
   udp.send(imgToJPG(img), clientIP, portNumber);
}
