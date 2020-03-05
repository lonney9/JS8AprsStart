# JS8 APRS Startup
Startup script for [JS8Call](http://js8call.com) and associated APRS app [JS8CallUtilsGPSD](https://github.com/m0iax/JS8CallUtilsGPSD) on Raspberry Pi running Buster Desktop.

Related to my [HF APRS with JS8Call project](https://lonneys-notebook.blogspot.com/2020/02/hf-aprs-with-js8call.html).

`js8aprs_start.sh` can run at startup via `js8aprs_start.desktop` located in `/home/pi/.config/autostart`.
I discovered this autostart method from [How to Run a Raspberry Pi Program on Startup](https://learn.sparkfun.com/tutorials/how-to-run-a-raspberry-pi-program-on-startup#method-2-autostart).

The scripts assume the default `/home/pi` home directory.

To install:
```
cd
git clone https://github.com/lonney9/JS8AprsStart.git
cd JS8AprsStart
chmod +x js8aprs_start.sh
mkdir /home/pi/.config/autostart
mv js8aprs_start.desktop /home/pi/.config/autostart/
```
