package com.summit.hackerton.define

import android.Manifest
import android.provider.Settings
import com.summit.hackerton.local.data.TrafficGeofence
import com.summit.hackerton.local.data.UserInfo
import java.text.SimpleDateFormat
import java.util.*

/**
 * App Define
 *
 * @author Brand
 * @created 2023-05-23
 **/
object AppDefine {

    // 필요 권한
    val NEED_PERMISSIONS: Array<String> = arrayOf(
        Manifest.permission.ACCESS_FINE_LOCATION,
        Manifest.permission.ACCESS_COARSE_LOCATION,
        Manifest.permission.ACCESS_BACKGROUND_LOCATION
    )

    // 포그라운드 서비스 Notification에 사용되는 인자들
    const val FOREGROUND_NOTIFICATION_CHANNEL_ID = "foreground_notification_channel"
    const val FOREGROUND_NOTIFICATION_CHANNEL_NAME = "foreground_notification"
    const val FOREGROUND_NOTIFICATION_CHANNEL_ID_NUMBER = 1

    // 기본 Notification에 사용되는 인자들
    const val NOTIFICATION_CHANNEL_ID = "notification_channel"
    const val NOTIFICATION_CHANNEL_NAME = "notification"
    const val NOTIFICATION_CHANNEL_ID_NUMBER = 2


    /** 현재시간 구하기 ["yyyy-MM-dd HH:mm:ss"] (*HH: 24시간)*/
    fun getTime(): String {
        val now = System.currentTimeMillis()
        val date = Date(now)

        val dateFormat = SimpleDateFormat("yyyy-MM-dd HH:mm:ss")
        val getTime = dateFormat.format(date)

        return getTime
    }


    var me : UserInfo = UserInfo()

    var crossWalkTargetTrafficLight : TrafficGeofence = TrafficGeofence()

    var nowTargetTlState = ""

    var enterTime = 0L
    var exitTime= 0L
}