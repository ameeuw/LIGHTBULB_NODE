-- RGBled.lua module
-- Author: Arne Meeuw
-- github.com/ameeuw
--
-- Simplified API for PWM driven RGBled
-- Initialize:
-- RGBled = require('RGBled').new(pinR, pinG, pinB)
-- 
-- Use:
-- RGBled:blink(RGBled.pinG, times, delay)

local RGBled = {}
RGBled.__index = RGBled

function RGBled.new(pinR, pinG, pinB)
	local self = setmetatable({}, RGBled)
	-- RGB LED pins:
	self.pinR = pinR
	self.pinG = pinG
	self.pinB = pinB
	
	self.timer = 0
	
	-- Set PWM modes
	pwm.setup(pinR,300,0)
	pwm.setup(pinG,300,0)
	pwm.setup(pinB,300,0)
	pwm.start(pinR)
	pwm.start(pinG)
	pwm.start(pinB)
	pwm.setduty(pinR, 0)
	pwm.setduty(pinG, 0)
	pwm.setduty(pinB, 0)
	
	return self
end

function RGBled.blink(self, pin, times, delay)	
	local lighton=0
	local count=0
	tmr.alarm(self.timer,delay,1,
		function()
			if lighton==0 then 
				lighton=1 
				pwm.setduty(pin, 255)
			else 
				lighton=0
				pwm.setduty(pin, 0)
			end
			if count==(times*2-1) then 
				tmr.stop(self.timer) 
			else		
				count=count+1
			end
		end)
end

return RGBled