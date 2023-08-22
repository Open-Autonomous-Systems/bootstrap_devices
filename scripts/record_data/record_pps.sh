#! /bin/bash
robot_ns=/$ROBOT_NAME
rosbag record -b 0 \
$robot_ns/camera \
$robot_ns/camera_array/cam0/camera_info \
$robot_ns/camera_array/cam0/image_raw \
$robot_ns/camera_array/cam1/camera_info \
$robot_ns/camera_array/cam1/image_raw \
$robot_ns/acquisition_node/parameter_descriptions \
$robot_ns/acquisition_node/parameter_updates \
$robot_ns/dji_sdk/battery_state \
$robot_ns/dji_sdk/flight_status \
$robot_ns/dji_sdk/gps_health \
$robot_ns/dji_sdk/gps_position \
$robot_ns/dji_sdk/height_above_takeoff \
$robot_ns/dji_sdk/imu \
$robot_ns/dji_sdk/rc \
$robot_ns/dji_sdk/velocity \
$robot_ns/lidarlite/range/down \
$robot_ns/simplenav/odom \
$robot_ns/extended_fix \
$robot_ns/fix

