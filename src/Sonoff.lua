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

function Sonoff.new(name, pressCallback, longPressCallback)
	-- TODO: add timer variable to change timer number
	local self = setmetatable({}, Sonoff)
	local relayPin = 6
	local buttonPin = 3

	-- Instantiate new RestAPI
	self.RestAPI = require("RestAPI").new(80)
	-- Add Hook listeners
	self.RestAPI:addHook(function(conn, commandTable) self.setHook(self, conn, commandTable) end, {"socket"})
	self.RestAPI:addHook(function(conn, commandTable) self.telnetHook(self, conn, commandTable) end, {"telnet"})
	self.RestAPI:addHook(function(conn, commandTable) self.statusHook(self, conn, commandTable) end, {"status"})
  -- Run REST server
  self.RestAPI:runServer()

	-- Instantiate new MQTT client
	self.MqttClient = mqtt.Client(name, 120, "", "")

	tmr.alarm(5,1000, 1, function()
		print("Connecting MQTT")
		self.MqttClient:connect("app.b0x.it", 3001)
	end)

	-- Add listeners
	self.MqttClient:on("connect", function()
		self.MqttClient:subscribe("light/set", 0)
		tmr.stop(5)
	end)

	-- Add on("message") function to forward incoming topic changes to existing hooks
	self.MqttClient:on("message", function(client, topic, message)
		print(message)
		if (topic == "light/set") and ( ( (message == "on") or (message =="off") ) or ( (message == "true") or (message =="false") ) ) then
			if ( (message == "on") or (message == "true") ) then
				self.Socket:set(true)
			else
				self.Socket:set(false)
			end
			self.MqttClient:publish("light/status", tostring(self.Socket.state), 0, 1)
		end
	end)

	-- Add reconnection on disconnect
	self.MqttClient:on("offline", function(client)
		print("Connection lost - reconnecting.")
		tmr.alarm(5,1000, 1, function()
			print("...")
			self.MqttClient:connect("app.b0x.it", 3001)
		end)
	end)


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

    -- Set name and mDNS service
    self.name = name
    mdns.register(name, {hardware='ITEAD Sonoff', description='GET /?socket=[0~1]', service='http', port=80})

	return self
end

function Sonoff.buttonPress(self)
	self.pressCallback()
	--self.Socket:toggle()
end

function Sonoff.buttonLongPress(self)
	self.longPressCallback()
end

function Sonoff.setHook(self, conn, commandTable)
	if commandTable.socket~=nil then
		if type(tonumber(commandTable.socket))=="number" then
      print("Set socket to:",tonumber(commandTable.socket))
			self.Socket:set(tonumber(commandTable.socket))

			-- local ok, json = pcall(cjson.encode, commandTable)
			-- 		if ok and json~="null" then
			-- 				--print('Sending JSON:',json)
			-- 				conn:send(json)
			-- 		else
			-- 				--print("failed to encode!")
			-- 				conn:send("{'error':'cjson encode fail'}")
			-- end

			conn:send(self.Socket.state)

		end
	end
end

function Sonoff.telnetHook(self, conn, commandTable)
	if commandTable.telnet~=nil then
		if type(tonumber(commandTable.telnet))=="number" then

			local ok, json = pcall(cjson.encode, commandTable)
					if ok and json~="null" then
							--print('Sending JSON:',json)
							conn:send(json)
					else
							--print("failed to encode!")
							conn:send("{'error':'cjson encode fail'}")
			end

			print("Starting telnet remote.")
			self.RestAPI:stopServer()
			dofile("telnet.lc")
		end
	end
end

function Sonoff.statusHook(self, conn, commandTable)
	if commandTable.status~=nil then
		if type(tonumber(commandTable.status))=="number" then
      print("Sending status:",tonumber(self.Socket.state))
			conn:send(self.Socket.state)
		end
	end
end

return Sonoff
