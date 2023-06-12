# flutter_mobius

Web and server implementation through flutter (dart).

## Getting Started

The project was developed in a Mac environment. It may not work smoothly in a window environment.

1. Git clone of the project and Mobius local setting must be ready. (+You must also configure MySql in your local environment.)

2. Installation of visual studio code for flutter installation and flutter execution is mandatory.
- [Go to install a flutter](https://docs.flutter.dev/release/archive?tab=macos)
- [Go to install a visual studio code](https://code.visualstudio.com)
(You need at least one traffic light data, a group resource that binds the status of the traffic light, and a group resource that binds the ci data of the traffic light.)

3. Use the images attached to the https://www.hackster.io site to pre-configure the Mobius configuration and data settings for the initial traffic lights.
- [Go to check oneM2M resource structure diagram](https://www.hackster.io/506312/smart-traffic-light-alarm-app-c4a34a#toc-onem2m-resource-structure-diagram-5)

4. In the NetworkProvider.dart file, replace all API domains with your configured Mobius' ip address.

5. Run the project with debugging or release in the main.dart file.

6. Make sure to set the target os to web(chrome) when running.

Depending on the situation, Firebase interworking may be required.
Create a Firebase project with your personal account, and then connect Firebase in a Flutter project
- [Connect firebase to flutter](https://firebase.google.com/docs/flutter/setup?hl=ko&platform=web)
(Make sure to include web settings when installing firebase)

## Special note

The project has the logic of periodically collecting data from users across crosswalks, analyzing and processing the data, and uploading it to mobius.
To change that period, you must modify the getCiData() function in the main.dart file. Currently, it is set 1 minute.