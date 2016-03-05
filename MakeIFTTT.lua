-- MakeIFTTT.lua module
-- Author: Arne Meeuw
-- github.com/ameeuw
--
-- Simplified API for IFTTT event triggers to Maker channel
--
-- Initialize:
-- MakeIFTTT = require('MakeIFTTT').new(makerKey)
-- 
-- Send an Event:
-- MakeIFTTT:sendEvent(self, eventName, value1)
--
-- Parameters:
-- 	eventName : name of event
--	value1 : value to add to data

local MakeIFTTT = {}
MakeIFTTT.__index = MakeIFTTT

function MakeIFTTT.new(makerKey)
	local self = setmetatable({}, MakeIFTTT)
	-- RGB LED pins:
	self.makerKey = makerKey
	
	return self
end

local function buildPostRequest(eventName, value1, MAKERkey)
	local data = ""
	data = '{"value1":"'..value1..'"}'
	request = "POST /trigger/"
		..eventName
		.."/with/key/"
		..MAKERkey
		.." HTTP/1.1\r\n"
		.."Host: maker.ifttt.com\r\n"
		.."Content-Type: application/json\r\n"
		.."Connection: close\r\n"
		.."Content-length: "
		..string.len(data)
		.."\r\n\r\n"
	  	..data
	  	.."\r\n"
	return request
end

local function buildGetRequest(eventName, value1, MAKERkey)
	request = "GET /trigger/"
		..eventName
		.."/with/key/"
		..MAKERkey
		.." HTTP/1.1\r\n"
		.."Host: maker.ifttt.com\r\n"
		.."Accept: */*\r\n"
		.."User-Agent: Mozilla/4.0 (compatible; esp8266 Lua; Windows NT 5.1)\r\n"
		.."\r\n"
	return request
end

function MakeIFTTT.sendEvent(self, eventName, value1)
	--print('Sending event: '..eventName..' with value1: '..value1)

	conn = nil
	conn=net.createConnection(net.TCP, 0)

	conn:on("receive", function(conn, payload)
		
	end)

	conn:on("connection", function(conn, payload)
		conn:send(buildPostRequest(eventName, value1, self.makerKey))
		--print("IFTTT request sent.")
	end)

	conn:dns("maker.ifttt.com", function(conn, ip)
		if (ip) then
			--print("We can connect to "..ip)
			conn:connect(80,ip)
		else
			--print("No connection.")
		end
	end)
end


return MakeIFTTT