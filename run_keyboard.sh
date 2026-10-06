#!/usr/bin/env bash
source /opt/ros/humble/setup.bash
source /usr/share/gazebo/setup.sh
source ~/turtlebot3_ws/install/setup.bash
export TURTLEBOT3_MODEL=burger

ros2 run turtlebot3_teleop teleop_keyboard
