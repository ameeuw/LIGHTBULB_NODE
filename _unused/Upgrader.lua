function install(url)
    filename=url:match(".-([^\/]-[^%.]+)$")
    print("Sending request for",url)
    http.get(url, "Authorization: Basic YW1lZXV3OkJpbGxhYm9uZzgwNQ==\r\n", function(code, data)
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
end

function upgrade(file)
end