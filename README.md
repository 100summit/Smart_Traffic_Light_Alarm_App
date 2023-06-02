# Smart Traffic Light Alarm App

**The app provides notifications and statistics on the different hazards that can occur when crossing a road.**
<br>

## 1) Web/Server(Administrator Center)
The development program is Visual Studio Code, developed in Flutter and Dart languages.

On the server side, Mobius is integrated with hardware and the app to collect and process necessary information. It then passes the appropriate data values to the control center (Web). 
The Web interface displays the received data in a user-friendly UI, allowing users to easily access information such as traffic light status and detailed information.
<br>

## 2) App(Pedestrian)
The App was implemented using Android Studio and Kotlin. App is composed of login page and main page.

- Login page
    Membership registration requires name, phone number, and identity verification. The phone number will be used to determine whether the user is vulnerable or not through user authentication. 
    The function of determining the transportation vulnerable cannot be implemented at present. However, it is assumed that it can be determined through self-certification afterwards.
    
- Main page
    On the main page, various alarms are provided to pedestrians, including alerts for approaching traffic lights, jaywalking, and changes in green light signals. The app is designed to operate even when running in the background.
<br>

## 3) Hardware(Traffic Light)
The hardware consists of a Raspberry Pi4, a module and a sensor. The connection between the Raspberry Pi4 and the module and the sensor is BCM mode, and the development language is Python. 

The lights at the traffic lights used a 12V Flexible LED. We use batteries and 2ch Relay Modules to power traffic lights. The signal time was expressed using 7-Segment. Each 7-Segment displays the signal time on the 7-Segment by attaching an SN74LS47N chip that helps ensure that the binary scale data is represented in the correct number. 

Each hardware means one traffic light.
<br>
