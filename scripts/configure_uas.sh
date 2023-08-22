#!/bin/bash
##### input arguments are '$1 :lab_name' '$2 :device_type' '$3 :id_or_serial_number'
# example
# $./configure_uas.sh frl tx2 6
set_robot_name=$1_uas$3
robot_config_file=/home/uas/apps/main_ws/src/uas_utils/cfg/robot_config
# set ROBOT_NAME
if [ -f $robot_config_file ]; then
	grep -q "export ROBOT_NAME" $robot_config_file
	if [ $? -eq 0 ]
	then
		sed -i "s/export ROBOT_NAME=.*/export ROBOT_NAME=$set_robot_name/" $robot_config_file
	else
		echo -e "\nexport ROBOT_NAME=$set_robot_name" >> $robot_config_file
	fi
else
	echo 'cannot find <uas_utils>/cfg/robot_config, creating one'
	echo -e "\nexport ROS_MASTER_URI=http://\$(hostname):11311" >> $robot_config_file
	echo -e "export ROBOT_NAME=$set_robot_name" >> $robot_config_file
	echo -e "if [ -f /home/uas/apps/robot_ws/devel/setup.bash ];then \n \t. /home/uas/apps/robot_ws/devel/setup.bash \nfi\n" >> $robot_config_file
fi
