# libfreenect Python Wrappers Info

For Mac users, libfreenect is the easiest way to access kinect data. Since touchdesigner allows python scripting, and libfreenect has python wrappers, I've decided the easiest solution is to follow that route and create a python script for touchdesigner that can avoid overhead from sending the video feed through a bunch of apps. Unfortunately, the process of getting these python wrappers is somewhat involved.

I've made a shell script to automate this process, but it still requires basic dependencies be installed first, (Homebrew, python, cmake, & libusb)

## Install libfreenect

I reccomend using homebrew for the least amount of trouble

`brew install libfreenect`

## Making Python Wrappers

This is the tricky part. You gotta build them yourself. I'll lay out how I did it.

### Install Dependencies

* Available through homebrew
  * python obviously
  * cmake
  * libusb
* Python Dependencies
  * cython
  * numpy
  * opencv is optional but recommended
  * `pip3 install cython numpy opencv-python`

### Build Python Wrappes

* Download libfreenect Github repository
  * `git clone https://github.com/openkinect/libfreenect`
* `cd libfreenect`
* `mkdir build`
* `cd build`
* `cmake .. -DBUILD_PYTHON3=ON`
* `make`
* `cd wrappers/python/python3`
  * Here there should be a file called `freenect.so`. This is the new library file. 

Now you can move that library file, `freenect.so`, wherever your python script is, and import it in Python by calling `import freenect`.
