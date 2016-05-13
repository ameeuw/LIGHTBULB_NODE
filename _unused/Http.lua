-- Http.lua module
-- Author: Arne Meeuw
-- github.com/ameeuw
--
--------------------------------------
-- Simplified API for Http requests --
--------------------------------------
--
-- Initialize:
-- HttpRequest = require('Http').new()
--
------------------------------------------------------------
--
-- Send a get request:
-- Http:get(url, headers, callback)
--
-- Parameters:
--	url : url to connect to
--	headers: addition headers (strings)
--	callback: function(payload) to call when reply is in
--
------------------------------------------------------------
--
-- Send a post request:
-- Http:post(url, headers, body, callback)
--
-- Parameters:
--	url : url to connect to
--	headers: addition headers (strings)
--  body: body to append to the request
--	callback: function(payload) to call when reply is in



local Http = {}
Http.__index = Http

function Http.new()
	local self = setmetatable({}, Http)
	
	-- TODO: add optional RGBled for status messages
	
	return self
end

local function send(self, protocol, host, sendString, callback)
    -- print("Protocol:",protocol)
    -- print("Host:",host)
    print("Sendstring:",sendString)
    local conn = nil
    -- Check for encryption
    if protocol=='https' then
        local secure = 1
    else
        local secure = 0
    end
    conn=net.createConnection(net.TCP, secure)

    conn:on("receive", function(conn, payload) 
        -- print("Received answer...")
        callback(payload)
    end)
    
    conn:on("connection", function(conn, payload)
        -- print("Sending request...")
        conn:send(sendString)
    end)

    conn:dns(host, function(conn, ip)
        if (ip) then
            -- print("We can connect to "..ip)
            conn:connect(80,ip)
        else
            print("No connection.")
        end
    end)
end

local function split(url)
    print('Splitting url: "'..url..'"')
    local protocol, host, uri = url:match('([http|https]*)[:/]*([^/]+)([%w%p]+)')
    if protocol=='' then
        protocol='http'
    end
    print(protocol, host, uri)
    
    local paramTable = {}
    for name, value in string.gfind(uri, "/?%??([^&=]+)=([^&=]+)") do
        paramTable[name] = value
    end
    
    return protocol, host, uri, paramTable
end

function Http.post(url, headers, body, callback)
	-- TODO: add type handling of body (table or string)
	-- 		 and adapt header (json) accordingly
    local protocol, host, uri, paramTable = split(url)
	sendString = "POST "
		..uri.." HTTP/1.1\r\n"
		.."Host: "..host.."\r\n"
		.."Content-Type: application/json\r\n"
		.."Connection: close\r\n"
		.."User-Agent: ESP8266\r\n".."\r\n"
		.."Content-length: "..string.len(body).."\r\n".."\r\n"
	  	..body.."\r\n"
	send(self, protocol, host, sendString, callback)
	return 0
end

function Http.get(url, headers, callback)
    local protocol, host, uri, paramTable = split(url)
	sendString = "GET "
	    ..uri.." HTTP/1.1\r\n"
		.."Host: "..host.."\r\n"
		..headers
		--.."Connection: close\r\n"
		--.."User-Agent: ESP8266\r\n"
		.."\r\n"
	send(self, protocol, host, sendString, callback)
	return 0
end

return Http
