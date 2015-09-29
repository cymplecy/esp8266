-- 01-wifi-connection.lua
-- Connect to the WiFi network (act as a station)

print("Setting the device up as a STATION")
wifi.setmode(wifi.STATION)

print("Connecting to the AP")
wifi.sta.config("CYCY", "") -- insert your SSID and password here
wifi.sta.connect()

print("Waiting a little bit to get an IP address...")
tmr.delay(1000 * 1000 * 30)

print("Device mode: " .. wifi.getmode())
print("(1 = STATION, 2 = SOFTAP, 3 = STATIONAP)")
print("STA MAC address: " .. wifi.sta.getmac())
print("STA IP: ".. wifi.sta.getip())
