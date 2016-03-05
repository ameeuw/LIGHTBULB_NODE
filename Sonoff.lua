-- Sonooff.lua module
-- Author: Arne Meeuw
-- github.com/ameeuw
--
-- Module for ITEAD Sonoff hardware
--
-- Initialize:
-- Sonoff = require('Sonoff').new()
--

local Sonoff = {}
Sonoff.__index = Sonoff

function Sonoff.new(pin, pressCallback, longPressCallback)
	-- TODO: add timer variable to change timer number
	local self = setmetatable({}, Sonoff)
	local relayPin = 6
	local buttonPin = 3
	
	self.RestAPI = require("RestAPI").new(80)
	self.RestAPI:addHook(function(commandTable) self.setHook(self, commandTable) end, {"socket"})
    -- Run REST server
    self.RestAPI:runServer()
	
	self.Button = require("Button").new(buttonPin, function() self.buttonPress(self) end, function() self.buttonLongPress(self) end)
	
	self.Socket = require("Socket").new(relayPin)
	
	
	return self
end

function Sonoff.buttonPress(self)
	print("Short press!")
	self.Socket:toggle()
end

function Sonoff.buttonLongPress(self)
	print("Looong press!")
end

function Sonoff.setHook(self, commandTable)
	if commandTable.socket~=nil then
		if type(tonumber(commandTable.socket))=="number" then
            print("Set socket to:",tonumber(commandTable.socket))
			self.Socket:set(tonumber(commandTable.socket))
		end
	end
end


return Sonoff
