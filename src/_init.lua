wifi.setmode(wifi.STATION)
wifi.sta.config("belkin.836","8e67b663")

-- Check for IP status
tmr.alarm(4,1000, 1, function() 
        if wifi.sta.getip()==nil then 
            print("Waiting for IP address...")
        else 
            print("Obtained IP: "..wifi.sta.getip())
            begin()
            tmr.stop(4)
        end
     end)

function begin()
    Sonoff = require("Sonoff").new('desk', nil, runTelnet)
end

function runTelnet()
    print("Stopping TCP Server")
    Sonoff.RestAPI:stopServer()
    print("Running Telnet")
    --dofile('telnet.lua')
end