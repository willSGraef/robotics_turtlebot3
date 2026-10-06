#!/usr/bin/env bash
source /opt/ros/humble/setup.bash
source /usr/share/gazebo/setup.sh
source ~/turtlebot3_ws/install/setup.bash
export TURTLEBOT3_MODEL=burger

ros2 launch turtlebot3_gazebo empty_world.launch.py
