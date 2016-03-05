function startConfig()
     print('Config -> start webserver')
     print(node.heap())
     file.remove("init.lua")
     file.open("init.lua", "a+")
     file.writeline('dofile("config.lc")')
     file.close()
     tmr.delay(100000)
     node.restart()
end

function checkLongPress()
    gpio.mode(pin_reset,gpio.OUTPUT)
	gpio.write(pin_reset,gpio.HIGH)
	tmr.alarm(1,500,0,function()
		if gpio.read(pin_reset)~=gpio.HIGH then
			startConfig()
		else
			gpio.mode(pin_reset,gpio.INT,gpio.PULLUP)
			gpio.trig(pin_reset,"low",checkLongPress)
		end
	end)
end

function checkPlants()
	print("Checking plants...") 

	for i=1,numberOfPlants do
		currentState = gpio.read(plants[i]['pin'])
		print("Plant "..i..": "..currentState)
		-- read 0
		if ( currentState==1 and plants[i].state==0 ) then
			print('Sending MakeIFTTT event')
			-- MakeIFTTT:sendEvent("plant_needs_water", i)
			httpRequest:sendIFTTT("cwezoY_qooed0A0xeEM76w", "plant_needs_water", i)
		end
		plants[i].state = currentState
	end
	
	print('Writing file...')
	file.remove("plantStates.lua")
	file.open("plantStates.lua", "a+")
	file.writeline('plantStates = {}')
	for index,plant in pairs(plants) do
		--print('plantStates['..index..'] = '..plant.state)
		file.writeline('plantStates['..index..'] = '..plant.state)
	end
	file.close()
end

function switchHook(commandTable)
	if (commandTable['sw']~=nil and commandTable['st']~=nil) then
		print(commandTable['sw']..','..commandTable['st']..';')
	end
end

function irHook(commandTable)
	if (commandTable['ir']~=nil) then
		print(commandTable['ir']..','..'0;')
	end
end

function startServices()
	-- Run REST server
	RestAPI:runServer()

	-- Set timer TODO move interval to settings.lua
	tmr.alarm(3, 5000, 1, checkPlants)
	
	-- set sleep timer
	tmr.alarm(5, 12500, 0, function()
		print('Going to sleep...')
		node.dsleep(tonumber(interval*1000000))
	end)	
end

if file.open('settings.lua', 'r') then 
     dofile('settings.lua')
	 wifi.setmode(wifi.STATION)
	 wifi.sta.config(network, password)
	 wifi.sta.autoconnect(1)
	 
	 -- Check for IP status
	 tmr.alarm(4,1000, 1, function() 
	 	if wifi.sta.getip()==nil then 
	 		print("Waiting for IP address...")
	 		-- blink LED
	 		RGBled:blink(RGBled.pinR, 2, 100)
	 	else 
	 		print("Obtained IP: "..wifi.sta.getip())
	 		-- Start services
	 		startServices()	
	 		-- blink LED
			RGBled:blink(RGBled.pinG, 2, 250)
	 		tmr.stop(4)
	 	end
	 end)
	 
	-- TODO Move number of plants to settings.lua
	numberOfPlants = 3
	 
	-- Reset pin:
	plants = {}
	pin_reset=3
	
	-- Set mode and trigger
	gpio.mode(pin_reset,gpio.INT,gpio.PULLUP)
	gpio.trig(pin_reset,"low",checkLongPress)
	
	-- Plant pins:
	plantPins = {}
	plantPins[1] = 2
	plantPins[2] = 1
	plantPins[3] = 4
	plantPins[4] = 8
	plantPins[5] = 5
	
	-- Plant memory:
	if file.open('plantStates.lua', 'r') then
		dofile('plantStates.lua')
	end
	
	
	for i=1, numberOfPlants do
		-- Build plant
		plant = {}
		plant.pin = plantPins[i]
		if plantStates~=nil then
			plant.state = plantStates[i]
		else
			plant.state = 1
		end
		
		-- Add to plant array
		table.insert(plants, plant)
		plant = nil
	end
	plantStates = nil
	
	-- Set mode and trigger
	for i=1, numberOfPlants do
		gpio.mode(plants[i]['pin'], gpio.INPUT)
	end
	
	-- Init RGBled module
	RGBled = require("RGBled").new(8,6,7)
		
	-- Init MakeIFTTT module
	MakeIFTTT = require("MakeIFTTT").new("cwezoY_qooed0A0xeEM76w")
	httpRequest = require("httpRequest").new()
	
	-- Init RestAPI module
	RestAPI = require("RestAPI").new(80)
	RestAPI:addHook(switchHook, {'sw','st'})
	RestAPI:addHook(irHook, {'ir','st'})	
	
else
	startConfig()
end
