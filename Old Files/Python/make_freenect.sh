#! /bin/bash
# Andrew Barlow
# Emmiting CU

# script to compile python wrappers for libfreenect on mac os
# make sure to run this script from the directory it is inside, I didn't go through the trouble to fuck with making this too robust

# hombrew, python, cmake, libusb, and the main libfreenect must be installed before this. 
# Homebrew must be installed manually, the rest are installable through homebrew (brew install cmake, etc)

# if important tasks fail, early exit

root_dir="$(pwd)"

pip3 install -r requirements.txt || exit 1
git clone https://github.com/openkinect/libfreenect --depth 1 || exit 1
cd libfreenect
mkdir build
cd build

cmake .. -DBUILD_PYTHON3=ON || exit 1

make || exit 1

cd wrappers/python/python3
make install
# im 90% sure this is the correct amount of directory 
# cp freenect.so "$root_dir"
# cd "$root_dir"
rm -rf libfreenect || echo "error removing libfreenect repo file"

echo "Script complete"
