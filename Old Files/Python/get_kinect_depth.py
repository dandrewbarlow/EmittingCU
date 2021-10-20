'''
Andrew Barlow
Emmitting CU

Script to get Kinect -> Touchdesigner on a mac
'''

import sys

# help touchdesigner find package
mypath = "/Users/Andrew/Dropbox/Classes/CTD/Capstone/Python"
if mypath not in sys.path:
    sys.path.append(mypath)

from freenect import sync_get_depth as get_depth
import cv2 as cv
import numpy as np

# get a numpy array of kinect's depth image
# def getDepthArray():
    # global depth
    # (depth,_) = get_depth()
    # return np.dstack((depth, depth, depth)).astype(uint8)
  
# TouchDesigner loop
def onCook(scriptOp):
    return get_depth()


'''
def doloop():
    global depth, rgb
    while True:
        # Get a fresh frame
        (depth,_), (rgb,_) = get_depth(), get_video()
        
        # Build a two panel color image
        d3 = np.dstack((depth,depth,depth)).astype(np.uint8)
        da = np.hstack((d3,rgb))
        
        # Simple Downsample
        cv.ShowImage('both',np.array(da[::2,::2,::-1]))
        cv.WaitKey(5)
'''