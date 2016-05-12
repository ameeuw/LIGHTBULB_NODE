repo = "https://raw.githubusercontent.com/ameeuw/ESP8266_SOCKET_NODE/master/src/"
--local filename = "try.lua"
dofile("Upgrader.lua")
files = {}
files[1] = "HttpRequest.lua"
files[2] = "Button.lua"
files[3] = "RestAPI.lua"

for k,v in pairs(files) do
    print(k,v)
end

counter = 1
function done(filename)
    if counter<=table.getn(files) then
        print("Downloading:",files[counter])
        install(repo,files[counter], done)
        install(repo,files[counter], done)
        counter = counter + 1
    else
        print("Done updating repo")
    end
end

done("")