gpiolookup = {[0]=3,[1]=10,[2]=4,[3]=9,[4]=1,[5]=2,[10]=12,[12]=6,[13]=7,[14]=5,[15]=8,[16]=0}
--key = gpio, value = nodelua

DWEET_ID = "cycy42"
dweet = net.createConnection(net.TCP, 0)

dweet:on("connection", function(conn, payload)
    dweet:send(
        "POST /dweet/for/" .. DWEET_ID .. 
        "?miniBotIP=" .. wifi.sta.getip() ..
        " HTTP/1.1\r\nHost: dweet.io\r\n" ..
        "Connection: close\r\nAccept: */*\r\n\r\n"
    )
end)

conn = net.createConnection(net.TCP, 0)
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
  pin = tonumber(math.floor(pin))
  if (g == true) then
    pin = (gpiolookup[pin])
  end
  print ("pin :" .. pin )
  gpio.mode(pin,gpio.OUTPUT)
  gpio.write(pin,state)  
end

function motor(pkt)
  pin1 = tonumber(string.sub(pkt,1,1))
  pin2 = tonumber(string.sub(pkt,2,2))
  speed = tonumber(string.sub(pkt,3,-1))
  if speed > 0 then
    gpio.mode(pin2,gpio.OUTPUT)
    pwm.setup(pin1, 30, math.floor(1023 * math.abs(speed) / 100))
    gpio.write(pin2,gpio.LOW) 
    pwm.start(pin1) 
  else
    gpio.mode(pin2,gpio.OUTPUT)
    pwm.setup(pin1, 30, (1023 - math.floor(1023 * math.abs(speed) / 100)))
    gpio.write(pin2,gpio.HIGH) 
    pwm.start(pin1) 
  end
end

function connected()
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
          if string.sub(pkt,1,5) == "motor" then
            motor(string.sub(pkt,6,-1),false)
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
      print ("DISCONNECTED")
   end)
   conn:connect(42001,"192.168.0.16")
end

wifi.setmode(wifi.STATION)
wifi.sta.config("CYCY", "")
wifi.sta.connect()

print("Waitfor IP...")


tmr.alarm(1, 1000, 1, function() 
  if wifi.sta.getip()=="0.0.0.0" or wifi.sta.getip() == nil then
    print("Waiting...") 
  else
    print("Wifi connected")
    print(wifi.sta.getip())
    dweet:connect(80, "dweet.io")
    connected()
    tmr.stop(1)
  end
end)



