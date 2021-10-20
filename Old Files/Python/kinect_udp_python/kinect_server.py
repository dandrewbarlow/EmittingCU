# Andrew Barlow
# Emitting CU
# send live kinect depth data as np array over UDP connection
# using pickle to encode/decode on both server & client

from freenect import sync_get_depth as get_depth
from frame_convert import *
import socket
import pickle
import io
from PIL import Image
# import cv2 as cv

# nice but not working :(
from rich.traceback import install
install()



import numpy as np
# pretty error messages
# defs not necessary

settings = {
    # https://stackoverflow.com/questions/48974070/object-transmission-in-python-using-pickle
    "MAX_UDP_SIZE" : 65507,

    "UDP_IP" : "localhost",
    "UDP_PORT" : 6969
}

socketSender = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)

def npArrayToJPG(array):
    img = Image.fromarray(array)
    buffer = io.BytesIO()
    img.save(buffer, format="JPEG")
    # compressed_array = np.asarray(Image.open(buffer))
    return buffer


def getData():
    (depth,_) = get_depth()
    data = np.dstack((depth, depth, depth)).astype(np.uint8)
    compressed_data = npArrayToJPG(data)
    return pickle.dumps(compressed_data)

def main():
    data = getData()

    # don't send data that goes over udp max rate
    if len(data) < settings["MAX_UDP_SIZE"]:
        print(f'data size: {len(data)}')
        socketSender.sendto(data, (settings["UDP_IP"], settings["UDP_PORT"]))
    else:
        overage = len(data) - settings["MAX_UDP_SIZE"]
        percentage = overage * 100 / len(data)
        print( f"Error: data is {overage} over maximum size: size({len(data)}) overage/size({percentage})" )

try:
    # continuous loop
    while True:
        main()
except KeyboardInterrupt:
    print('\nKeyboard Interrupt Received. Stopping Program')
    exit(0)
except Exception as err:
    print(f'Error: {err}')
    exit(1)