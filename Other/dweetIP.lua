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
    tmr.stop(1)
  end
end)