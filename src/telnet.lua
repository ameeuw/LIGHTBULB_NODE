print("==== Remote upgrade Utility ==========")
print("Remote Lua console provided by openthings@164.com")
print("Server starting ......")

function install(url)
    filename=url:match(".-([^\/]-[^%.]+)$")
    print("Sending request for",url)
    auth = "Authorization: Basic YW1lZXV3OkJpbGxhYm9uZzgwNQ==\r\n"
    http.get(url, nil, function(code, data)
        if (code < 0) then
          print("HTTP request failed")
          return code
        else
          --print(code, data)
          print(code.."Writing file: '"..filename.."'")
          file.open(filename,"w+")
          file.write(data)
          file.close()
          --node.compile(filename)
          --file.remove(filename)
        end
      end)
end

function remove(file)
  file.remove(file)
end

function upgrade(file)
  print("Upgraaayyed..")
end

function view(file)
    local _line
    if file.open(file,"r") then
      print("--FileView start")
      repeat _line = file.readline()
        if (_line~=nil) then print(string.sub(_line,1,-2))
        end
      until _line==nil file.close()
      print("--FileView done.")
    else
      print("\r--FileView error: can't open file")
    end
end



 function connected(conn)
    print("Wifi console connected.")
    function s_output(str)
 	  if (conn~=nil)    then
 		 conn:send(str)
 	  end
    end
    node.output(s_output,0)
    conn:on("receive", function(conn, pl)
 	  node.input(pl)
    end)
    conn:on("disconnection",function(conn)
 	  node.output(nil)
    end)
    print("Welcome to the remote upgrade utility.\nPlease type 'install <url>' to download a file from a remote location.\nExecuting a file enter 'dofile(<file>)'\nTo delete a file enter 'remove(<file>)'\nTo view a file enter 'view(<file>)'")
 end

 function startServer()
    print("Wifi AP connected. Telnet IP:")
    print(wifi.sta.getip())
    sv=net.createServer(net.TCP, 23)
    sv:listen(23, connected)
    print("Telnet Server running at :23")
    print("===Now, logon and input LUA.====")
 end

 tmr.alarm(1, 1000, 1, function()
    if wifi.sta.getip()=="0.0.0.0" then
 	  print("Connect AP, Waiting...")
    else
 	  startServer()
 	  tmr.stop(1)
    end
 end)
