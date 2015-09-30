# esp8266
Scratch controlling ESP8266

This is my initial coding attempts to run a Lua script on an esp8266 board (I'm using an ESP-12 at moment).

At the moment, it can be used to turn the GPIO pins on or off and control a single Neopixel/Sparkle

Instructions
Your esp device must be running NodeMCU Lua firmware
Amend the WifConnect script with your WiFi settings an upload it

Upload ScratchLua and make note of IP address shown (e.g 192.168.0.10)

For BYOB

Open BYOB and connect to mesh and type in IP collected above

to use

broadcast gpio15on

will switch gpio15on

For Scratch

Run lanpy.py and then load in Scratch and enable Remote Sensor Connectors

do a broadcast linka.b.c.d replaing a.b.c.d with IP collected above

e.g

broadcast link192.168.0.10

Precede and broadcast text with send. e.g

broadcast send gpio15on

will switch esp8266 GPIO15 on

