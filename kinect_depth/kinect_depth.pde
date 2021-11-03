// kinect_depth.pde
// Emitting CU
// A file to get depth data of people from a kinect and send said data to another machine creating visuals over an OSC connection.
// utilizes the SimpleOpenNI library for Kinect interaction, because it has skeleton tracking, making it much easier to obtain consistent depth data.

// IMPORTS //////////////////////////////////////////////////

// SimpleOpenNI
import processing.opengl.*;
import SimpleOpenNI.*;

// OSC libraries
import netP5.*;
import oscP5.*;

// VARIABLES //////////////////////////////////////////////////

// kinect object
SimpleOpenNI kinect;

// variable to store images. 1 for skeleton data, 1 for depth data
    // TODO: Remove these. Not necessary, only map data arrays needed
PImage userImage;
PImage depthImage;

int userID;

// userMap is an array that maps a percieved skeleton to an int corresponding to a pixel
int[] userMap;

// OSC object
OscP5 oscP5;

// used to simplify network logic
NetAddress depthClient;
NetAddress userCountClient;

// define an easy to remember port to recieve the data over
int depthPortNumber = 6969;
int userCountPortNumber = 7000;

// the IP address of recieving computer
String clientIP = "localhost";

// FUNCTIONS //////////////////////////////////////////////////

// Initialization
void setup() {
    // limited by Kinect v1 resolution. Changable for v2
    // TODO: possibly movable to settings/preload funtion
    size(640, 480);

    // initialize kinect
    kinect = new SimpleOpenNI(this);

    // enable depth data and skeleton tracking
    kinect.enableDepth();
    kinect.enableUser();

    // OSC initialization
    oscP5 = new OscP5(this,12000);
    depthClient = new NetAddress(clientIP, depthPortNumber);
    userCountClient = new NetAddress(clientIP, userCountPortNumber);
}

// main loop
void draw() {
    // draw a black background
    background(0);  

    // update kinect data
    kinect.update();
    println("loop");

    // get depth image from kinect
        // TODO: remove for final product.
        // only necessary to visualize depth data, adds extra cycles otherwise
    depthImage = kinect.depthImage();

    // get depth map array
    int[] depthMap = kinect.depthMap();

    // prepare the Depth pixels 
    depthImage.loadPixels();

    // if we have detected any users
    if (kinect.getNumberOfUsers() > 0) {

        // find out which pixels have users in them
        userMap = kinect.userMap();  
        float depthSum = 0;
        int depthN = 0; 

        // populate the pixels array from the sketch's current contents
            // TODO: remove unnecessary visuals
        loadPixels();  

        // loop through userMap
        for (int i = 0; i < userMap.length; i++) {

            // if the current pixel is on a user
            if (userMap[i] != 0) {

                // TODO: Remove extra visuals
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
            // TODO: no need to draw anything
        updatePixels();
        
        // calculate (sample) average depth
        float average = depthSum / depthN;
        println("Average Depth=", average, " N=", depthN);
        
        // send OSC signals
        sendOSCData(depthClient, "/depth", average);
        sendOSCData(userCountClient, "/users", (float) kinect.getNumberOfUsers());
    }
}

// sendOSCData() is a helper function to take the seperate components of a OSC message, combine, and send them
void sendOSCData(NetAddress client, String title, float message) {

    // create new OSC message, with given title
    OscMessage m = new OscMessage(title);

    // add message param 
    m.add(message);

    // send over network
    oscP5.send(m, client);
}

// Imma keep it real. I forget why I included this. I think this is boilerplate from SimpleOpenNI's documentation
void onNewUser(int uID) {
    userID = uID;
    println("tracking");
}