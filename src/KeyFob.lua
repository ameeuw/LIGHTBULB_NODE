wifi.setmode(wifi.STATION)
wifi.sta.config("qn_2","drogensindverlogen")


function wifiHook(commandTable)
	if (commandTable.ssid~=nil and commandTable.password~=nil) then
        print("Setting Wifi to:")
        printTable(commandTable)
		wifi.sta.config(commandTable.ssid, commandTable.password)
	end
end

function printTable(commandTable)
    for k,v in pairs(commandTable) do
        print("Key:",k,"Val:",v)
    end
end

wifi.setmode(wifi.STATION)

Sonoff=require("Sonoff").new()
Sonoff.RestAPI:addHook(wifiHook,{"ssid","password"})

Sonoff.RestAPI:addHook(function(commandTable)
    r = tonumber(commandTable.r)
    g = tonumber(commandTable.g)
    b = tonumber(commandTable.b)
    print("Settings RGB Led to ",r,g,b)
    gpio.mode(3,gpio.OUTPUT)
    ws2812.writergb(3, string.char(r,g,b))
    gpio.mode(3,gpio.INT,gpio.PULLUP)
    end, {'r','g','b'})
    

http=require("Http").new()

state1 = "0"
state2 = "0"
Button2 = require("Button").new(3, 
    -- Switch on/off bed light by short press
    function()
        if state2=="0" then
            state2="1"
        else
            state2="0"
        end
        http.get("192.168.0.183/?socket="..state2, "", function(payload) end) 
    end,
    -- Switch on/off shelf light by long press
    function()
        if state1=="0" then
            state1="1"
        else
            state1="0"
        end
        http.get("192.168.0.203/?socket="..state1, "", function(payload) end) 
    end)
