print("====Wicon, a LUA console over wifi.==========")
print("Author: openthings@163.com. copyright&GPL V2.")
print("Last modified SW 29Sep15 V0.0.1")
print("Waiting for connection")

gpiolookup = {[0]=3,[1]=10,[2]=4,[3]=9,[4]=1,[5]=2,[10]=12,[12]=6,[13]=7,[14]=5,[15]=8,[16]=0};

stripPin = 2   -- Comment: GPIO5  
wsg = 0  
wsr = 0 
wsb = 0  


function connected(conn)
   print("Scratch connected")
   function s_output(str)
      if (conn~=nil)    then
         conn:send(str)
      end
   end
   --node.output(s_output,0)
   conn:on("receive", function(conn, pl) 
      --node.input(pl) 
      msg = string.sub(pl,5,-1)
      print ("msg received:" .. msg)
      pkt = string.sub(msg,12,-2)
      if string.sub(pkt,1,4) == "gpio" then
        gpin = 15
        state = gpio.LOW
        if string.sub(pkt,-2,-1) == "on" then
            state = gpio.HIGH
            print ("gpin:" .. string.sub(pkt,5,-3))
            gpin = tonumber(string.sub(pkt,5,-3))
        end
        if string.sub(pkt,-3,-1) == "off" then
            state = gpio.LOW
            print ("gpin:" .. string.sub(pkt,5,-4))            
            gpin = tonumber(string.sub(pkt,5,-4))
        end
        gpio.write(gpiolookup[gpin],state);    
      end
      if string.sub(pkt,1,7) == "sparkle" then
         --wsnum = tonumber(string.sub(pkt,8,9))
         wsrgb = string.sub(pkt,8,-1)
         print ("Wsnum,wsrgb:" .. wsrgb) 
         r = tonumber(string.sub(wsrgb,1,3))
         g = tonumber(string.sub(wsrgb,5,7))
         b = tonumber(string.sub(wsrgb,9,-1))
         print (" " .. r .. g .. b)
         rgb = string.char(r, g, b) 
         ws2812.writergb(stripPin, rgb)
      end
   end)
   conn:on("disconnection",function(conn) 
      print ("")
      print ("DISCONNECTED")
      print ("")
   end)
end

function startServer()
   print("Wifi AP connected. Wicon IP:")
   print(wifi.sta.getip())
   sv=net.createServer(net.TCP, 3600)
   sv:listen(42001, "192.168.0.16", connected)
   print("Server running at :42001")
   print("")
end

tmr.alarm(1, 1000, 1, function() 
   if wifi.sta.getip()=="0.0.0.0" then
      print("Connect AP, Waiting...") 
   else
      startServer()
      tmr.stop(1)
   end
end)