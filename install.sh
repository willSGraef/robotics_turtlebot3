#!/usr/bin/env bash
# ROS 2 Humble + Gazebo Classic + TurtleBot3 simulation installer
# Target: Ubuntu 22.04 (including WSL2)
#
# References:
#   https://docs.ros.org/en/humble/Installation/Ubuntu-Install-Debs.html
#   https://docs.robotis.com/docs/systems/turtlebot3/quick_start_guide/pc_setup/
#   https://docs.robotis.com/docs/systems/turtlebot3/simulation/gazebo_simulation
#
# Usage:  bash install.sh

set -e

# Append a line to ~/.bashrc only if it isn't already there
add_to_bashrc() {
  grep -qxF "$1" ~/.bashrc || echo "$1" >> ~/.bashrc
}

echo "=== Set locale (UTF-8) ==="
sudo apt update && sudo apt install -y locales
sudo locale-gen en_US en_US.UTF-8
sudo update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8
export LANG=en_US.UTF-8

echo "=== Enable Ubuntu Universe repository ==="
sudo apt install -y software-properties-common
sudo add-apt-repository -y universe

echo "=== Install ros-apt-source package ==="
sudo apt update && sudo apt install -y curl
export ROS_APT_SOURCE_VERSION=$(curl -s https://api.github.com/repos/ros-infrastructure/ros-apt-source/releases/latest | grep -F "tag_name" | awk -F'"' '{print $4}')
curl -L -o /tmp/ros2-apt-source.deb "https://github.com/ros-infrastructure/ros-apt-source/releases/download/${ROS_APT_SOURCE_VERSION}/ros2-apt-source_${ROS_APT_SOURCE_VERSION}.$(. /etc/os-release && echo ${UBUNTU_CODENAME:-${VERSION_CODENAME}})_all.deb"
sudo dpkg -i /tmp/ros2-apt-source.deb

echo "=== Update and upgrade ==="
sudo apt update
sudo apt upgrade -y

echo "=== Install ROS 2 Humble Desktop (already includes ros-base) ==="
sudo apt install -y ros-humble-desktop
# Only needed on its own for headless installs; included in desktop:
# sudo apt install -y ros-humble-ros-base

echo "=== Install development tools ==="
sudo apt install -y ros-dev-tools

echo "=== Install Gazebo ==="
sudo apt install -y 'ros-humble-gazebo-*'

echo "=== Install Cartographer ==="
sudo apt install -y ros-humble-cartographer
sudo apt install -y ros-humble-cartographer-ros

echo "=== Install Navigation2 ==="
sudo apt install -y ros-humble-navigation2
sudo apt install -y ros-humble-nav2-bringup

echo "=== Install TurtleBot3 packages (from source) ==="
source /opt/ros/humble/setup.bash
mkdir -p ~/turtlebot3_ws/src
cd ~/turtlebot3_ws/src/
[ -d DynamixelSDK ]    || git clone -b humble https://github.com/ROBOTIS-GIT/DynamixelSDK.git
[ -d turtlebot3_msgs ] || git clone -b humble https://github.com/ROBOTIS-GIT/turtlebot3_msgs.git
[ -d turtlebot3 ]      || git clone -b humble https://github.com/ROBOTIS-GIT/turtlebot3.git
sudo apt install -y python3-colcon-common-extensions
cd ~/turtlebot3_ws
colcon build --symlink-install
add_to_bashrc 'source ~/turtlebot3_ws/install/setup.bash'

echo "=== Set up ROS environment ==="
add_to_bashrc 'export ROS_DOMAIN_ID=30 #TURTLEBOT3'
add_to_bashrc 'source /usr/share/gazebo/setup.sh'
add_to_bashrc 'source /opt/ros/humble/setup.bash'
set +e
source ~/.bashrc
set -e

echo "=== Install TurtleBot3 simulation package ==="
cd ~/turtlebot3_ws/src/
[ -d turtlebot3_simulations ] || git clone -b humble https://github.com/ROBOTIS-GIT/turtlebot3_simulations.git
cd ~/turtlebot3_ws
# The build sometimes needs to be run twice because of a CMake warning
colcon build --symlink-install || colcon build --symlink-install

cat <<'EOF'

=============================================================
Install complete. Open a NEW terminal (or run: source ~/.bashrc)

Terminal 1 - run the simulation (TurtleBot3 World):
    export TURTLEBOT3_MODEL=waffle
    ros2 launch turtlebot3_gazebo turtlebot3_world.launch.py

Terminal 2 - keyboard teleoperation (keep this terminal focused):
    export TURTLEBOT3_MODEL=waffle
    ros2 run turtlebot3_teleop teleop_keyboard

Other simulations are listed at:
https://docs.robotis.com/docs/systems/turtlebot3/simulation/gazebo_simulation?ros=humble
=============================================================
EOF
