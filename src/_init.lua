function checkIP()
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
end

function writeSettings()
    local ssid, password, _, _ = wifi.sta.getconfig()
    file.remove("wifi.lua")
    file.open("wifi.lua", "a+")
    file.writeline('wifi.setmode(wifi.STATION)')
    file.writeline('wifi.sta.config("'..ssid..'","'..password..'")')
    file.close()
end

function begin()
    Sonoff = require("Sonoff").new('curtain', nil, nil)
end

if file.open('wifi.lua', 'r') then
    dofile('wifi.lua')
    checkIP()
else
    if enduser_setup~=nil then
        local SSID = 'Socket-Node-'..string.sub(wifi.sta.getmac(),13,-1)
        wifi.setmode(wifi.STATIONAP)
        wifi.ap.config({ssid=SSID, auth=wifi.AUTH_OPEN})
        enduser_setup.manual(true)
        print('Starting end user setup..')
        enduser_setup.start(
            function()
                print("Connected to wifi as:" .. wifi.sta.getip())
                writeSettings()
                checkIP()
            end,

            function(err, str)
                print("enduser_setup: Err #" .. err .. ": " .. str)
            end
        )
    end
end
