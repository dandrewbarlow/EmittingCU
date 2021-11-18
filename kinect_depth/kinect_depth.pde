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

Boolean looping = false;

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
NetAddress userCountClient2;
NetAddress bradDepth;
NetAddress bradUserCount;

// define an easy to remember port to recieve the data over
int depthPortNumber = 10101;
int userCountPortNumber = 10102;

// the IP address of recieving computer
String clientIP = "192.168.1.65";
//String client2IP = "192.168.1.207";
String bradIP = "192.168.1.232";

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
    //userCountClient2 = new NetAddress(client2IP, userCountPortNumber);
    bradDepth = new NetAddress(bradIP, 7000);
    bradUserCount = new NetAddress(bradIP, 7001);
}

// main loop
void draw() {
    // draw a black background
    background(0);  

    // update kinect data
    kinect.update();
    if (!looping){
      println("looping");
      looping = true;
    }

    // get depth image from kinect
        // TODO: remove for final product.
        // only necessary to visualize depth data, adds extra cycles otherwise
    depthImage = kinect.depthImage();

    // get depth map array
    int[] depthMap = kinect.depthMap();

    // prepare the Depth pixels 
    depthImage.loadPixels();
    float depthSum = 0;
    int depthN = 0; 


    // if we have detected any users
    if (kinect.getNumberOfUsers() > 0) {

        // find out which pixels have users in them
        userMap = kinect.userMap();  

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
    }
        
     // calculate (sample) average depth
    float average = depthSum / depthN;
    float userCount = (float) kinect.getNumberOfUsers();

    // handling when user leaves frame
    if (Float.isNaN(average)) {
        average = 7500;
        userCount = 0;
    }
    
    // send OSC signals
    sendOSCData(depthClient, "/depth", average);
    sendOSCData(userCountClient, "/users", userCount);
    //sendOSCData(userCountClient2, "/users/", (float) kinect.getNumberOfUsers());
    
    sendOSCData(bradDepth, "/depth", average);
    sendOSCData(bradUserCount, "/users", userCount);


}

// sendOSCData() is a helper function to take the seperate components of a OSC message, combine, and send them
void sendOSCData(NetAddress client, String title, float message) {
  //if (title == "/users:
    println("OSC out -> " + client + " :  " + title + " : " + message);
    
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
