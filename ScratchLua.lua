print("====Wicon, a LUA console over wifi.==========")
print("Author: openthings@163.com. copyright&GPL V2.")
print("Last modified SW 30Sep15 V0.0.4")
print("Waiting for connection")

gpiolookup = {[0]=3,[1]=10,[2]=4,[3]=9,[4]=1,[5]=2,[10]=12,[12]=6,[13]=7,[14]=5,[15]=8,[16]=0};

stripPin = 2   -- Comment: GPIO5  
wsg = 0  
wsr = 0 
wsb = 0  

sparkleTable ={"ABC","ABC","ABC","ABC","ABC","ABC","ABC","ABC","ABC","ABC","ABC","ABC","ABC","ABC","ABC","ABC","ABC","ABC","ABC","ABC","ABC","ABC","ABC","ABC","ABC","ABC","ABC","ABC","ABC","ABC","ABC","ABC","ABC"}


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
         myTable = split(wsrgb,",")
         sparkleNum = tonumber(myTable[1])
         r = tonumber(myTable[2])
         g = tonumber(myTable[3])
         b = tonumber(myTable[4])
         sparkleTable[sparkleNum] = string.char(r, g, b) 
         --print (sparkleTable)
         rgb = ""
         for loop = 1,12 do
           rgb = (rgb .. sparkleTable[loop])
         end
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
   sv=net.createServer(net.TCP, 3600)
   sv:listen(42001, connected)
   print("Server running at :42001")
   print("")
end

print("Setting the device up as a STATION")
wifi.setmode(wifi.STATION)

print("Connecting to the AP")
wifi.sta.config("CYCY", "")
wifi.sta.connect()

print("Waiting a little bit to get an IP address...")


tmr.alarm(1, 1000, 1, function() 
   if wifi.sta.getip()=="0.0.0.0" or wifi.sta.getip() == nil then
      print("Waiting for IP ...") 
   else
      print("Wifi AP connected. IP:")
      print(wifi.sta.getip())
      startServer()
      tmr.stop(1)
   end
end)

