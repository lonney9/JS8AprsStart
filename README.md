# JS8 APRS Startup

Startup script for [JS8Call](http://js8call.com) and associated GPS/APRS tool (Git) [JS8CallUtilsGPSD](https://github.com/m0iax/JS8CallUtilsGPSD), (Compiled Binaries) [JS8Call Utilities](https://m0iax.com/downloadfiles/).

Related to my [HF APRS with JS8Call project](https://lonneys-notebook.blogspot.com/2020/02/hf-aprs-with-js8call.html).

The scripts were written a few years ago with the previous version of JS8CallUtils and Raspberry Pi OS Buster Desktop, but should be easy to adpat to current versions assuming other things have not changed too much..

`js8aprs_start.sh` can run at startup via `js8aprs_start.desktop` located in `/home/pi/.config/autostart`.

I discovered this autostart method from [How to Run a Raspberry Pi Program on Startup](https://learn.sparkfun.com/tutorials/how-to-run-a-raspberry-pi-program-on-startup#method-2-autostart).

The scripts assume the default `/home/pi` home directory.

To install:

```bash
cd
git clone https://github.com/lonney9/JS8AprsStart.git
cd JS8AprsStart
chmod +x js8aprs_start.sh
mkdir /home/pi/.config/autostart
mv js8aprs_start.desktop /home/pi/.config/autostart/
```

## FLRig Monitor

flrig_mon.sh

This basic script used with the Debian 12 laptop setup to handle power disruptions (vehicle stop/start).

- Script monitors Flrig rig connection.
- Monitors DBM value via flrig xmlrpc server, if value returned is -128 rig control is lost.
- Closes and restarts applications if rig connection is interrupted (power loss).
- Waits until RIG_PORT is present (USB port), restarts applications.
- Resumes monitoring DBM value. 

## FLRig APRS Start

flrig_aprs_start.sh

This more advanced script used with the Debian 12 laptop setup to start the applications and handle power disruptions (vehicle stop/start).

Uses wmctrl to gracefully close the applications allowing them to save their current state and settings.

- Checks for rig connection, starts Flrig, waits for any key press to proceeed, starts JS8Call and JS8Call Utilities
- Script then monitors Flrig rig connection.
- Monitors DBM value via flrig xmlrpc server, if value returned is -128 rig control is lost.
- Closes and restarts applications if rig connection is interrupted (power loss).
- Waits until RIG_PORT is present (USB port), restarts applications.
- Resumes monitoring DBM value. 

flrig_aprs_start.ps1

Windows PowerShell version of the script.

CTRL C function not implemented, press Enter key to continue, otherwise the same.
