wifi.setmode(wifi.SOFTAP)

cfg =
{
    ip="192.168.1.1",
    netmask="255.255.255.0",
    gateway="192.168.1.1"
}
wifi.ap.setip(cfg)

cfg = 
{
    ssid="SONOFF"
    --pwd="password"
}
wifi.ap.config(cfg)

enduser_setup.start(
  function()
    print("Connected to wifi as:" .. wifi.sta.getip())
  end,
  function(err, str)
    print("enduser_setup: Err #" .. err .. ": " .. str)
  end
);
