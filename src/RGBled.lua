-- RGBled.lua module
-- Author: Arne Meeuw
-- github.com/ameeuw
--
-- Simplified API for PWM driven or WS2812 RGBled
-- Initialize:
-- RGBled = require('RGBled').new(mode, pins)
-- 		mode: "PWM" or "WS2812"w
--		pins: table of pins (use {})
-- Use:
-- RGBled:blink(times, delay, r, g, b)
--	times: how many times blink
--	delay: time between flashes in ms
--	r, g, b: Byte values of colors to blink
--
-- RGBled:setRGB(r, g, b)
-- RGBled:fade(r, g, b)
-- RGBled:blink(times, delay, r, g, b)
-- RGBled:breathe(times, r, g, b)

local RGBled = {}
RGBled.__index = RGBled

function RGBled.new(mode, pins, timer)
	local self = setmetatable({}, RGBled)

	self.color = {}
	self.color.r = 0
	self.color.g = 0
	self.color.b = 0

	if mode == "PWM" then
		-- RGB LED pins:
		self.pinR = pins[1]
		self.pinG = pins[2]
		self.pinB = pins[3]
		self.mode = "PWM"

		-- Set PWM modes
		for _,pin in ipairs(pins) do
			pwm.setup(pin,300,0)
			pwm.start(pin)
			pwm.setduty(pin,0)
		end
	end

	if mode == "WS2812" then
		-- RGB LED pin:
		if pins[1] ~= nil then
			self.pinWS = pins[1]
		else
			self.pinWS = pins
		end
			self.mode = "WS2812"
	end

	if timer~=nil then
		self.timer = timer
	else
		self.timer = 0
	end

	return self
end

function RGBled.blink(self, times, delay, r, g, b)
	local lighton=0
	local count=0
	tmr.alarm(self.timer,delay,1,
		function()
			if lighton==0 then
				lighton=1
				self.setRGB(self, r, g, b)
			else
				lighton=0
				self.setRGB(self, 0, 0, 0)
			end
			if count==(times*2-1) then
				tmr.stop(self.timer)
			else
				count=count+1
			end
		end)
end

function RGBled.breathe(self, times, r, g, b)
    local dim = 5
    local direction = 1
    local count = 0
    local stepDelay = 20
    local maxSteps = 100
    local minSteps = 5
    tmr.alarm(self.timer,stepDelay,1,
        function()
            local tR = r * dim / maxSteps
            local tG = g * dim / maxSteps
            local tB = b * dim / maxSteps
            self.setRGB(self, tR, tG, tB)
            dim = dim + direction
            if dim > maxSteps then
                direction = -1
            end
            if dim < minSteps then
                direction = 1
                count = count + 1
            end
            if count == times then
                tmr.stop(self.timer)
                self.setRGB(self,0,0,0)
            end
        end)
end

function RGBled.fade(self, r, g, b)
	local step = 0
	local steps = 35
	local stepDelay = 20
	local dr = (r - self.color.r)
	local dg = (g - self.color.g)
	local db = (b - self.color.b)

	tmr.alarm(self.timer,stepDelay,tmr.ALARM_AUTO,
		function()
			step = step + 1
			local cr = math.max(0, self.color.r + step * dr / steps)
			local cg = math.max(0, self.color.g + step * dg / steps)
			local cb = math.max(0, self.color.b + step * db / steps)

			if self.mode == "PWM" then
				pwm.setduty(self.pinR, cr)
				pwm.setduty(self.pinG, cg)
				pwm.setduty(self.pinB, cb)
			end
			if self.mode == "WS2812" then
				ws2812.writergb(self.pinWS, string.char(cr,cg,cb))
			end

			if step > steps then
				tmr.stop(self.timer)
				self.setRGB(self, cr, cg, cb)
			end
		end)
end

function RGBled.setRGB(self, r, g, b)

	if self.mode == "PWM" then
		pwm.setduty(self.pinR, r)
		pwm.setduty(self.pinG, g)
		pwm.setduty(self.pinB, b)
	end

	if self.mode == "WS2812" then
		ws2812.writergb(self.pinWS, string.char(r,g,b))
	end

	self.color.r = r
	self.color.g = g
	self.color.b = b
end

function RGBled.stop(self)
    tmr.stop(self.timer)
end

return RGBled
