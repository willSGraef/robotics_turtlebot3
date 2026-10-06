#!/usr/bin/env bash
# Usage:  bash install.sh

# Install required packages
sudo dpkg --add-architecture armhf  
sudo apt-get update  
sudo apt-get install libc6:armhf  

# Specify burger for the model, and the port for the OpenCR board
export OPENCR_PORT=/dev/ttyACM0  
export OPENCR_MODEL=burger
rm -rf ./opencr_update.tar.bz2

# Download the latest OpenCR firmware update package and extract it
wget https://github.com/ROBOTIS-GIT/OpenCR-Binaries/raw/master/turtlebot3/ROS2/latest/opencr_update.tar.bz2   
tar -xvf opencr_update.tar.bz2 

# Upload the firmware to the OpenCR board
cd ./opencr_update  
./update.sh $OPENCR_PORT $OPENCR_MODEL.opencr 