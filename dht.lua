--- MQTT configuration ---
MQTT_BROKER_IP = "m20.cloudmqtt.com"     
MQTT_BROKER_PORT = 12689
MQTT_USER = "qyrrmsap"
MQTT_PASS = "kOn4LD68EMAz"

TOPIC_SUBSCRIBE = "Modules/Dht/#"
TOPIC_PUBLISH = "Modules/Dht/Temp"

CLIENT_ID = node.chipid()
SECURE_LEVEL = 0 -- without encryption
QOS_LEVEL = 0 -- "fire and forget"
RETAIN_FLAG = 0 -- recive messages only when status changed

--- values for timers ---
SLEEP_TIME_SEC = 30
SLEEP_TIME_MS = 30 * 1000
SLEEP_TIME_US = 30 * 1000 * 1000
AWAKEN_TIME_SEC = 5
AWAKEN_TIME_MS = 5 * 1000

    
            --- DHT ---
DHT_PIN = 4
dhtStatus, dhtTemp, dhtHumi = dht.read11(DHT_PIN)

            --- MQTT ---
mqttClient = mqtt.Client(CLIENT_ID, AWAKEN_TIME_SEC, MQTT_USER, MQTT_PASS)

            --- callback functions for events ---
mqttClient:on("connect", function(client) print ("connected") end)
mqttClient:on("offline", function(client) print ("offline") end)
mqttClient:on("message", function(client, topic, message)
    print(topic .. ":")
    if message ~= nil then
        print(message)
        print("Go sleeping for " .. SLEEP_TIME_SEC .. "sec")    
        node.dsleep(SLEEP_TIME_US)
    end
end)

            --- connect, subscribe and publish ---
mqttClient:connect(MQTT_BROKER_IP, MQTT_BROKER_PORT, SECURE_LEVEL, function(conn) 
    mqttClient:subscribe(TOPIC_SUBSCRIBE, QOS_LEVEL, function(conn) 
        local messageToPublish
        if( dhtStatus == dht.OK ) then 
            messageToPublish = "Temperature: "..dhtTemp.."*C\n".."Humidity: "..dhtHumi.."%"
        elseif( dhtStatus == dht.ERROR_CHECKSUM ) then
            messageToPublish = "DHT Checksum error."
        elseif( dhtStatus == dht.ERROR_TIMEOUT ) then
            messageToPublish = "DHT Time out."
        else
            messageToPublish = "DHT Status error."
        end
        mqttClient:publish(TOPIC_PUBLISH, messageToPublish, QOS_LEVEL, RETAIN_FLAG)  
    end)
end)


            --- go to sleep to save battery ---
ALARM_ID = 0
tmr.alarm(ALARM_ID, AWAKEN_TIME_MS, tmr.ALARM_SINGLE, function() 
    print("Can't connect to MQTT. Reset.")
    node.dsleep(SLEEP_TIME_US)
end)
