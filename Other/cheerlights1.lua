-- get current cheerlights colour
print("Setting the device up as a STATION")
wifi.setmode(wifi.STATION)

print("Connecting to the AP")
wifi.sta.config("CYCY", "")
wifi.sta.connect()

print("Waiting a little bit to get an IP address...")

function main()
    print ("main")

    sk=net.createConnection(net.TCP, 0)
    conn = sk
    sk:on("receive", function(sck, c)
        print ("receive...")
        print(c)
        field2 = string.find(c, 'field2')
        if field2 ~= nil then
            --ws2812.writergb(2,string.char(0,0,0))    
            tmr.delay(1000*1000)
            pkt = string.sub(c,field2 + 10,field2 + 15)
            print ("pkt".. pkt)
            r = tonumber(string.sub(pkt,1,2), 16)
            g = tonumber(string.sub(pkt,3,4), 16)
            b = tonumber(string.sub(pkt,5,6), 16) 
            wsrgb = string.char(r,g,b)
            total = ""
            for loop = 1,3 do
                total = total .. wsrgb
                ws2812.writergb(2,total)
            end
        end

    end )
    
    sk:connect(80,"144.212.80.11")
    --conn:send("GET /channels/1417/field/2/last.json HTTP/1.1\r\nHost: api.thingspeak.com\r\nConnection: keep-alive\r\nAccept: */*\r\n\r\n")
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

tmr.alarm(2, 10000, 1, function() 
    conn:send("GET /channels/1417/field/2/last.json HTTP/1.1\r\nHost: api.thingspeak.com\r\nConnection: keep-alive\r\nAccept: */*\r\n\r\n")
end)


