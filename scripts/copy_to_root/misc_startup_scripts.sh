#! /bin/bash
# to be run at startup
## to supress or limit msgs by changing console logging level 
echo "3" > /proc/sys/kernel/printk
## for multicast and fkie_multi_master_discovery
route add -net 224.0.0.0 netmask 224.0.0.0 wlan0


