import processing.opengl.*;
import SimpleOpenNI.*;

// OSC libraries
import netP5.*;
import oscP5.*;

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

void setup() {
    size(640, 480);
    kinect = new SimpleOpenNI(this);
    kinect.enableDepth();
    kinect.enableUser();
    // OSC Setup
    oscP5 = new OscP5(this,12000);
    myRemoteLocation = new NetAddress(clientIP, portNumber);
}

void draw() {
    background(0);  
    kinect.update();
    depthImage = kinect.depthImage();
    int[] depthMap = kinect.depthMap();
    // prepare the Depth pixels 
    depthImage.loadPixels();
    // if we have detected any users
    if (kinect.getNumberOfUsers() > 0) {
        // find out which pixels have users in them
        userMap = kinect.userMap();  
        float depthSum = 0;
        int depthN = 0; 
        // populate the pixels array
        // from the sketch's current contents
        loadPixels();  
        for (int i = 0; i < userMap.length; i++) {
            // if the current pixel is on a user
            if (userMap[i] != 0) {
                pixels[i] = depthImage.pixels[i];
                // random sampling of depth to create representative sample mean of depth
                // done for performance mainly
                if (random(0, 1) < 0.05) {
                    depthSum += (float) depthMap[i];
                    depthN++;
                }
            }
        }
        // display the changed pixel array
        updatePixels();

        float average = depthSum/depthN;
        println("Average Depth=", average, " N=", depthN);

        OscMessage message = new OscMessage("/depth");
        message.add(average);
        oscP5.send(message, myRemoteLocation);
    }
}
void onNewUser(int uID) {
    userID = uID;
    println("tracking");
}