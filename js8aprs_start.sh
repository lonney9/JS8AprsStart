#!/usr/bin/env bash

# JS8Call ARPS startup script for Raspberry Pi
# This can be manually run to test, to run it when the system boots use in conjunction with
# js8aprs_start.desktop located in /home/pi/.config/autostart

# 2020-02-19 - KL3NO - Initial script
# 2024-02-17 - K1LH  - Remove GPSD restart, add note about gpsd hotplugging

# Ensure /etc/default/gpsd has hotplugging disabled: USBAUTO="false"
# Otherwise gpsd will lockup other /dev/ttyUSBx ports, e.g. the rig CAT control etc.

# Start JS8Call.
/usr/local/bin/js8call &

# Wait for JS8Call to get started.
sleep 25

# Start JS8CallUtilsGPSD.
/home/pi/JS8CallUtilsGPSD/js8callutilsGPSD.py &
