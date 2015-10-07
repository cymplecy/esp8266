gpiolookup = {[0]=3,[1]=10,[2]=4,[3]=9,[4]=1,[5]=2,[10]=12,[12]=6,[13]=7,[14]=5,[15]=8,[16]=0};

stripPin = 2   -- Comment: GPIO5  
wsg = 0  
wsr = 0 
wsb = 0  

sparkleTable ={}


function split(pString, pPattern)
   local Table = {} 
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
            gpio.mode(gpiolookup[gpin],gpio.OUTPUT)
            gpio.write(gpiolookup[gpin],state)  
          end
          if string.sub(pkt,1,7) == "sparkle" then
             wsrgb = string.sub(pkt,8,-1)
             print ("wsrgb" .. wsrgb)
             myTable = split(wsrgb,",")
             sparkleNum = tonumber(myTable[1])
             r = tonumber(myTable[2])
             g = tonumber(myTable[3])
             b = tonumber(myTable[4])
             print (myTable[1])
             print (myTable[2])
             print (myTable[3])
             print (myTable[4])
             sparkleTable[sparkleNum] = string.char(r, g, b) 
             rgb = ""
             for loop = 1,5 do
               if sparkleTable[loop] ~= nil then
                rgb = (rgb .. sparkleTable[loop])
               else
                rgb = (rgb .. string.char(0, 0, 0))
               end
             end
             ws2812.writergb(stripPin, rgb)
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

