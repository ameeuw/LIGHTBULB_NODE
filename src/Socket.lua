-- Socket.lua module
-- Author: Arne Meeuw
-- github.com/ameeuw
--
-- Simplified API for remote controlled sockets (ITEAD Sonoff) ESP8266 hardware
--
-- Initialize:
-- Socket = require('Socket').new(pin)
-- 
-- Set socket state:
-- Socket:set(state)
--
-- Parameters:
--	state : 0 or 1
-- 
-- Socket:on()
-- Socket:off()
-- Socket:toggle()

local Socket = {}
Socket.__index = Socket

function Socket.new(pin)
	local self = setmetatable({}, Socket)
	
	self.pin = pin
	self.state = 0
	
	gpio.mode(pin, gpio.OUTPUT)
	
	return self
end

function Socket.set(self, state)
	-- TODO: add type(state)=="number" verification
    --print('Pin: ',self.pin,'State:',state)
	gpio.write(self.pin, (state and 1 or 0))
	self.state = state
end

function Socket.addLed(self, rgbLed)
	
end

function Socket.on(self)
	self.set(self, 1)
end

function Socket.off(self)
	self.set(self, 0)
end

function Socket.toggle(self)
    --print('[toggle] state:',self.state)
	if self.state==false then
		self.on(self)
	else
		self.off(self)
	end
end


return Socket
