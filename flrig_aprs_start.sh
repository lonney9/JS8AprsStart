#!/bin/bash

# Script starts Flrig, waits for key press then proceeds to start JS8Call and JS8Call Utilities
# Ctrl C at any point will close the applications via wmctrl which simulates an Alt F4 keypress
#   This allows the apps to gracefully close saving settings and current state
# Once main script starts Flrig rig connection is monitored
# Monitors DBM value via flrig xmlrpc server, if value returned is -128 rig control is lost
# Closes applicatoins
# Waits until RIG_PORT is present (USB port connected / rig has power), restarts applications
# Resumes monitoring DBM value

# Requires curl and wmctrl (apt-get install curl wmctrl)

# RIG_PORT: With USB cable connected "ls -l /dev/serial/by-id/" to get link name
# The link points to the /dev/ttyUSBx device where x (number) can change.

RIG_PORT="/dev/serial/by-id/usb-Silicon_Labs_CP2102_USB_to_UART_Bridge_Controller_IC-7100_22001383_A-if00-port0"
FLRIG_IP="127.0.0.1:12345"
DBM_GET_XML='<?xml version="1.0"?><methodCall><methodName>rig.get_DBM</methodName></methodCall>'
DBM_DISCONN='<value>-128</value>'

# Functions to close applications
# Close Flrig
close_flrig() {
  window_id=$(wmctrl -l | grep "flrig" | cut -d' ' -f1)
  echo "Closing Flrig.." 
  wmctrl -ic "$window_id"
  
  # Wait for the process to gracefully exit
  timeout=10
  while pgrep -x "flrig" > /dev/null && [ $timeout -gt 0 ]; do
    sleep 1
    ((timeout--))
  done

  # If the process is still running after the timeout, terminate it
  if pgrep -x "flrig" > /dev/null; then 
    pkill flrig
    echo "flrig terminated"
  fi
}

# Close JS8Call
close_js8call() {
  window_id=$(wmctrl -l | grep "JS8Call de KN4CRD" | cut -d' ' -f1)
  echo "Closing JS8Call.." 
  wmctrl -ic "$window_id"
  
  # Wait for the process to gracefully exit
  timeout=10
  while pgrep -x "js8call" > /dev/null && [ $timeout -gt 0 ]; do
    sleep 1
    ((timeout--))
  done

  # If the process is still running after the timeout, terminate it
  if pgrep -x "js8call" > /dev/null; then 
    pkill js8call
    echo "js8call terminated"
  fi
  if pgrep -x "js8" > /dev/null; then 
    pkill js8
    echo "js8 terminated"
  fi
}

# Close JS8Call Utilities
close_js8call_utils() {
  window_id=$(wmctrl -l | grep "JS8Call Utilities" | cut -d' ' -f1)
  echo "Closing JS8Call Utilities.." 
  wmctrl -ic "$window_id"
  
  # Wait for the process to gracefully exit
  timeout=10
  while pgrep -x "JS8CallUtils_v2" > /dev/null && [ $timeout -gt 0 ]; do
    sleep 1
    ((timeout--))
  done

  # If the process is still running after the timeout, terminate it
  if pgrep -x "JS8CallUtils_v2" > /dev/null; then 
    pkill JS8CallUtils_v2
    echo "JS8CallUtils_v2 terminated"
  fi
}

# Function to handle Ctrl+C
ctrl_c() {
    echo "Ctrl+C detected. Exiting..."
    close_js8call_utils
    close_js8call
    close_flrig
    exit 1
}

# Trap Ctrl+C
trap ctrl_c INT


## Start main script ##

if ! [ -e $RIG_PORT ]; then
  echo "RIG at $RIG_PORT not connected, exiting.."
  sleep 1
  exit 1
fi

# Start Flrig
echo "Starting flrig.."
flrig &
sleep 2

# Prompt user for input
echo " "
echo "When started check JS8Call audio settings / tune"
echo " "
echo "Press any key to continue, or Ctrl+C to exit"
read -n 1 -s -r -p ""

# Continue
echo "Starting JS8Call.."
js8call > /dev/null 2>&1 &
echo "Starting JS8Call Utilities.."
./JS8CallUtils_v2 &
sleep 2

# Monitor DBM reading (normal operation is -127 or higher)
while true; do
  DBM_RESULT=$(curl -s -X POST -d "$DBM_GET_XML" "http://${FLRIG_IP}" | grep '<value>')
  # DBM_RESULT='<value>-128</value>' # For testing
  printf "DBM reading: $DBM_RESULT" # For testing, printf updates same line vs scrolling

  # If DBM reading becomes -128 rig control lost
  if [[ $DBM_RESULT == *"$DBM_DISCONN"* ]]; then
    echo "Rig control lost, closing applications.."
    # Close applications
    close_js8call_utils
    close_js8call
    close_flrig
  
    # Monitor RIG_PORT symlink status and start applications
    while true; do

    if [ -e $RIG_PORT ]; then
      # Rig connected, start applications
      # Need to add a check to see Flrig started properly
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