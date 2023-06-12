App implementation through Kotlin.

## Getting Started

The project was developed in a Window environment. It may not work smoothly in a mac environment.

<pre>
<code>
Environment
- Android Studio Electric Eel | 2022.1.1
- Kotlin
- Android Studio embedded JDK
- Gradle Plugin Version : 7.2.1
- Gradle Version : 7.3.3
</code>
</pre>

1. Download Android Studio
- [Go to install a Android Studio](https://developer.android.com/studio)

2. Download "App" Directory and open the project through android studio

3. Please wait while initializing

4. Create a Firebase project with your personal account, and then connect Firebase in a Flutter project
- [Connect firebase to Android](https://firebase.google.com/docs/android/setup?hl=ko)

5. Modify the IP and Port values ​​inside the App/app/src/main/java/com/summit/hackerton/utils/MqttUtils.kt  route file to appropriate values.

6. After completing the above settings, build and run the app</br>
(If you do not have a real device, you can build the app using the emulator in Android Studio)
- [Android Studio Emulator](https://developer.android.com/studio/run/emulator?hl=ko)

## Special note
> <span style="color:orange">- If you want to build with release, you need to create and modify a new keystore</span></br>
> <span style="color:orange">- If Build fails, please check Gradle Version and JDK Version</span>