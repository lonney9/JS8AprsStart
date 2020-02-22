#!/usr/bin/env bash

# JS8Call ARPS startup script for Raspberry Pi
# This can be manually run to test, to run it when the system boots use in conjunction with
# js8aprs_start.desktop located in /home/pi/.config/autostart

# 2020-02-19 - KL3NO - Initial script

# Restart gpsd, for me my GPS is on /dev/ttyUSB1 (as configured in /etc/default/gpsd) it locks up 
# /dev/ttyUSB0 when the system starts. This prevents JS8Call from interfacing with my Icom IC-7300
# rig on /dev/ttyUSB0. Simply restarting gpsd resolves this.

# Restart gpsd.
sudo /etc/init.d/gpsd restart

# Start JS8Call.
/usr/local/bin/js8call &

# Wait for JS8Call to get started.
sleep 25

# Start JS8CallUtilsGPSD.
/home/pi/JS8CallUtilsGPSD/js8callutilsGPSD.py &
