#!/bin/bash

#### suppress warnings onto console########################
echo "3" > /proc/sys/kernel/printk

#################### Wait until time is synced ##############
# check if time is synced with NTP server or remote or GPS time

if [ -x /usr/bin/timedatectl ]; then
    FLAG_TIME_SYNCED=False
    while [ $FLAG_TIME_SYNCED ];do
        # Determine sync status using timedatectl
        # ubuntu 16, check for NTP synchronized: yes
        # in ubuntu 18, it's System clock synchronized: yes
        if /usr/bin/timedatectl status | grep -q "synchronized: yes"; then
            FLAG_TIME_SYNCED=True;
            echo "Time Synced with NTP";
            break;
        elif /usr/bin/timedatectl status | grep -q "synchronized: no"; then
            sleep 1;
        fi
    done;
fi

# Works only for system(s) without RTC installed and initial data is before
# 2016(eg), and in chrony, if save last sync/ known time to RTC is set to false
# eg: nvidia tx2

while [ "$(date +"%Y")" -le 2016 ];do 
    sleep 1;
done
echo "Time Synced"

#################### Set up environment ####################
source /opt/ros/melodic/setup.bash

# load robot config and ws parameters
if [ -f /home/uas/apps/main_ws/src/uas_utils/cfg/robot_config ]; then
    . /home/uas/apps/main_ws/src/uas_utils/cfg/robot_config
fi

# load current mission requirements
if [ -f /home/uas/apps/main_ws/src/uas_utils/params/uas_config.bash ]; then
    . /home/uas/apps/main_ws/src/uas_utils/params/uas_config.bash
fi

##### wait until ir cam is connected#####

while [ "$IRCamera" = True ] ;do
   if [ -c /dev/video* ]; then
        printf '%s\n' "ir cam connected"
        break;
    else
        printf '%s\n' "waiting for IR camera"
        sleep 5
    fi
done
##### wait until zed cam is connected#####
export ZedCamera_configured=False
while [ "$ZedCamera" = True ] ;do
   for file in /dev/videoZEDM*; do
    if [ -c "$file" ]; then
        printf '%s\n' "ZED cam connected"
        ZedCamera_configured=True
        break;
    else
        printf '%s\n' "waiting for ZED camera"
        sleep 5
    fi
   done
   if [ "$ZedCamera_configured" = True ]; then
    break;
   fi
done
##### wait until balckfly s cam is connected#####
if [ "$Spinnaker" = True ]; then
    printf '%s\n' "waiting for blackfly camera"
    sleep 5
fi
##### wait until vn100_imu is live #####
while [ "$Vn100" = True ] ;do
   if [ -c /dev/ttyUSB* ]; then
        printf '%s\n' "vn100_imu connected"
	chmod 666 /dev/ttyUSB*;
        break;
    else
        printf '%s\n' "waiting for vn100_imu"
        sleep 5
    fi
done
##### wait until nmea_gps is live #####
export Nmea_gps2_configured=False
while [ "$Nmea_gps2" = True ] ;do
  for file in /dev/ttyACM*; do
   if [ -c "$file" ]; then
    printf '%s\n' "NMEA GPS connected"
	chmod 666 "$file";
	Nmea_gps2_configured=True
    break;
   else
    printf '%s\n' "waiting for NMEA GPS"
    sleep 5
   fi
  done
  if [ "$Nmea_gps2_configured" = True ]; then
    break;
  fi
done
### Ublox_gnss ####
while [ "$Ublox_gnss" = True ] ;do
   if [ -c /dev/ttyUblox ]; then
        printf '%s\n' "Ublox_gnss connected";
	systemctl restart gpsd.service;
	printf '%s\n' "gpsd service restarted";
	while ! echo exit | nc -q 1 localhost 2947 > /dev/null;do
		printf '%s\n' "waiting for gpsd socket";
    	sleep 1;
    done
        
    printf '%s\n' "gpsd socket is online";
        
    break;
    else
        printf '%s\n' "waiting for Ublox_gnss"
        sleep 5
    fi
done

#####configure mesh network openmesh #####
if [ "$NetThread" = True ]; then
    wpantund -o Config:NCP:SocketPath /dev/ttyACM0 -o Config:TUN:InterfaceName utun7 -o Daemon:SyslogMask " -debug" &
    sleep 5
fi
#### start from here ########
if [ "$ROSCore" = True ]; then
    # rotate logs, up to 3 times of boot history
    if [ ! -d /home/uas/log_files ];then
        mkdir /home/uas/log_files
    fi
    
    if [ -f /home/uas/log_files/last.log ]; then
        mv /home/uas/log_files/last.log /home/uas/log_files/last2.log
    fi
    
    if [ -f /home/uas/log_files/current.log ]; then
        mv /home/uas/log_files/current.log /home/uas/log_files/last.log
        touch /home/uas/log_files/current.log
    else
        touch /home/uas/log_files/current.log
    fi

    # starting roscore
    roscore &
    while ! echo exit | nc localhost 11311 > /dev/null;do
        sleep 1;
    done
    # wait for ros out 
    sleep 1;
    
    echo "starting master launch"
    roslaunch uas_utils master_robotwide.launch --wait > /home/uas/log_files/current.log 2>&1 &

    sleep 10

    robot_ns=/$ROBOT_NAME
    
    #################### Log if a SD card on the drone ####################
    if [ $LogData = True ]; then
        if mountpoint -q /mnt/data; then
            bagpath="/mnt/data/"
        else
            bagpath="/home/uas/log_files/"
        fi
        echo "start logging..."
    else
        echo "Logging not requested, quit now!!"
    fi

    echo "all jobs finished"
fi

### Keep the Script Running for simple systemd service ###
while true; do
    sleep 10
done
