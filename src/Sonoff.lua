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

function Sonoff.new(pin, name, pressCallback, longPressCallback)
	-- TODO: add timer variable to change timer number
	local self = setmetatable({}, Sonoff)
	local relayPin = 6
	local buttonPin = 3

	-- Set name and mDNS service
	self.name = name
	mdns.register(name, {hardware='Sonoff', description='GET /?socket=[0~1]' service='http', port=80})

	-- Instantiate new RestAPI
	self.RestAPI = require("RestAPI").new(80)
	self.RestAPI:addHook(function(commandTable) self.setHook(self, commandTable) end, {"socket"})
  -- Run REST server
  self.RestAPI:runServer()

	-- Add Button to Sonoff
	if pressCallback~=nil then
		self.pressCallback = pressCallback
	else
		self.pressCallback = function() print("Short press!") end
	end

	if longPressCallback~=nil then
		self.longPressCallback = longPressCallback
	else
		self.longPressCallback = function() print("Long press!") end
	end

	self.Button = require("Button").new(buttonPin, function() self.buttonPress(self) end, function() self.buttonLongPress(self) end)

	-- Add switchable Socket to Sonoff
	self.Socket = require("Socket").new(relayPin)

	return self
end

function Sonoff.buttonPress(self)
	self.pressCallback()
	self.Socket:toggle()
end

function Sonoff.buttonLongPress(self)
	self.longPressCallback()
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
