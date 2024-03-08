#!/bin/bash

# Script monitors Flrig rig connection.
# Closes and restarts applications if rig connection is interrupted (power loss).
# Monitors DBM value via flrig xmlrpc server, if value returned is -128 rig control is lost.
# Waits until RIG_PORT is present (USB port connected / rig has power), restarts applications.
# Resumes monitoring DBM value.

## A much improved version at https://github.com/lonney9/JS8AprsStart/blob/master/flrig_aprs_start.sh ##

RIG_PORT="/dev/serial/by-id/usb-Silicon_Labs_CP2102_USB_to_UART_Bridge_Controller_IC-7100_22001383_A-if00-port0"
FLRIG_IP="127.0.0.1:12345"
DBM_GET_XML='<?xml version="1.0"?><methodCall><methodName>rig.get_DBM</methodName></methodCall>'
DBM_DISCONN='<value>-128</value>'

# Function to close applications
close_app() {
    if pgrep -x "$1" > /dev/null; then 
        pkill $1; echo "$1 closed";
    fi
}

# Monitor DBM reading (normal operation is -127 or higher)
while true; do
  DBM_RESULT=$(curl -s -X POST -d "$DBM_GET_XML" "http://${FLRIG_IP}" | grep '<value>')
  # DBM_RESULT='<value>-128</value>' # For testing
  # echo $DBM_RESULT # For testing

  # If DBM reading becomes -128 rig control lost
  if [[ $DBM_RESULT == *"$DBM_DISCONN"* ]]; then
    echo "Rig control lost"
    # Close applications
    close_app flrig
    close_app js8call
    close_app js8
    close_app JS8CallUtils_v2
    sleep 1
  
    # Monitor RIG_PORT symlink status and start applications
    while true; do

    if [ -e $RIG_PORT ]; then
      # Rig connected, start applications
      echo "Rig connected, start applications.."
      flrig &
      sleep 3
      js8call > /dev/null 2>&1 &
      ./JS8CallUtils_v2 &
      sleep 3
      break
    else
      # RIG_PORT disconneccted take a nap and try again
      echo "Rig disconnected, re-check every 5 seconds.."
      sleep 5
    fi
    done
  fi

  sleep 1
done
