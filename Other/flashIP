-- use WS2812 on pin 2 to flash IP address
function split(pString, pPattern)
   local Table = {}  -- NOTE: use {n = 0} in Lua-5.0
   local fpat = "(.-)" .. pPattern
   local last_end = 1
   local s, e, cap = pString:find(fpat, 1)
   while s do
          if s ~= 1 or cap ~= "" then
         table.insert(Table,cap)
          end
          last_end = e+1
          s, e, cap = pString:find(fpat, last_end)
   end
   if last_end <= #pString then
          cap = pString:sub(last_end)
          table.insert(Table, cap)
   end
   return Table
end

function blink(pin,times)
    if times > 0 then
        gpio.mode(pin,gpio.OUTPUT)
        gpio.write(pin,gpio.LOW)
        tmr.delay(1 * 1000000)
        for i = 1,times do
            gpio.write(pin,gpio.HIGH)
            tmr.delay(5 * 100000)
            gpio.write(pin,gpio.LOW)
            tmr.delay(1 * 100000)
        end
    end
end
  
print("Setting the device up as a STATION")
wifi.setmode(wifi.STATION)

print("Connecting to the AP")
wifi.sta.config("CYCY", "")
wifi.sta.connect()

print("Waiting a little bit to get an IP address...")


function main()
    print ("main")
    ipaddr = wifi.sta.getip()
    local str = ipaddr
    local o1,o2,o3,o4 = str:match("(%d%d?%d?)%.(%d%d?%d?)%.(%d%d?%d?)%.(%d%d?%d?)" )
    print ("4th:" .. o4)
    o4 = "000" .. tostring(o4)
    o43 = tonumber(string.sub(o4,-1,-1))
    o42 = tonumber(string.sub(o4,-2,-2))
    o41 = tonumber(string.sub(o4,-3,-3))
    print (o41 .. "," .. o42 ..  "," .. o43)
    for loop = 1,3 do
        blink(4,o41)
        blink(4,o42)    
        blink(4,o43)
        tmr.delay(1 * 1000000)
    end
end


tmr.alarm(1, 1000, 1, function() 
   if wifi.sta.getip()=="0.0.0.0" or wifi.sta.getip() == nil then
      print("Connect AP, Waiting...") 
   else
      print("Wifi AP connected. Wicon IP:")
      print(wifi.sta.getip())
      main()
      tmr.stop(1)
   end
end)




