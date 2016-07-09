-- Lightbulb.lua module
-- Author: Arne Meeuw
-- github.com/ameeuw
--
-- Module for Witty ESP board hardware
--
-- Initialize:
-- Lightbulb = require('Lightbulb').new(mqttHost, mqttPort)
--
-- Methods:
-- Lightbulb:

local Lightbulb = {}
Lightbulb.__index = Lightbulb

function Lightbulb.new(mqttHost, mqttPort)
	-- TODO: add timer variable to change timer number
	local self = setmetatable({}, Lightbulb)

	if RGBled ~= nil then
		RGBled:breathe(1,0,50,0)
	else
		RGBled = require("RGBled").new("PWM",{8,6,7})
	end

  self.mqttHost = mqttHost
  self.mqttPort = mqttPort
	self.name = 'Lightbulb:'..string.sub(wifi.sta.getmac(),13,-1)
	self.domain = 'burggraben'
	self.topic = self.domain..'/'..self.name..'/'
	self.services = '{"lightbulb" : "true", "lightsensor" : "true"}'

	self.on = false
	self.brightness = 0
	self.hue = 0
	self.saturation = 0

	-- Instantiate new MQTT client
	self.MqttClient = mqtt.Client(self.name, 120, "", "")

	RGBled:breathe(-1,100,10,0)
	tmr.alarm(5,1500, 1,
		function()
			print("Connecting MQTT")
			self.MqttClient:connect(self.mqttHost, self.mqttPort)
		end)

	-- Send sampled value as soon as node is connected
	self.MqttClient:on("connect",
		function()
    	tmr.stop(5)
			RGBled:stop()
			print("Connected to:",self.mqttHost)
			self.MqttClient:publish(self.topic.."services/get", self.services, 0, 1)
			self.MqttClient:subscribe(self.topic.."#", 0)
    	-- RGBled:breathe(3,0,80,0)

	    -- tmr.alarm(5, 10000, 1,
			-- 	function()
	    --   node.dsleep(300000000)
	    -- end)

		end)



		-- Add on("message") function to forward incoming topic changes to existing hooks
		self.MqttClient:on("message", function(client, topic, message)
			print(message, topic)

			if ( topic == self.topic.."on/set") then
				if message == "true" then
					self.on = true
				else
					self.on = false
				end
				self.setHsb(self, self.hue, self.saturation, (self.on and 1 or 0)*self.brightness)
				self.MqttClient:publish(self.topic.."on/get", tostring(self.on), 0, 1)
			end

			if ( topic == self.topic.."brightness/set") then
				self.brightness = tonumber(message)
				-- RGBled:fade(self.brightness, self.hue, self.saturation)
				self.setHsb(self, self.hue, self.saturation, self.brightness)
				self.MqttClient:publish(self.topic.."brightness/get", tostring(self.brightness), 0, 1)
			end

			if ( topic == self.topic.."hue/set") then
				self.hue = tonumber(message)
				-- RGBled:fade(self.brightness, self.hue, self.saturation)
				self.setHsb(self, self.hue, self.saturation, self.brightness)
				self.MqttClient:publish(self.topic.."hue/get", tostring(self.hue), 0, 1)
			end

			if ( topic == self.topic.."saturation/set") then
				self.saturation = tonumber(message)
				-- RGBled:fade(self.brightness, self.hue, self.saturation)
				self.setHsb(self, self.hue, self.saturation, self.brightness)
				self.MqttClient:publish(self.topic.."saturation/get", tostring(self.saturation), 0, 1)
			end

			if ( topic == self.topic.."domain/set") then
				self.domain = message
				-- TODO: check retain flag
				self.MqttClient:unsubscribe(self.topic.."#")
				self.topic = self.domain..'/'..self.name..'/'
				self.MqttClient:subscribe(self.topic.."#", 0)
				self.MqttClient:publish(self.topic.."domain/get", self.domain, 0, 0)
			end

		end)

	-- Add reconnection on disconnect
	self.MqttClient:on("offline",
		function(client)
			print("Connection lost - reconnecting.")
			RGBled:breathe(-1,100,10,0)
			tmr.alarm(5,1000, 1,
				function()
					print("...")
					self.MqttClient:connect(self.mqttHost, self.mqttPort)
				end)
		end)

	return self
end

function Lightbulb.setHsb(self, h, s, b)
	--[[
	 * Converts an HSV color value to RGB. Conversion formula
	 * adapted from http://en.wikipedia.org/wiki/HSV_color_space.
	 * Assumes h, s, and v are contained in the set [0, 1] and
	 * returns r, g, and b in the set [0, 255].
	 *
	 * @param   Number  h       The hue
	 * @param   Number  s       The saturation
	 * @param   Number  v       The value
	 * @return  Array           The RGB representation
	]]
	function hsvToRgb(h, s, v)
	  local r, g, b

	  local i = math.floor(h * 6);
	  local f = h * 6 - i;
	  local p = v * (1 - s);
	  local q = v * (1 - f * s);
	  local t = v * (1 - (1 - f) * s);

	  i = i % 6

	  if i == 0 then r, g, b = v, t, p
	  elseif i == 1 then r, g, b = q, v, p
	  elseif i == 2 then r, g, b = p, v, t
	  elseif i == 3 then r, g, b = p, q, v
	  elseif i == 4 then r, g, b = t, p, v
	  elseif i == 5 then r, g, b = v, p, q
	  end

	  return r * 255, g * 255, b * 255
	end

	RGBled:fade(hsvToRgb((h/360),(s/100),(b/100)))

end

return Lightbulb
