#!/bin/bash

#ls -t /dev/video*

declare -a zed_array=()
declare -a zed_avail_array=()
declare -a zed_not_avail_array=()

detect_zed_m() {
    for sysdevpath in $(find /sys/bus/usb/devices/usb*/ -name dev); do
            syspath="${sysdevpath%/dev}"
            [[ "$syspath" != *video4linux/video* ]] && continue
            [[ $(cat "$syspath/name") != "ZED-M" ]] && continue
            zed_array[${#zed_array[@]}]=/dev/$(basename $syspath)
            zed_idx="$((${#zed_array[@]}-1))"
            export "zedm_$zed_idx=/dev/$(basename $syspath)"
            
            if fuser -v /dev/$(basename $syspath) > /dev/null 2>&1; then
                zed_not_avail_array[${#zed_not_avail_array[@]}]=/dev/$(basename $syspath)
            else
                 zed_avail_array[${#zed_avail_array[@]}]=/dev/$(basename $syspath)
            fi
    done
}

detect_zed_m

#echo "${zed_array[*]}"
#echo "${zed_avail_array[*]}"
#echo "${zed_not_avail_array[*]}"

#devname="$(udevadm info -q name -p $syspath)"
#[[ "$devname" == "bus/"* ]] && continue
#eval "$(udevadm info -q property --export -p $syspath)"
#[[ -z "$ID_SERIAL" ]] && continue
#[[ "$ID_VENDOR_ID" == "2b03" ]] && echo "/dev/$devname - $ID_SERIAL"
