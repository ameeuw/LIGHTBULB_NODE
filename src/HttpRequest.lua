-- httpRequest.lua module
-- Author: Arne Meeuw
-- github.com/ameeuw
--
-- Simplified API for http requests
--
-- Initialize:
-- httpRequest = require('httpRequest').new()
--
--
-- Send a request:
-- httpRequest:send(method, host, URI, payload)
--
-- Parameters:
-- 	method : Request type ('GET' or 'POST')
--	host : host du connect to
--  payload: payload to append to request
--
--
-- Send a makerIFTTT request:
-- httpRequest:sendIFTTT(makerKey, eventName, value1)
-- 
-- Parameters:
--  makerKey: maker API key
-- 	eventName : name of event
--	value1 : value to add to data

local httpRequest = {}
httpRequest.__index = httpRequest

function httpRequest.new()
	local self = setmetatable({}, httpRequest)
	
	-- TODO: add optional RGBled for status messages
	
	return self
end

local function buildPostRequest(host, URI, payload)
	request = "POST "
		..URI
		.." HTTP/1.1\r\n"
		.."Host: "..host.."\r\n"
		.."Content-Type: application/json\r\n"
		.."Connection: close\r\n"
		.."Content-length: "..string.len(payload).."\r\n\r\n"
	  	..payload.."\r\n"
	return request
end

local function buildGetRequest(host, URI)
	request = "GET "
		..URI.." HTTP/1.1\r\n"
		.."Host: "..host.."\r\n"
        .."Authorization: Basic YW1lZXV3OkJpbGxhYm9uZzgwNQ==".."\r\n"
        .."Cache-Control: no-cache\r\n"
		.."\r\n"
	return request
end

function httpRequest.send(self, method, host, URI, payload)
	--print('Sending event: '..eventName..' with value1: '..value1)

	conn = nil
	conn=net.createConnection(net.TCP, 0)

	conn:on("receive", function(conn, payload) print(payload) print("Closing connection.") conn:close() end)

	conn:on("connection", function(conn, payload)
            local sendString
            if method=="GET" then
                sendString = buildGetRequest(host, URI)
            else
                if method=="POST" then
                    sendString = buildPostRequest(host, URI, payload)
                else
                    sendString = '{"error":"GET or POST not specified"}'
                end
            end
            conn:send(sendString)
	end)

    conn:on("sent", function() end)

	conn:dns(host, function(conn, ip)
		if (ip) then
			print("We can connect to "..ip)
			conn:connect(80,ip)
		else
			print("No connection.")
		end
	end)
end

function httpRequest.sendIFTTT(self, makerKey, eventName, value1)
	local method = 'POST'
	local host = 'make.ifttt.com'
	local URI = '/trigger/'..eventName.."/with/key/"..makerKey
	local payload = '{"value1":"'..value1..'"}'
	self.send(self, method, host, URI, payload)
end

return httpRequest
