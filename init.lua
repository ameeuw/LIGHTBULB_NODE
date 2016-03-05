dofile("Upgrader.lua")
RestAPI=require("RestAPI").new(80)

function installHook(commandTable)
    if commandTable.file~=nil then
        install(commandTable.file)
    end
end

RestAPI:addHook(installHook,{"file"})
RestAPI:runServer()