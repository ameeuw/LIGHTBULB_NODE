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

HttpRequest=require("HttpRequest").new()

state1 = "0"
state2 = "0"
Button2 = require("Button").new(4, 
    -- Switch on/off bed light by short press
    function()
        if state2=="0" then
            state2="1"
        else
            state2="0"
        end
        HttpRequest:send("GET","192.168.0.183","/?socket="..state2,"") 
    end,
    -- Switch on/off shelf light by long press
    function()
        if state1=="0" then
            state1="1"
        else
            state1="0"
        end
        HttpRequest:send("GET","192.168.0.203","/?socket="..state1,"") 
    end)