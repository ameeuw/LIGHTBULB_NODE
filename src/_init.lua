if file.open('wifi.lua', 'r') then 
    dofile('wifi.lua')
else
    if enduser_setup~=nil then
        local SSID = 'Socket-Node-'..string.sub(wifi.sta.getmac(),13,-1)
        wifi.setmode(wifi.SOFTAP)
        wifi.ap.config({ssid=SSID, auth=wifi.AUTH_OPEN})
        enduser_setup.manual(true)
        enduser_setup.start(
            function()
                print("Connected to wifi as:" .. wifi.sta.getip())
            end,
            
            function(err, str)
                print("enduser_setup: Err #" .. err .. ": " .. str)
            end
        )
    end
end

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