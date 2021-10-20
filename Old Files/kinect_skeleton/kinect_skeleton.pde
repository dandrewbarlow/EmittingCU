
/*
Andrew Barlow
Kinect.pde

Trying to find an easy-ish way to send live video to Touchdesigner in a platform-agnostic way. 
Which turns out to not be very easy-ish

Also using the internet for help, because I'm a goals oriented man, and this is an art project, not a coding one

Resources:
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

// simpleopenNI - kinect library
import processing.opengl.*;
import SimpleOpenNI.*;

// OSC libraries
import netP5.*;
import oscP5.*;


// GLOBAL VARIABLES //////////////////////////////////////////////////

SimpleOpenNI kinect;

PImage userImage;
int userID;
int[] userMap;
PImage depthImage;

OscP5 oscP5;
NetAddress myRemoteLocation;

// define an easy to remember port to recieve the video over
int portNumber = 6969;

String clientIP = "localhost";

// SyphonServer server;

// debugging bools

boolean syphon = false;
boolean osc = true;

// FUNCTIONS //////////////////////////////////////////////////
// float averageDepth(){}

void setup() {
  // Processing Setup
  size(640, 480, P2D);


  // Kinect Setup
  kinect = new SimpleOpenNI(this);
  kinect.enableDepth();
  kinect.enableUser();

  // OSC Setup
  if (osc) {
    oscP5 = new OscP5(this,12000);
    myRemoteLocation = new NetAddress(clientIP, portNumber);
  }

  // Syphon Setup
    // bc td is weird about restarting syphon, give it a new name, so you can manually switch syphon stream
  // if (syphon) {
  //   String serverName = "Kinect Syphon" + str(round(random(0, 999)));
  //   println("Server Name: " + serverName);
  //   server = new SyphonServer(this, serverName);
  // }

}

// getSkeletonDepth 
void getSkeletonDepth() {

  // PImage userDepthImage = createImage(640, 480, RGB);

  // load depthImage
  depthImage = kinect.depthImage();
  int[] depthMap = kinect.depthMap();

  // prepare the Depth pixels 
  depthImage.loadPixels();


  if (kinect.getNumberOfUsers() > 0) {  

    // find out which pixels have users in them
    userMap = kinect.userMap();

    // for calculating average depth of user
    float depthSum = 0;
    int depthN = 0;

    // userDepthImage.loadPixels();
    loadPixels();

    for (int i = 0; i < userMap.length; i++) {

      // if the current pixel is on a user
      if (userMap[i] != 0) {

        // draw depth of user
        pixels[i] = depthImage.pixels[i];

        // random sampling of depth to create representative sample mean of depth
        // done for performance mainly
        if (osc && random(0, 1) < 0.05 ) {
          depthSum += (float) depthMap[i];
          depthN++;
        }

      }
    }
    updatePixels();

    // calculate average & send it over OSC connection
    if (osc) {
      float average = depthSum/depthN;
      println("Average Depth=", average, " N=", depthN);

      OscMessage message = new OscMessage("/depth");
      message.add(average);
      oscP5.send(message, myRemoteLocation);
    }

   }

  // return userDepthImage;

}

void draw() {

  background(0);

  kinect.update();

  getSkeletonDepth();

  // draw image to screen
  // image(img, 0, 0);

  // if (syphon) {
  //   server.sendScreen();
  // }

}

void onNewUser(int uID) {
  userID = uID;
  println("tracking");
}