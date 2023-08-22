export ROS_MASTER_URI=http://$(hostname):11311
export ROBOT_NAME=oas_uas8
if [ -f /home/uas/apps/robot_ws/devel/setup.bash ];then 
 	. /home/uas/apps/robot_ws/devel/setup.bash 
fi

