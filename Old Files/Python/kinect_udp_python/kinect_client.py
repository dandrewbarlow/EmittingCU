# Andrew Barlow
# Emitting CU
# Recieve kinect depth data over udp connection
# this script is for TouchDesigner

import sys
mypath = "/usr/local/lib/python3.9/site-packages/"
if mypath not in sys.path:
    sys.path.append(mypath)

import socket
import pickle
import numpy as np
import cv2 as cv
from PIL import Image

# udp socket 
sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
sock.bind(('localhost', 6969))


def receiveData():
    # put in try/catches for debugging

    # Get raw byte data from our socket, (max of 20,000 bytes)
    try:
        # for large packets, wait until it's complete
        # https://stackoverflow.com/questions/44637809/python-3-6-socket-pickle-data-was-truncated
        data = []
        while True:
            print("l")
            packet = sock.recvfrom(25000)
            if not packet: 
                print('break')
                break
            data.append(packet[0])
        
        # print(f'{type(data)} {data}')
    except Exception as err:
        print(f'{err}')
        return
    
    # use pickle library to decode data into PIL Image
    try:
        depickled = pickle.loads(data[0])
    except Exception as err:
        print(f'{err} depickle')
        return

    # jpg -> numpy array
    try:
        numpy_image = jpegToNpArray(depickled)
        return numpy_image 
    except Exception as err:
        print(f'{err} jpeg conversion')
        return

def npArrayToCV(img):
    img = img[:, :, ::-1].copy()
    return img

# convert PIL Image -> numpy array
def jpegToNpArray(img):
    try:
        return np.asarray(Image.open(img))
    except Exception as err:
        print(f'jpgToNpArray: {err}')

# main TouchDesigner loop
# def onCook(scriptOp):
#     pass

def main():
    data = receiveData()
    # print(type(data))
    # cv.imshow('Kinect Data', data)
    return data


def onCook(scriptOp):
    data = receiveData()
    scriptOp.copyNumpyArray(data)
    return

# continuous loop for testing outside of TD
try:
    while True:
        main()
except KeyboardInterrupt:
    print('\nKeyboard Interrupt Recieved. Stopping Program')
    cv.destroyAllWindows()
    exit(0)
except Exception as err:
    print(f'Error: {err}')
    exit(1)