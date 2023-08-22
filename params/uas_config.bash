#!/bin/bash
echo "loading system params..."
# uas and networking
export ROSCore=True
export DJICore=True
export MultiMaster=True
export NetThread=False
# autonomy
export Simplenav=True
export BenchTest=True
export RobotState=True
export Swarm=False
export AprilTrack=False
export WirelessCharge=False
# sensors
export Spinnaker=True
export ZedCamera=False
export IRCamera=False
export Vn100=False
export Lidarlite=True
export Nmea_gps2=False
export Ublox_gnss=True
# processes for sensing
export YoloIR=False
export AprilTag=False
export PX4Flow=False
export OpticalFlow=False
# logging
export LogData=False

echo "system params all loaded"

