gpiolookup = {[0]=3,[1]=10,[2]=4,[3]=9,[4]=1,[5]=2,[10]=12,[12]=6,[13]=7,[14]=5,[15]=8,[16]=0}
--key = gpio, value = nodelua
stripPin = 2   -- Comment: GPIO5  

sparkleTable = {}

function pinControl(pkt,g)
  state = gpio.LOW
  pin = ""
  if string.sub(pkt,-2,-1) == "on" then
        state = gpio.HIGH
        pin = string.sub(pkt,1,-3)
  end
  if string.sub(pkt,-3,-1) == "off" then
        state = gpio.LOW
        pin = string.sub(pkt,1,-4)
  end
  pin = tonumber(pin)
  if g == true then
    pin = gpiolookup[pin]
  end
  print ("pin :" .. pin )
  gpio.mode(pin,gpio.OUTPUT)
  gpio.write(pin,state)  
end

function connected()
   conn = net.createConnection(net.TCP, 0)
   print("Scratch connected")
   function s_output(str)
      if (conn~=nil)    then
         conn:send(str)
      end
   end
   conn:on("receive", function(conn, pl) 
      print (string.byte(pl,1,1))
      print (string.byte(pl,4,4))      
      msg = string.sub(pl,5,-1)
      print ("msg received:" .. msg)
      if string.sub(msg,1,9) == "broadcast" then
          word=msg:match('%"(%a+)%"')
          msg = string.gsub(msg, "%s+", "")
          quote2 = string.find(msg, '"', 11 )
          pkt = string.sub(msg,11,quote2 - 1)
          print ("pkt:" .. pkt)
          if string.sub(pkt,1,4) == "gpio" then
            pinControl(string.sub(pkt,5,-1),true)
          end
          if string.sub(pkt,1,1) == "d" then
            pinControl(string.sub(pkt,2,-1),false)
          end          
          if string.sub(pkt,1,7) == "sparkle" then
             wsrgb = string.sub(pkt,8,-1)
             print ("wsrgb" .. wsrgb)
             sparkleNum,r,g,b = wsrgb:match("(%d%d?%d?)%,(%d%d?%d?)%,(%d%d?%d?)%,(%d%d?%d?)" )
             if sparkleNum == "0" then
                sparkleNum = "1"
             end
             sparkleTable[tonumber(sparkleNum)] = string.char(r,g, b) 
             rgb = ""
             for loop = 1,12 do
               if sparkleTable[loop] ~= nil then
                 rgb = (rgb .. sparkleTable[loop])
               else
                 rgb = (rgb .. string.char(0,0,0))
               end
             end
             ws2812.writergb(stripPin,rgb)
             rgb = ""
          end
      end
   end)

   conn:on("disconnection",function(conn) 
      print ("")
      print ("DISCONNECTED")
      print ("")
   end)
   conn:connect(42001,"192.168.0.16")
end


print("Setting the device up as a STATION")
wifi.setmode(wifi.STATION)

print("Connecting to the AP")
wifi.sta.config("CYCY", "")
wifi.sta.connect()

print("Waiting a little bit to get an IP address...")


tmr.alarm(1, 1000, 1, function() 
  if wifi.sta.getip()=="0.0.0.0" or wifi.sta.getip() == nil then
    print("Connect AP, Waiting...") 
  else
    print("Wifi AP connected. Wicon IP:")
    print(wifi.sta.getip())
    connected()
    tmr.stop(1)
  end
end)



