function nameHook(commandTable)
    print("Changing Socket name to:")
	printTable(commandTable)
end

function socketHook(commandTable)
    print("Set socket to:")
	if commandTable.socket~=nil then
		if type(tonumber(commandTable.socket))=="number" then
			Socket:set(tonumber(commandTable.socket))
		end
	end
end

function wifiHook(commandTable)
    print("Setting Wifi to:")
	if (commandTable.ssid~=nil and commandTable.password~=nil) then
		wifi.sta.config(commandTable.ssid, commandTable.password)
	end
end

function buttonPressed()
	--print("Short Press!")
    Socket:toggle()
end

function buttonLongPressed()
	--print("Long Press!")
end

function printTable(commandTable)
    for k,v in pairs(commandTable) do
        print("Key:",k,"Val:",v)
    end
end

wifi.setmode(wifi.STATION)

-- Init RestAPI module
RestAPI = require("RestAPI").new(80)
RestAPI:addHook(socketHook, {'socket'})
--RestAPI:addHook(nameHook, {'soName'})
--RestAPI:addHook(wifiHook, {'ssid','password'})

-- Run REST server
RestAPI:runServer()

Socket = require("Socket").new(6)
Button = require("Button").new(3, buttonPressed, buttonLongPressed)
