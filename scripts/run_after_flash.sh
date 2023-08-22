#!/bin/bash
# @author Mithun Diddi @ Open autonomous systems llc 

##### input arguments are '$1 :lab_name' '$2 :device_type' '$3 :id_or_serial_number'
# example
# $./run_after_flash.sh oas tx2 6
# where frl is lab name. device name is tx2 and serial number of uas is 6
# so device properties are set in following convention
#hostname: frl-tx26
#robot_name: frl_uas6
#robot_ip_eth0: 192.168.0.36 (defaults) [prefix uas_starting_ip=30 in our static rules]
# under the assumption in router you set static ip for wlan0 of uas as 192.168.1.36
# in case if you need to change subnet. feel free to modify below set_robot_wlan0_subnet, set_robot_eth0_subnet

set_robot_wlan0_subnet=192.168.1
set_robot_eth0_subnet=192.168.0
# add prefix of 30 to ip of uas respective subnet
uas_starting_ip=30

set_robot_wlan0_ip=$set_robot_wlan0_subnet.$(($3+$uas_starting_ip))
set_robot_eth0_ip=$set_robot_eth0_subnet.$(($3+$uas_starting_ip))

set_hostname=$1-$2$3
set_robot_name=$1_uas$3

echo "hostname", $set_hostname
echo "robot_name", $set_robot_name
echo "robot eth0 ip address",  $set_robot_eth0_ip
echo "robot wlan0 ip address", $set_robot_wlan0_ip

# set hostname in /etc/hostname
echo $set_hostname > /etc/hostname || { echo run with sudo previlages; exit 0; }

# resolve hostname in /etc/hosts file
sed -i "s/127.0.1.1 .*/127.0.1.1 $set_hostname/" /etc/hosts || { echo run with sudo previlages; exit 0; }

grep -q $set_robot_wlan0_ip /etc/hosts
if [ $? -eq 0 ]
then
	sed -i "s/$set_robot_wlan0_ip .*/$set_robot_wlan0_ip $set_hostname/" /etc/hosts
else
	echo -e "\n$set_robot_wlan0_ip $set_hostname" >> /etc/hosts
fi

# set static ip for eth0 port for debugging and data transfer
# our default subnet is 192.168.0.x, as in system image.
sed -i "/iface eth0 inet static/,/broadcast 192.168.0.255/{/broadcast 192.168.0.255/ s/.*/iface eth0 inet static\n\taddress "$set_robot_eth0_ip"\n\tnetmask 255.255.255.0\n\tbroadcast "$set_robot_eth0_subnet.255"/;t;d}" /etc/network/interfaces || { echo run with sudo previlages; exit 0; }

# set ROBOT_NAME
if [ -f /home/uas/apps/main_ws/src/uas_utils/cfg/robot_config ]; then
	grep -q "export ROBOT_NAME" /home/uas/apps/main_ws/src/uas_utils/cfg/robot_config
	if [ $? -eq 0 ]
	then
		sed -i "s/export ROBOT_NAME=.*/export ROBOT_NAME=$set_robot_name/" /home/uas/apps/main_ws/src/uas_utils/cfg/robot_config
	else
		echo -e "\nexport ROBOT_NAME=$set_robot_name" >> /home/uas/apps/main_ws/src/uas_utils/cfg/robot_config
	fi
else
	robot_config_file=/home/uas/apps/main_ws/src/uas_utils/cfg/robot_config
	echo 'cannot find <uas_utils>/cfg/robot_config, creating one'
	echo -e "\nexport ROS_MASTER_URI=http://\$(hostname):11311" >> $robot_config_file
	echo -e "export ROBOT_NAME=$set_robot_name" >> $robot_config_file
	echo -e "if [ -f /home/uas/apps/robot_ws/devel/setup.bash ];then \n \t. /home/uas/apps/robot_ws/devel/setup.bash \nfi\n" >> $robot_config_file
fi

echo "system configured sucess"
echo "configure your sensors"