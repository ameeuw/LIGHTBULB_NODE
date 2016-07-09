-- init.lua module
-- Author: Arne Meeuw
-- github.com/ameeuw
--
-- This skript is launched after boot of ESP8266 and loads the Wifi configuration (expected in wifi.lua).
-- If this fails, enduser_setup is launched and the settings are saved.
-- After an IP is acquired, begin() is triggered.

-- Initialize global PWM RGBled on pins 8,6,7
RGBled = require("RGBled").new("PWM",{8,6,7})
-- Initialize global Button on pin 2
Button = require("Button").new(2,function() print("Short press.") end,telnet)

-- IP acquired, begin()
function begin()
    Lightbulb = require("Lightbulb").new('m-e-e-u-w.de',62763)
end

-- Check for IP status
function checkIP()
    RGBled:breathe(-1,100,138,11)
    tmr.alarm(4,2000, 1,
      function()
        if wifi.sta.getip()==nil then
            print("Waiting for IP address...")
        else
            print("Obtained IP: "..wifi.sta.getip())
            RGBled:breathe(3,150,52,141,0)
            begin()
            tmr.stop(4)
        end
      end)
end

-- Write wifi station config to wifi.lua
function writeSettings()
    local ssid, password, _, _ = wifi.sta.getconfig()
    file.remove("wifi.lua")
    file.open("wifi.lua", "a+")
    file.writeline('wifi.setmode(wifi.STATION)')
    file.writeline('wifi.sta.config("'..ssid..'","'..password..'")')
    file.close()
end

-- Try to open wifi.lua and start enduser_setup if it fails
if file.open('wifi.lua', 'r') then
    dofile('wifi.lua')
    checkIP()
else
    if enduser_setup~=nil then
        RGBled:breathe(-1,0,255,11)
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
          end)
    end
end

-- Start telnet to update code
function telnet()
			print("Starting telnet remote.")
			--dofile("telnet.lc")
end
