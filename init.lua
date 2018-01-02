--- Constants ---
FILE_TO_EXECUTE = "dht.lua"
SLEEP_TIME_US = 30 * 1000 * 1000

--- test WIFI config ---
WIFI_SSID = "MyWiFiSSID"
WIFI_PASS = "MyWiFiPASS"

--- Connect to WiFi ---
wifi.setmode(wifi.STATION)
wifi.setphymode(wifi.PHYMODE_G)
wifi.sta.config(WIFI_SSID, WIFI_PASS)

--- Init ---
print("Initiate module, connecting to Wi-fi.")
print("Type tmr.stop(0) to terminate program.")

connCounter = 0
ALARM_ID = 0
tmr.alarm(ALARM_ID, 1000, tmr.ALARM_AUTO, function() 
    if wifi.sta.getip() == nil then 
        print("Waiting for IP address...")
        connCounter =  connCounter + 1
    elseif connCounter >= 10 then
        print("Can't connect to wi-fi. Reset.")
        node.dsleep(SLEEP_TIME_US)
    else
        tmr.stop(ALARM_ID)
        print("New IP address is "..wifi.sta.getip()) 
        print("Start file: ".. FILE_TO_EXECUTE)
        dofile(FILE_TO_EXECUTE)
    end 
end)