-- Button.lua module
-- Author: Arne Meeuw
-- github.com/ameeuw
--
-- Simplified API for push button handling ESP8266 hardware
--
-- Initialize:
-- Button = require('Button').new(pin, pressCallback, longPressCallback)
-- 
-- pin : Pin push button is connected to
-- pressCallback :  function to call when button is pressed
-- longPressCallback : function to call when button is pressed long
--

local Button = {}
Button.__index = Button

function Button.new(pin, pressCallback, longPressCallback)
	-- TODO: add timer variable to change timer number
	local self = setmetatable({}, Button)
	
	self.pin = pin
	self.pressCallback = pressCallback
	if longPressCallback~=nil then
		self.longPressCallback = longPressCallback
	else
		self.longPressCallback = pressCallback
	end
	
	-- Set mode and trigger
	gpio.mode(self.pin,gpio.INT,gpio.PULLUP)
	gpio.trig(self.pin,"low",function(level) self.checkLongPress(self) end)
	
	return self
end

-- Check if button was pressed long
function Button.checkLongPress(self)
    gpio.mode(self.pin,gpio.OUTPUT)
    gpio.write(self.pin,gpio.HIGH)
    tmr.alarm(1,500,0,function()
        if gpio.read(self.pin)~=gpio.HIGH then
        -- long press received
            self.longPressCallback()
        else
        -- short press received         
            self.pressCallback()
        end
    end)
    tmr.delay(500)
    gpio.mode(self.pin,gpio.INT,gpio.PULLUP)
    gpio.trig(self.pin,"down",function(level) self.checkLongPress(self) end)
end


return Button
