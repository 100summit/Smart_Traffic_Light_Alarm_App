import random
import paho.mqtt.client as mqtt_client

import json
from collections import OrderedDict

import RPi.GPIO as GPIO
import atexit

import asyncio

broker_address = "192.168.0.238"
broker_port = 1883

topic = "/oneM2M/req/Mobius2/tl1/+"
relpyTopic = "/oneM2M/resp/Mobius2/tl1/json"

GREEN_LED = 20
RED_LED = 21

SEG_1_1 = 17
SEG_1_10 = 27
SEG_1_100 = 22
SEG_1_1000 = 23

SEG_2_1 = 24
SEG_2_10 = 25
SEG_2_100 = 5
SEG_2_1000 = 6

state = ""
r_time = 5
g_time = 5
local_state = ""
local_r_time = 99
local_g_time = 99

client = mqtt_client.Client(f"mqtt_client_{random.randint(0, 100000)}")

def gpioSet():
    GPIO.setmode(GPIO.BCM)
    GPIO.setwarnings(False)
    
    GPIO.setup(GREEN_LED, GPIO.OUT)
    GPIO.setup(RED_LED, GPIO.OUT)
    GPIO.setup(SEG_1_1, GPIO.OUT)
    GPIO.setup(SEG_1_10, GPIO.OUT)
    GPIO.setup(SEG_1_100, GPIO.OUT)
    GPIO.setup(SEG_1_1000, GPIO.OUT)
    GPIO.setup(SEG_2_1, GPIO.OUT)
    GPIO.setup(SEG_2_10, GPIO.OUT)
    GPIO.setup(SEG_2_100, GPIO.OUT)
    GPIO.setup(SEG_2_1000, GPIO.OUT)
    
    GPIO.output(GREEN_LED, GPIO.LOW)
    GPIO.output(RED_LED, GPIO.LOW)
    GPIO.output(SEG_1_1, GPIO.LOW)
    GPIO.output(SEG_1_10, GPIO.LOW)
    GPIO.output(SEG_1_100, GPIO.LOW)
    GPIO.output(SEG_1_1000, GPIO.LOW)
    GPIO.output(SEG_2_1, GPIO.LOW)
    GPIO.output(SEG_2_10, GPIO.LOW)
    GPIO.output(SEG_2_100, GPIO.LOW)
    GPIO.output(SEG_2_1000, GPIO.LOW)

def gpioInit():
    GPIO.output(GREEN_LED, GPIO.LOW)
    GPIO.output(RED_LED, GPIO.LOW)
    GPIO.output(SEG_1_1, GPIO.LOW)
    GPIO.output(SEG_1_10, GPIO.LOW)
    GPIO.output(SEG_1_100, GPIO.LOW)
    GPIO.output(SEG_1_1000, GPIO.LOW)
    GPIO.output(SEG_2_1, GPIO.LOW)
    GPIO.output(SEG_2_10, GPIO.LOW)
    GPIO.output(SEG_2_100, GPIO.LOW)
    GPIO.output(SEG_2_1000, GPIO.LOW)

def ledRedOn():
    GPIO.output(RED_LED, GPIO.HIGH)
    GPIO.output(GREEN_LED, GPIO.LOW)

def ledGreenOn():
    GPIO.output(RED_LED, GPIO.LOW)
    GPIO.output(GREEN_LED, GPIO.HIGH)
    
def displayNumber(number: int):
    one_position = number%10
    ten_position = number//10
    
    one_one = one_position%2
    one_two = one_position//2%2
    one_three = one_position//4%2
    one_four = one_position//8
    GPIO.output(SEG_1_1, one_one)
    GPIO.output(SEG_1_10, one_two)
    GPIO.output(SEG_1_100, one_three)
    GPIO.output(SEG_1_1000, one_four)
    
    ten_one = ten_position%2
    ten_two = ten_position//2%2
    ten_three = ten_position//4%2
    ten_four = ten_position//8
    GPIO.output(SEG_2_1, ten_one)
    GPIO.output(SEG_2_10, ten_two)
    GPIO.output(SEG_2_100, ten_three)
    GPIO.output(SEG_2_1000, ten_four)

def exit():
    gpioInit()
    GPIO.cleanup()

def connect_mqtt():
    client.on_connect = on_connect
    client.on_message = on_message
    client.connect(host=broker_address, port=broker_port)

def on_connect(client, userdata, flags, rc):
        if rc == 0:
            print("Connected to MQTT Broker")
        else:
            print(f"Failed to connect, Returned code: {rc}")
            
        client.subscribe(topic)

def on_message(client, userdata, msg):
    print(f"---> Received `{msg.payload.decode()}` from `{msg.topic}` topic")
        
    try:
        inputJsonData = json.loads(msg.payload.decode())
        replyRqi = inputJsonData.get("rqi")
        publish(client, replyRqi)
        contentTask(inputJsonData)
    except:
        print("Error!!")

def publish(client: mqtt_client, rqi: str):
    replyMsg = OrderedDict()
    replyMsg["rsc"] = 2000
    replyMsg["rqi"] = rqi
    replyMsgString = json.dumps(replyMsg)
    
    result = client.publish(relpyTopic, replyMsgString)
    # result: [0, 1]
    status = result[0]
    if status == 0:
        print(f"---> Send `{replyMsgString}` to topic `{relpyTopic}`")
    else:
        print(f"Failed to send message to topic {relpyTopic}")

def contentTask(input: json):
    global state
    global r_time
    global g_time
    
    content = input.get("pc").get("m2m:sgn").get("nev").get("rep").get("m2m:cin").get("con")
    state = content.get("state")
    r_time = content.get("r_time")
    g_time = content.get("g_time")
    
async def showLedAndSeg():
    global state
    global r_time
    global g_time
    global local_state
    global local_r_time
    global local_g_time
    
    while True:
        if local_state != state:
            gpioInit()
            local_state = state
            if local_state == "red":
                ledRedOn()
                local_r_time = r_time
                displayNumber(local_r_time)
            elif local_state == "green":
                ledGreenOn()
                local_g_time = g_time
                displayNumber(local_g_time)
        elif local_state == state:
            if local_state == "red":
                local_r_time = local_r_time - 1
                displayNumber(local_r_time)
            elif local_state == "green":
                local_g_time = local_g_time - 1
                displayNumber(local_g_time)
                
        await asyncio.sleep(1)

async def main():
    loop = asyncio.get_event_loop()
    tasks = [loop.create_task(showLedAndSeg()), loop.run_in_executor(None, client.loop_forever)]
    await asyncio.wait(tasks)
    
if __name__ == '__main__':
    atexit.register(exit)
    gpioSet()
    connect_mqtt()
    asyncio.run(main())