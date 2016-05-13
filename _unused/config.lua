function updateAP()
	wifi.setmode(wifi.STATION)
	wifi.sta.disconnect()
	wifi.sta.getap(function(aplist) if aplist~=nil then networks={} for k,v in pairs(aplist) do networks[#networks+1]=k end createServer() else tmr.delay(500000) updateAP() end end)
	tmr.delay(100000)
	wifi.setmode(wifi.STATIONAP)
	cfg={}
	cfg.ssid="PLANT_NODE"
	--cfg.pwd="12341234"
	wifi.ap.config(cfg)
	tmr.delay(250000)
	print(wifi.ap.getip())
end

function applySettings(network, password, interval, numberOfPlants)
	file.remove("settings.lua")
	file.open("settings.lua", "a+")
	file.writeline('network="'..network..'"')
	file.writeline('password="'..password..'"')
	file.writeline('interval=tonumber("'..interval..'")')
	file.writeline('numberOfPlants=tonumber("'..numberOfPlants..'")')
	file.close()
	file.remove("init.lua")
	file.open("init.lua", "a+")
	file.writeline('dofile("client.lc")')
	file.close()
end

function parsePayload(payload)
	local network, password, interval, numberOfPlants = payload:match("network=([^,]+)&password=([^,]+)&interval=([^,]+)&numberOfPlants=([^,]+)")
	if network~=nil and password~=nil and interval~=nil and numberOfPlants~=nil then
		payload=nil
		print(network,password,interval,numberOfPlants)
		applySettings(network,password,interval,numberOfPlants)
		tmr.delay(100000)
		wifi.setmode(wifi.STATION)
		wifi.sta.config(network, password)
		wifi.sta.autoconnect(1)
		tmr.delay(100000)
		node.restart()
	end
end

function createServer()
	srv=net.createServer(net.TCP) srv:listen(80,function(conn)
	conn:on("receive",function(conn,payload)
	parsePayload(payload)
	conn:send([[<html><head><meta name="viewport" content="width=device-width,initial-scale=1,maximum-scale=1,user-scalable=no"/><style>*{font-size:110%;text-align:center;font-family:Arial;}</style></head><body><b>ESP8266 Config<form action="." method="post">
	<select style="width:100%;" name="network">
	<option>]]..table.concat(networks,"</option><option>")..[[</option></select><br>
	<input style="width:100%;" type="password" name="password" placeholder="Password"><br>
	<input style="width:100%;" type="number" name="interval" value="]]..tostring(interval)..[["><br>
	<input style="width:100%;" type="number" name="numberOfPlants" value="]]..tostring(numberOfPlants)..[["><br>
	<input style="width:100%;" type="submit" value="Apply settings"/></body></html>]])end)
	conn:on("sent",function(conn) conn:close() end)end)
end

if file.open('settings.lua', 'r') then 
	dofile('settings.lua')
else
	interval = "Interval"
	numberOfPlants = "Number of Plants"
end 
 RGBled = require('RGBled').new(8,6,7)
 RGBled:blink(RGBled.pinB,-1,500)
 updateAP()
